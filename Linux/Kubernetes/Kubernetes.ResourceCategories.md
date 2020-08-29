# Kubernetes 资源清单

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
