# LXC

- LXC is a userspace interface for the Linux kernel containment features.

- Current LXC uses the following kernel features to contain processes
    - Kernel namespaces (ipc, uts(主机名和域名), mount, pid, network and user)
    - Apparmor(app-armor) and SELinux profiles
    - Seccomp policies
    - Chroots (using pivot_root)
    - Kernel capabilities
    - CGroups (control groups)

- LXC containers are often considered as something in the middle between a chroot and a full fledged virtual machine.

- The goal of LXC is to create an environment as close as possible to a standard Linux installation but without the need for a separate kernel.

- 虚拟化和容器的区别
[![virtualization_vs_container](https://github.com/Minions1128/net_tech_notes/blob/master/img/virtualization_vs_container.jpg "virtualization_vs_container")](https://github.com/Minions1128/net_tech_notes/blob/master/img/virtualization_vs_container.jpg "virtualization_vs_container")

- 容器体系架构

[![lxc_architecture](https://github.com/Minions1128/net_tech_notes/blob/master/img/lxc_architecture.jpg "lxc_architecture")](https://github.com/Minions1128/net_tech_notes/blob/master/img/lxc_architecture.jpg "lxc_architecture")

- 简单使用:
    - lxc-checkconfig: 检查系统环境是否满足容器使用要求;
    - lxc-create: 创建lxc容器;
        - lxc-create -n NAME -t TEMPLATE_NAME
    - lxc-start: 启动容器;
        - lxc-start -n NAME -d
    - lxc-info: 查看容器相关的信息;
        - lxc-info -n NAME
    - lxc-console: 附加至指定容器的控制台;
        - lxc-console -n NAME -t NUMBER
    - lxc-stop: 停止容器;
    - lxc-destory: 删除处于停机状态的容器;
    - lxc-snapshot: 创建和恢复快照;

- WebGUI: lxc-webpanel
```sh
# http://lxc-webpanel.github.io
yum install python-flask
git clone https://github.com/lxc-webpanel/LXC-Web-Panel.git
python LXC-Web-Panel/lwp.py
```

- Linux Containers have emerged as a key open source application packaging and delivery technology, combining lightweight application isolation with the flexibility of image-based deployment methods.

- CentOS 7 implements Linux Containers using core technologies such as Control Groups (Cgroups) for Resource Management, Namespaces for Process Isolation, SELinux for Security, enabling secure multitenancy and reducing the potential for security exploits.
