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
