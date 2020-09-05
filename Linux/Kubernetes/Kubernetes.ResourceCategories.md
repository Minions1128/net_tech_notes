# Kubernetes 资源清单

- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#-strong-api-overview-strong-

- **Workloads**: are objects you use to manage and run your containers on the cluster.
    - Pod, ReplicaSet, Deployment, StatefulSet, DaemonSet, Job, Cronjob

- **Discovery & LB resources**: are objects you use to "stitch" your workloads together into an externally accessible, load-balanced Service.
    - Service, Ingress

- **Config & Storage resources**: are objects you use to inject initialization data into your applications, and to persist data that is external to your container.
    - Volume, CSI, ConfigMap, Secret

- **Cluster resources**: objects define how the cluster itself is configured; these are typically used only by cluster operators.
    - Namespace, Node, Role, ClusterRole, RoleBinding, ClusterRoleBinding

- **Metadata resources**: are objects you use to configure the behavior of other resources within the cluster, such as HorizontalPodAutoscaler for scaling workloads.
    - HPA, PodTemplate, LimitRange

- 一般的一级字段
    - apiVersion(group/version): `kubectl api-versions`
    - kind
    - metadata(name, namespace, labels, annotations, ...)
    - spec
    - status(readOnly)

## Pods

```yaml
# demo
apiVersion: v1
kind: Pod
metadata:
  name: pod-demo
  namespace: default
  labels:
    app: myapp
    tier: frontend
spec:
  containers:                   # required
    - name: myngx               # required
      image: nginx:latest       # required
      ports:
        - name: http
          containerPort: 80     # required
        - name: https
          containerPort: 443
    - name: mybbox
      image: busybox:latest
      command:
        - "/bin/sh"
        - "-c"
        - "sleep 1000"
```

```yaml
# liveness-exec-container
apiVersion: v1
kind: Pod
metadata:
  name: liveness-exec-pod
  namespace: default
spec:
  containers:
    - name: liveness-exec-container
      image: busybox:latest
      imagePullPolicy: IfNotPresent
      command:
        - "/bin/sh"
        - "-c"
        - "touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 3600"
      livenessProbe:
        exec:
          command:
            - "test"
            - "-e"
            - "/tmp/healthy"
        initialDelaySeconds: 1
        periodSeconds: 3
```

```yaml
# readiness-httpget-pod
apiVersion: v1
kind: Pod
metadata:
  name: readiness-httpget-pod
  namespace: default
spec:
  containers:
    - name: readiness-httpget-container
      image: nginx:latest
      imagePullPolicy: IfNotPresent
      ports:
        - name: http
          containerPort: 80
      readinessProbe:
        httpGet:
          port: http
          path: /var/www/html/index.html
        initialDelaySeconds: 1
        periodSeconds: 3
```

## Pod控制器

### ReplicaSet

- https://www.cnblogs.com/linuxk/p/9578211.html#二、ReplicaSet控制器

- 代用户创建指定数量的pod副本数量, 确保pod副本数量符合预期状态, 并且支持滚动式自动扩容和缩容功能.
    - ReplicaSet主要三个组件组成
        - 1) 用户期望的pod副本数量
        - 2）标签选择器, 判断哪个pod归自己管理
        - 3）当现存的pod数量不足, 会根据pod资源模板进行新建
    - 帮助用户管理无状态的pod资源, 精确反应用户定义的目标数量, 但是RelicaSet不是直接使用的控制器, 而是使用Deployment

```yaml
# ReplicaSet
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      release: canary
  template:             # Pod
    metadata:
      name: myapp-pod
      labels:
        app: myapp
        release: canary
        environment: qa
    spec:
      containers:
        - name: myapp-container
          image: nginx:latest
          ports:
            - name: http
              containerPort: 80
```

### Deployment

- https://www.cnblogs.com/linuxk/p/9578211.html#三、Deployment控制器

- 工作在ReplicaSet之上, 用于管理无状态应用, 目前来说最好的控制器. 支持滚动更新和回滚功能, 还提供声明式配置.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deploy
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      release: canary
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:                 # pod
    metadata:
      labels:
        app: myapp
        release: canary
    spec:
      containers:
        - name: myapp
          image: nginx:latest
          ports:
            - name: http
              containerPort: 80
```

### DaemonSet

- https://www.cnblogs.com/linuxk/p/9597470.html

- 用于确保集群中的每一个节点只运行特定的pod副本, 通常用于实现系统级后台任务, 比如ELK服务
    - 特性: 服务是无状态的
    - 服务必须是守护进程

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
      role: logstor
  template:
    metadata:
      labels:
        app: redis
        role: logstor
    spec:
      containers:
        - name: redis
          image: redis:4.0-alpine
          ports:
            - name: redis
              containerPort: 6379
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: filebeat-ds
  namespace: default
spec:
  selector:
    matchLabels:
      app: filebeat
      release: stable
  template:
    metadata:
      labels:
        app: filebeat
        release: stable
    spec:
      containers:
        - name: filebeat
          image: ikubernetes/filebeat:5.6.5-alpine
          env:
            - name: REDIS_HOST
              value: redis.default.svc.cluster.local
            - name: REDIS_LOG_LEVEL
              value: info
```

### Job & Cronjob

- 只要完成就立即退出, 不需要重启或重建.
- 周期性任务控制, 不需要持续后台运行

### StatefulSet

- 管理有状态应用

### Service

- https://www.cnblogs.com/linuxk/p/9605901.html

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: default
spec:
  selector:                   # 标签选择器，必须指定pod资源本身的标签
    app: myapp
    release: canary
  type: NodePort
  # {NodePort|ExternalName|ClusterIP|NodePort|LoadBalancer}
  ports:
    - port: 80                # 暴露给服务的端口
      targetPort: 80          # 容器的端口
      nodePort: 30080         # node port
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deploy
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      release: canary
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:                 # pod
    metadata:
      labels:
        app: myapp
        release: canary
    spec:
      containers:
        - name: myapp
          image: nginx:latest
          ports:
            - name: http
              containerPort: 80
```

### Ingress和Ingress Controller

- https://www.cnblogs.com/linuxk/p/9706720.html
- [ingress-nginx部署](https://www.jianshu.com/p/52889bc8571d "ingress-nginx部署")

- 部署 Ingress controller

```sh
wget https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/deploy/static/mandatory.yaml
sed -i 's/quay.io/quay.azk8s.cn/' mandatory.yaml
kubectl apply -f mandatory.yaml
```

- 部署 ingress-nginx service

```sh
wget https://github.com/kubernetes/ingress-nginx/blob/nginx-0.30.0/deploy/static/provider/baremetal/service-nodeport.yaml
sed -i 's/targetPort: 80/targetPort: 80\n      nodePort: 30080/' \
    service-nodeport.yaml
sed -i 's/targetPort: 443/targetPort: 443\n      nodePort: 30443/' \
    service-nodeport.yaml
kubectl apply -f service-nodeport.yaml
```

- 部署后端服务

```yaml
# 创建service为myapp
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: default
spec:
  selector:
    app: myapp
    release: canary
  ports:
    - name: http
      targetPort: 80
      port: 80
---
# 创建后端服务的pod
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-backend-pod
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      release: canary
  template:
    metadata:
      labels:
        app: myapp
        release: canary
    spec:
      containers:
        - name: myapp
          image: ikubernetes/myapp:v2
          ports:
            - name: http
              containerPort: 80
```

- 部署ingress

```yaml
# ingress
apiVersion: extensions/v1beta1              # api版本
kind: Ingress   #清单类型
metadata:     #元数据
  name: ingress-myapp                       # ingress的名称
  namespace: default                        # 所属名称空间
  annotations:                              # 注解信息
    kubernetes.io/ingress.class: "nginx"
spec:                                       # 规格
  rules:                                    # 定义后端转发的规则
  - host: myapp.example.com                 # 通过域名进行转发
    http:
      paths:
      - path:
      # 配置访问路径, 如果通过url进行转发, 需要修改; 空默认为访问的路径为"/"
        backend:                            # 配置后端服务
          serviceName: myapp
          servicePort: 80
```

- 部署 tomcat tls

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-tomcat-tls
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  tls:
  - hosts:
    - tomcat.example.com
    secretName: tomcat-ingress-secret
  rules:
  - host: tomcat.example.com
    http:
      paths:
      - path:
        backend:
          serviceName: tomcat
          servicePort: 8080
```
