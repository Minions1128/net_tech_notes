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

- 一级字段
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
