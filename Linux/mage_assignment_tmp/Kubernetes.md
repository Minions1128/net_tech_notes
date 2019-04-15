# Kubernetes

## 容器编排三组解决方案

- Docker容器编排三剑客
    - docker-machine：管理docker各个节点
    - docker-swarm：管理容器集群，监控容器
    - docker-compose：实现编排
- ASF：mesos（资源调框架，IDC操作系统），marathon（编排容器）
- Google：Kubernetes

## 简介

- Kubernetes is an open source system for managing containerized applications across multiple hosts, providing basic mechanisms for deployment, maintenance, and scaling of applications.

- Kubernetes Cluster: A running Kubernetes cluster contains node agents (kubelet) and a cluster control plane (AKA master), with cluster state backed by a distributed storage system (etcd)

[![k8s.cluster](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.cluster.jpg "k8s.cluster")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.cluster.jpg "k8s.cluster")

- 架构：master/agent

[![k8s.arch.view](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.arch.view.jpg "k8s.arch.view")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.arch.view.jpg "k8s.arch.view")

- master主机：
    - kube-API Server: Kubernetes API server
    - kubu-scheduler: Schedules pods in worker nodes
    - kube-controller-manager: 监控部署的容器是否够用
    - etcd(golang): A metadata service, distributed key-value store (zookeeper)

[![k8s.master](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.master.jpg "k8s.master")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.master.jpg "k8s.master")

- agent主机（node）：
    - kubelet: Container Agent
    - container runtime(docker/rkt/...)
    - kube-proxy: A load balancer for Pods
    - supervisord: 
    - Pod: A group of Containers, pods之间为joined container.
    - Addons: 附件
    - fluentd: 日志收集工具

[![k8s.node](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.node.jpg "k8s.node")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.node.jpg "k8s.node")

[![k8s.arch](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.arch.jpg "k8s.arch")](https://github.com/Minions1128/net_tech_notes/blob/master/img/k8s.arch.jpg "k8s.arch")


Key Concepts of Kubernetes
v Labels - Labels for identifying pods



v cAdvisor - Container Advisor providers resource usage/performance statistics
v Replication Controller - Manages replication of pods




```
Kubernetes Cluster：
    环境：
        master, etcd：172.18.0.67
        node1：172.18.0.68
        node2：172.18.0.69
    前提：
        1、基于主机名通信：/etc/hosts；
        2、时间同步；
        3、关闭firewalld和iptables.service；
        
        OS：CentOS 7.3.1611, Extras仓库中；
        
安装配置步骤：
        1、etcd，仅master节点；
        2、flannel，集群的所有节点；
        3、配置k8s的master：仅master节点；
            kubernetes-master
            启动的服务：
                kube-apiserver, kube-scheduler, kube-controller-manager
        4、配置k8s的各Node节点；
            kubernetes-node 
            
            先设定启动docker服务；
            启动的k8s的服务：
                kube-proxy, kubelet
                
        http://www.cnblogs.com/zhenyuyaodidiao/p/6500830.html
        https://xuxinkun.github.io/2016/07/18/flannel-docker/
```