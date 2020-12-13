# Kubernetes

- [Kubernetes 文档](https://www.kubernetes.org.cn/k8s "Kubernetes 文档")

- [Centos7部署Kubernetes集群](https://www.cnblogs.com/zhenyuyaodidiao/p/6500830.html "Centos7部署Kubernetes集群")

- [浅析flannel与docker结合的机制和原理](https://xuxinkun.github.io/2016/07/18/flannel-docker/ "浅析flannel与docker结合的机制和原理")

- [k8s核心yml--Pod、Deployment、Service](https://cloud.tencent.com/developer/article/1462777 "k8s核心yml--Pod、Deployment、Service")

## 容器编排三组解决方案

- Docker容器编排三剑客
    - docker-machine: 管理docker各个节点
    - docker-swarm: 管理容器集群, 监控容器
    - docker-compose: 实现编排
- ASF: mesos(资源调框架, IDC操作系统), marathon(编排容器)
- Google: Kubernetes

## 概述

- Kubernetes is an open source system for managing containerized applications across multiple hosts, providing basic mechanisms for deployment, maintenance, and scaling of applications.

- Kubernetes Cluster: A running Kubernetes cluster contains node agents (kubelet) and a cluster control plane (AKA master), with cluster state backed by a distributed storage system (etcd)

[![k8s.cluster](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.cluster.jpg "k8s.cluster")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.cluster.jpg "k8s.cluster")

- 架构: master/agent

[![k8s.arch.view](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.arch.view.jpg "k8s.arch.view")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.arch.view.jpg "k8s.arch.view")

- master主机:
    - kube-API Server: Kubernetes API server
    - kubu-scheduler: Schedules pods in worker nodes
    - kube-controller-manager: 监控部署的容器是否够用
        - Replication Controller - Manages replication of pods
            - Ensures that a Pod or homogeneous set of Pods are always up and available
            - Always maintains desired number of Pods
                - If there are excess Pods, they get killed
                - New pods are launched when they fail, get deleted, or terminated
            - Creating a replication controller with a count of 1 ensures that a Pod is always available
            - Replication Controller and Pods are associated through Labels
        - Replication Sets
    - etcd(golang): A metadata service, distributed key-value store (zookeeper)

[![k8s.master](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.master.jpg "k8s.master")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.master.jpg "k8s.master")

- node:
    - kubelet: Container Agent
    - container runtime(docker/rkt/...)
    - kube-proxy: A load balancer for Pods
    - supervisord:
    - Pod: A group of Containers, pods之间为joined container.
    - Addons: 附件
    - fluentd: 日志收集工具
    - cAdvisor - Container Advisor providers resource usage/performance statistics, 统计代理程序

[![k8s.node](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.node.jpg "k8s.node")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.node.jpg "k8s.node")

[![k8s.arch](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.arch.jpg "k8s.arch")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.arch.jpg "k8s.arch")

- Key Concepts of Kubernetes
    - Labels: Labels for identifying pods
    - Group: label的key和value都相同的pod称之为group, 通常会给group赋予IP地址

- Pod
    - A group of one or more containers that are always co-located and co-scheduled that share the context
    - Containers in a pod share the same IP address, ports, hostname and storage
    - Modeled like a virtual machine
        - Each container represents one process
        - Tightly coupled with other containers in the same pod
    - Pods are scheduled in Nodes
    - Fundamental unit of deployment in Kubernetes
    - Containers within the same pod communicate with each other using IPC(Inter-Process Communication);
    - Containers can find each other via localhost;
    - Each container inherits the name of the pod
    - Each pod has an IP address in a flat shared networking space
    - Volumes are shared by containers in a pod

[![k8s.pod](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.pod.jpg "k8s.pod")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.pod.jpg "k8s.pod")

[![k8s.deploy.a.pod](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.deploy.a.pod.jpg "k8s.deploy.a.pod")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.deploy.a.pod.jpg "k8s.deploy.a.pod")

- Controllers
    - Replica Sets
    - Deployments
    - Daemon Sets
    - Jobs

- Services: 赋予IP地址的group, 以及group包含的pods, 称之为service
    - Kubernetes Pods are mortal, they are born and when they die, they are not resurrected
    - ReplicationControllers in particular create and destroy Pods dynamically (e.g. when scaling up or down or when doing rolling updates)
    - While each Pod gets its own IP address, even those IP addresses cannot be relied upon to be stable over time
    - This leads to a problem: if some set of Pods (let’s call them backends) provides functionality to other Pods (let’s call them frontends) inside the Kubernetes cluster, how do those frontends find out and keep track of which backends are in that set?
    - A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service
    - The set of Pods targeted by a Service is (usually) determined by a Label Selector
    - For Kubernetes-native applications, Kubernetes offers a simple Endpoints API that is updated whenever the set of Pods in a Service changes
    - For non-native applications, Kubernetes offers a virtual-IP-based bridge to Services which redirects to the backend Pods
    - Services are exposed through internal and external endpoints
    - Supports TCP and UDP
    - Interfaces with kube-proxy to manipulate iptables
    - Service can be exposed internal or external to the cluster
        - A Service as a static API object
        - virtual, but static IP
        - no service discovery necessary
    - A group of pods that work together: grouped by a selector
    - Defines access policy: "load balanced" or "headless"
    - Gets a stable virtual IP and port
        - sometimes called the service portal
        - also a DNS name
    - VIP is managed by kube-proxy
        - watches all services
        - updates iptables when backends change
    - Hides complexity-ideal for non-native apps

[![k8s.obj.service](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.obj.service.jpg "k8s.obj.service")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.obj.service.jpg "k8s.obj.service")

[![k8s.obj.service.2](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.obj.service.2.jpg "k8s.obj.service.2")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.obj.service.2.jpg "k8s.obj.service.2")

- Labels & Selectors
    - Key/Value pairs associated with Kubernetes objects
    - Used to organize and select subsets of objects
    - Attached to objects at creation time but modified at any time
    - Labels are the essential glue to associated one API object with other
        - Replication Controller Pods
        - Service Pods
        - Pods Nodes

- kube-proxy
    - The Kubernetes network proxy runs on each node
    - This reflects services as defined in the Kubernetes API on each node and can do simple TCP,UDP stream forwarding or round robin TCP,UDP forwarding across a set of backends
    - Service cluster ips and ports are currently found through Docker-links-compatible environment variables specifying ports opened by the service proxy
    - There is an optional addon that provides cluster DNS for these cluster Ips
    - The user must create a service with the apiserver API to configure the proxy
    - Proxy mode:
        - Userspace:
            - For each Service it opens a port (randomly chosen) on the local node
            - Any connections to this “proxy port” will be proxied to one of the Service’s backend Pods
        - IPtables:
            - For each Service it installs iptables rules which capture traffic to the Service’s clusterIP (which is virtual) and Port and redirects that traffic to one of the Service’s backend sets
            - For each Endpoints object it installs iptables rules which select a backend Pod

- Discovering services: supports 2 primary modes of finding a Service - environment variables and DNS
    - Environment variables: When a Pod is run on a Node, the kubelet adds a set of environment variables for each active Service. It supports both Docker links compatible variables and simpler `{SVCNAME}_SERVICE_HOST` and `{SVCNAME}_SERVICE_PORT` variables , where the Service name is upper-cased and dashes are converted to underscores
    - **DNS**
        - 1.3版本之前, 称之为skydns；1.3版本之后, 称之为kube_dns
        - An optional (though strongly recommended) cluster add-on is a DNS server
        - The DNS server watches the Kubernetes API for new Services and creates a set of DNS records for each
        - If DNS has been enabled throughout the cluster then all Pods should be able to do name resolution of Services automatically

- Network
    - Cilium
    - OVN (Open Virtual Networking)
    - Calico
    - Romana
    - Flannel
    - OVS
    - Open Contrail
    - Cisco Contiv

- Kubernetes Objects
    - are persistent entities in the Kubernetes system
    - Kubernetes uses these entities to represent the state of your cluster
    - Specifically, they can describe:
        - What containerized applications are running (and on which nodes)
        - The resources available to those applications
        - The policies around how those applications behave, such as restart policies, upgrades, and fault-tolerance
    A Kubernetes object is a "record of intent" –- once you create the object, the Kubernetes system will constantly work to ensure that object exists
    - By creating an object, you’re effectively telling the Kubernetes system what you want your cluster’s workload to look like; this is your cluster’s desired state
    - To work with Kubernetes objects – whether to create, modify, or delete them – you’ll need to use the Kubernetes API
    - When you use the kubectl command-line interface, for example, the CLI makes the necessary Kubernetes API calls for you; you can also use the Kubernetes API directly in your own programs
    - Every Kubernetes object includes two nested object fields that govern the object’s configuration: the object **spec** and the object **status**
        - The spec, which you must provide, describes your desired state for the object the characteristics that you want the object to have
        - The status describes the actual state for the object, and is supplied and updated by the Kubernetes system
    - At any given time, the Kubernetes Control Plane actively manages an object’s actual state to match the desired state you supplied
    - Most often, you provide the information to kubectl in a .yaml file. kubectl converts the information to JSON when making the API request: [k8s核心yml--Pod、Deployment、Service](https://cloud.tencent.com/developer/article/1462777 "k8s核心yml--Pod、Deployment、Service")

## deployment实例

- https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod

```yml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

## service 实例

```yml
apiVersion: extensions/v1beta1
kind: Service
matadata:
  name: nginx-service
spec:
  ports:
  - name: http
    protocol: tcp
    port: 80
    targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer
```
