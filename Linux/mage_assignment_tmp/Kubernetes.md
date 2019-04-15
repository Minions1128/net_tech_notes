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
- Kubernetes builds upon a decade and a half of experience at Google running production workloads at scale using a system called Borg, combined with best-of-breed ideas and practices from the community.

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
