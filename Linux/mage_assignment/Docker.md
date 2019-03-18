# Docker

## LXC

- 虚拟化和容器的区别
[![virtualization_vs_container](https://github.com/Minions1128/net_tech_notes/blob/master/img/virtualization_vs_container.jpg "virtualization_vs_container")](https://github.com/Minions1128/net_tech_notes/blob/master/img/virtualization_vs_container.jpg "virtualization_vs_container")

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

- 容器体系架构

[![lxc_architecture](https://github.com/Minions1128/net_tech_notes/blob/master/img/lxc_architecture.jpg "lxc_architecture")](https://github.com/Minions1128/net_tech_notes/blob/master/img/lxc_architecture.jpg "lxc_architecture")

- 简单使用：
    - lxc-checkconfig：检查系统环境是否满足容器使用要求；
    - lxc-create：创建lxc容器；
        - lxc-create -n NAME -t TEMPLATE_NAME
    - lxc-start：启动容器；
        - lxc-start -n NAME -d
    - lxc-info：查看容器相关的信息；
        - lxc-info -n NAME
    - lxc-console：附加至指定容器的控制台；
        - lxc-console -n NAME -t NUMBER
    - lxc-stop：停止容器；
    - lxc-destory：删除处于停机状态的容器；
    - lxc-snapshot：创建和恢复快照；

- WebGUI: lxc-webpanel
    - http://lxc-webpanel.github.io/
    - yum install python-flask
    - git clone https://github.com/lxc-webpanel/LXC-Web-Panel.git
    - python LXC-Web-Panel/lwp.py


- Linux Containers have emerged as a key open source application packaging and delivery technology, combining lightweight application isolation with the flexibility of image-based deployment methods.

- CentOS 7 implements Linux Containers using core technologies such as Control Groups (Cgroups) for Resource Management, Namespaces for Process Isolation, SELinux for Security, enabling secure multitenancy and reducing the potential for security exploits.


## Docker

### 体系结构

- docker中的容器: lxc -> libcontainer -> runC
    - runC is a CLI tool for spawning and running containers according to the OCI(Open Container Initiative) specification
    - Containers are started as a child process of runC and can be embedded into various other systems without having to run a daemon
    - runC is built on libcontainer, the same container technology powering millions of Docker Engine installations.

- Docker体系结构
    - Client <--> Daemon <--> Registry Server
    - The Docker Client
        - The Docker client (docker) is the primary way that many Docker users interact with Docker.
        - The docker command uses the Docker API.
    - The Docker Daemon
        - The Docker daemon (dockerd) listens for Docker API requests and manages Docker objects such as images, containers, networks, and volumes(外部的持久存储).
    - Docker Registries
        - A Docker registry stores Docker images.
        - **Docker Hub** and **Docker Cloud** are public registries that anyone can use, and Docker is configured to look for images on Docker Hub by default.
        - You can even run your own private registry.

[![docker.architecture](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.architecture.jpg "docker.architecture")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.architecture.jpg "docker.architecture")

- Docker逻辑组件
    - Containers：容器
    - Images：镜像
    - Registry：Image Repositories

- When you use Docker, you are creating and using images, containers, networks, volumes, plugins, and other objects.
    - IMAGES
        - An image is a read-only template with instructions for creating a Docker container.
        - Often, an image is based on another image, with some additional customization.
        - You might create your own images or you might only use those created by others and published in a registry.
    - CONTAINERS
        - A container is a runnable instance of an image.
        - You can create, run, stop, move, or delete a container using the Docker API or CLI.
        - You can connect a container to one or more networks, attach storage to it, or even create a new image based on its current state.


### 安装docker

- 依赖的基础环境
    - 64 bits CPU
    - Linux Kernel 3.10+
    - Linux Kernel cgroups and namespaces
- Docker Client：`docker [OPTIONS] COMMAND [arg...]`
- 启动Docker Daemon：`systemctl start docker.service`
- 查看docker相关的信息：
    - docker version
    - docker info
- Registry选项：
    - 配置文件在：`/etc/sysconfig/docker`
    - `ADD_REGISTRY='--add-registry registry.ifeng.com --add-registry registry.ifengidc.com'`：添加其他仓库
    - `BLOCK_REGISTRY='--block-registry docker.io'`：防止用户在docker的registry拉镜像
    - `INSECURE_REGISTRY='--insrcure-registry'`：允许使用非安全协议
- Docker event state

[![docker.event.state](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.event.state.jpg "docker.event.state")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.event.state.jpg "docker.event.state")

### 相关命令

- 镜像
    - images
    - rmi
    - pull

- 容器：
    - run：创建并运行一个容器；
    - create：创建一个容器；
    - start：启动一个处于停止状态容器；

- ps：List containers

- 容器的状态切换命令
    - created：
        - create
        - run
    - runing
        - start
    - paused and continue
        - pause
        - unpause
    - stopped
        - kill
        - stop
    - deleted
        - rm
        - run --rm
    - restart：
        - restart

- 创建容器：
    - 基于“镜像文件”，镜像文件有默认要运行的程序；
    - 注意：
        - 运行的容器内部必须有一个**工作前台**的运行的进程；
        - docker的容器的通常也是仅为运行一个程序；
            - 要想在容器内运行多个程序，一般需要提供一个管控程序，例如supervised。
    - run, create的选项
        - --name CT_NAME
        - --rm：容器运行终止即自行删除
        - --network BRIDGE：让容器加入的网络；默认为docker0；
        - 交互式启动一个容器：
            - -i：--interactive，交互式；
            - -t：Allocate a pseudo-TTY
            - 从终端拆除：ctrl+p, ctrl+q
            - attach：附加至某运行状态的容器的终端设备；
            - exec：让运行中的容器运行一个额外的程序；
        
- 查看：
    - logs：Fetch the logs of a container，容器内部程序运行时输出到终端的信息；
        - 例如：`docker logs CONTAINER-NAME`
    - ps：List containers
        - -a, --all：列出所有容器；
        - -f, --filter：过滤器条件显示
            - name=CONTAINER-NAME
            - status={stopped|running|paused}
    - stats：动态方式显示容器的资源占用状态；
    - top：Display the running processes of a container
        - `docker top CONTAINER-NAME`

### Docker Images

[![docker.image.layer](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.image.layer.jpg "docker.image.layer")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.image.layer.jpg "docker.image.layer")

- Docker镜像含有启动容器所需要的文件系统及其内容，因此，其用于创建并启动docker容器采用分层构建机制，称之为联合挂载，最底层为bootfs，其之为rootfs
    - bootfs：用于系统引导的文件系统，包括bootloader和kernel，容器启动完成后会被卸载以节约内存资源；
    - rootfs：位于bootfs之上，表现为docker容器的根文件系统;
        - 传统模式中，系统启动之时，内核挂载rootfs时会首先将其挂载为“只读”模式，完整性自检完成后将其重新挂载为读写模式；
        - docker中，rootfs由内核挂载为“只读”模式，而后通过“联合挂载 ”技术额外挂载一个“可写”层；
        - 位于下层的镜像称为父镜像(parent image)，最底层的称为基础镜像(base image)
        - 最上层为“可读写”层，其下的均为“只读”层

- Docker目前支持的联合文件系统种类包括AUFS、Btrfs、VFS和DeviceMapper等。
    - AUFS, Aadvanced multi-layered Unification FileSystem, 高级多层统一文件系统，在Ubuntu上默认使用aufs
    - Devicemapper：在CentOS7上使用的是devicemapper，

- Docker Registry：a stateless, highly scalable server side application that stores and lets you distribute Docker images.
    - 启动容器时，docker daemon会试图从本地获取相关的镜像；本地镜像不存在时，其将从Registry中下载该镜像并保存到本地
    - 分类：
        - Docker Hub
        - Sponsor Registry：第三方的registry，供客户和Docker社区使用
        - Mirror Registry：第三方的registry，只让客户使用
        - Vendor Registry：由发布Docker镜像的供应商提供的registry
        - Private Registry：通过设有防火墙和额外的安全层的私有实体提供的registry
    - Repository：由某特定的docker镜像的所有迭代版本组成的镜像仓库
        - 一个 Registry中可以存在多个Repository
            - Repository可分为“顶层仓库”和“用户仓库”
            - 用户仓库名称格式为“用户名/仓库名”
        - 每个仓库可以包含多个Tag(标签) ，每个标签对应一个镜像
    - Index
        - 维护用户帐户、镜像的校验以及公共命名空间的信息
        - 相当于为Registry提供了一个完成用户认证等功能的检索接口

| 请求镜像 | 部署流程 |
| :------------: | :------------: |
| [![docker.registry.1](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.registry.1.jpg "docker.registry.1")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.registry.1.jpg "docker.registry.1") | [![docker.registry.2](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.registry.2.jpg "docker.registry.2")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.registry.2.jpg "docker.registry.2") |

- docker hub:
    - docker login [OPTIONS] [SERVER]
        - --password, -p: Password
        - --password-stdin: Take the password from stdin
        - --username, -u: Username
    - docker logout [SERVER]
    - docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
        - docker tag 0e5574283393 myregistryhost:5000/fedora/httpd:version1.0
    - docker push [OPTIONS] NAME[:TAG]
    - docker pull [OPTIONS] NAME[:TAG|@DIGEST]

- 镜像制作：
    - 基于容器制作：在容器中完成操作后制作；
        - docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]
            - --author, -a: Author (e.g., “John Hannibal Smith hannibal@a-team.com”)
            - --message, -m: Commit message
            - --pause, -p: Pause container during commit, default is true.
            - --change, -c: Apply Dockerfile instruction to the created image
    - 基于镜像制作：编辑一个Dockerfile，而后根据此文件制作；

[![docker.make.image](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.make.image.jpg "docker.make.image")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.make.image.jpg "docker.make.image")
          
- 将镜像文件导出为tar文件:
            docker save
                Save one or more images to a tar archive (streamed to STDOUT by default)
                
                docker save [OPTIONS] IMAGE [IMAGE...]
                
                
        从tar文件导入镜像 ：
            docker load 
                Load an image from a tar archive or STDIN
                
                docker load [OPTIONS]
                
                    --input, -i     Read from tar archive file, instead of STDIN
                    --quiet, -q false   Suppress the load output                

Docker private Registry的Nginx反代配置方式：
```
        client_max_body_size 0;

        location / {
            proxy_pass  http://registrysrvs;
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_redirect off;
            proxy_buffering off;
            proxy_set_header        Host            $host;
            proxy_set_header        X-Real-IP       $remote_addr;
            proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
            auth_basic "Docker Registry Service";
            auth_basic_user_file "/etc/nginx/.ngxpasswd";
        }
        
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