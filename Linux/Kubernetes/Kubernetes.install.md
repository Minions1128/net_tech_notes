# Kubernetes 安装

- 使用kubeadm安装部署kubernetes集群

### 准备工作

- 各节点时间同步;
- 各节点主机名称解析: dns OR hosts;
- 各节点 iptables 及 firewalld 服务被 disable;
- 网络可以访问到海外资源

### 设置各节点安装程序包

```sh
# 获取docker-ce的配置仓库配置文件
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo \
    -O /etc/yum.repos.d/docker-ce.repo

# 生成kubernetes的yum仓库配置文件/etc/yum.repos.d/kubernetes.repo
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
enabled=1
EOF

# 安装相关的程序包
yum install docker-ce kubelet kubeadm kubectl -y
```

### 初始化 master 节点

```sh
# 启动docker
systemctl start docker.service

# 编辑kubelet的配置文件/etc/sysconfig/kubelet，设置其忽略Swap启用的状态错误
KUBELET_EXTRA_ARGS="--fail-swap-on=false"

# 设定docker和kubelet开机自启动
systemctl enable docker kubelet

echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables

# 初始化master节点
kubeadm init --pod-network-cidr=10.244.0.0/16 \
    --service-cidr=10.96.0.0/12 \
    --ignore-preflight-errors=Swap

# 请记录最后的kubeadm join命令的全部内容

# 初始化kubectl
mkdir ~/.kube
cp /etc/kubernetes/admin.conf ~/.kube/
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
source ~/.bash_profile

# 检查kube-scheduler.yaml, kube-controller-manager.yaml配置是否禁用了非安全端口
egrep "\-\-port=0" /etc/kubernetes/manifests/kube-scheduler.yaml
egrep "\-\-port=0" /etc/kubernetes/manifests/kube-controller-manager.yaml

# 测试
kubectl get componentstatus

# 添加flannel网络附件
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 验正master节点已经就绪
kubectl get nodes
kubectl get po -n kube-system
```

### 添加nodes节点到集群中

```sh
# 启动docker
systemctl start docker.service

# 编辑kubelet的配置文件/etc/sysconfig/kubelet, 设置其忽略Swap启用的状态错误
KUBELET_EXTRA_ARGS="--fail-swap-on=false"

# 设定docker和kubelet开机自启动
systemctl enable docker kubelet

# 将之前记录的kubeadm join在node节点上执行要附加“--ignore-preflight-errors=Swap”
kubeadm join 10.207.0.10:6443 --token bbbbbb.eeeee \
    --discovery-token-ca-cert-hash sha256:aaaaaaa \
    --ignore-preflight-errors=Swap

# 最后在master节点上验证
kubectl get nodes
kubectl get po -n kube-system -o wide
```
