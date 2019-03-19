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

- [Docker reference documentation](https://docs.docker.com/reference/ "Docker reference documentation")

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
    - docker inspect：显示docker详细信息

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

- 镜像的导入导出：
    - 将镜像文件导出为tar文件:
        - docker save: Save one or more images to a tar archive (streamed to STDOUT by default)
        - `docker save [OPTIONS] IMAGE [IMAGE...]`
    - 从tar文件导入镜像：
        - docker load: Load an image from a tar archive or STDIN
        - `docker load [OPTIONS]`
            - --input, -i: Read from tar archive file, instead of STDIN
            - --quiet, -q: Suppress the load output

### Docker Data Volumes

- 写时复制(COW)：
    - Docker镜像由多个只读层叠加而成，启动容器时，Docker会加载只读镜像层并在镜像栈顶部添加一个读写层
    - 如果运行中的容器修改了现有的一个已经存在的文件，那该文件将会从读写层下面的只读层复制到读写层，该文件的只读版本仍然存在，只是已经被读写层中该文件的副本所隐藏
    - 关闭并重启容器，其数据不受影响；但删除Docker容器，则其更改将会全部丢失
    - 存在的问题：
        - 存储于联合文件系统中，不易于宿主机访问；
        - 容器间数据共享不便
        - 删除容器其数据会丢失
    - 解决方案：“卷(volume)”: 

[![docker.cow](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.cow.jpg "docker.cow")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.cow.jpg "docker.cow")

- “卷”是容器上的一个或多个“目录”，此类目录可绕过联合文件系统，与宿主机上的某目录“绑定(关联)”
    - 删除容器之时既不会删除卷，也不会对哪怕未被引用的卷做垃圾回收操作；
    - 可以把“镜像”想像成静态文件，例如“程序”，把卷类比为动态内容，例如“数据”；于是，镜像可以重用，而卷可以共享；卷实现了“程序(镜像)”和“数据(卷)”分离，以及“程序(镜像)”和“制作镜像的主机”分离，用户制作镜像时无须再考虑镜像运行的容器所在的主机的环境；

[![docker.volumes.proc](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.volumes.proc.jpg "docker.volumes.proc")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.volumes.proc.jpg "docker.volumes.proc")

- 两种类型的卷：
    - Bind mount volume： a volume that points to a user-specified location on the host file system.
    - Docker-managed volume： the Docker daemon creates managed volumes in a portion of the host’s file system that’s owned by Docker, e.g.. `var/lib/docker/volumes`
    - 在docker run是，使用`--volume, -v {HOSTDIR:VOLUMERDIR | HOSTDIR}`选项指定
    - docker volume list: 列出现在已有的卷

- Sharing volumes: There are two ways to share volumes between containers.
    - 多个容器的卷使用同一个主机目录，例如
        ```
        ~]# docker run –it --name c1 -v /docker/volumes/v1:/data busybox
        ~]# docker run –it --name c2 -v /docker/volumes/v1:/data busybox
        ```
    - 复制使用其它容器的卷，为docker run命令使用--volumes-from选项
        ```
        ]# docker run -it --name bbox1 -v /docker/volumes/v1:/data busybox
        ]# docker run -it --name bbox2 --volumes-from bbox1 busybox
        ```
- 删除卷
    - 删除容器之时删除相关的卷：为docker rm命令使用-v选项
    - 删除指定的卷：`docker volume rm`

### Docker网络

- Docker is concerned with two types of networking:
    - single-host virtual networks: provide container isolation
    - multi-host networks: provide an overlay where any container on a participating host can have its own routable IP address from any other container in the network.

[![docker.network.4.archetypes](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.network.4.archetypes.jpg "docker.network.4.archetypes")](https://github.com/Minions1128/net_tech_notes/blob/master/img/docker.network.4.archetypes.jpg "docker.network.4.archetypes")

- Docker安装完成后，会自动创建三个网络，可使用“docker network ls”命令查看。创建容器时，可为docker run命令使用--network选项指定要加入的网络
    - host: 相当于是Open container，直接使用宿主机网络资源
    - none：不参与网络通信，运行于此类容器中的进程仅能访问本地环回接口，仅适用于进程无须网络通信的场景中，例如备份、进程诊断及各种离线任务等
        - `]# docker run --rm --net none busybox:latest ifconfig -a`
    - bridge: represents the docker0 network present in all Docker installations
        - `]# docker run --rm --net bridge busybox:latest ifconfig -a`
        - --dns DNS_SERVER_IP”选项能够为容器指定所使用的dns服务器地址，例如
            - `]# docker run --rm --dns 172.16.0.1 busybox:latest nslookup docker.com`
        - --add-host HOSTNAME:IP”选项能够为容器指定本地主机名解析项，例如
            - `]# docker run --rm --dns 172.16.0.1 --add-host "docker.com:172.16.0.100" busybox:latest nslookup docker.com`

- Joined containers: 指使用某个已存在容器的网络接口的容器，接口被联盟内的各容器共享使用；因此，联盟式容器彼此间完全无隔离，
    - 例如: 
        - 创建一个监听于2222端口的http服务容器
            - `]# docker run -d -it --rm -p 2222 busybox:latest /bin/httpd -p 2222 -f`
        - 创建一个联盟式容器，并查看其监听的端口
            - `]# docker run -it --rm --net container:web --name joined busybox:latest netstat -tan`
    - 联盟式容器彼此间虽然共享同一个网络名称空间，但其它名称空间如User、Mount等还是隔离的
    - 联盟式容器彼此间存在端口冲突的可能性，因此，通常只会在多个容器上的程序需要程序loopback接口互相通信、或对某已存的容器的网络属性进行监控时才使用此种模式的网络模型

- 开放容器或其上的服务为外部网络访问，需要在宿主机上为其定义DNAT规则，例如
    - 对宿主机某IP地址的访问全部映射给某容器地址
        - 主机IP 容器IP
            - -A PREROUTING -d 主机IP -j DNAT --to-destination 容器IP
    - 对宿主机某IP地址的某端口的访问映射给某容器地址的某端口
        - 主机IP:PORT 容器IP:PORT
            - -A PREROUTING -d 主机IP -p {tcp|udp} --dport 主机端口 -j DNAT --to-destination容器IP:容器端口

- 为docker run命令使用-p选项即可实现端口映射，无须手动添加规则
    - -p选项的使用格式
        - -p <containerPort>: 将指定的容器端口映射至主机所有地址的一个动态端口
        - -p <hostPort>:<containerPort>: 将容器端口<containerPort>映射至指定的主机端口<hostPort>
        - -p <ip>::<containerPort>: 将指定的容器端口<containerPort>映射至主机指定<ip>的动态端口
        - -p <ip>:<hostPort>:<containerPort>: 将指定的容器端口<containerPort>映射至主机指定<ip>的端口<hostPort>
    - v `-P`选项或`--publish-all`将容器的所有计划要暴露端口全部映射至主机端口

- 如果不想使用默认的docker0桥接口，或者需要修改此桥接口的网络属性，可通过为docker daemon命令使用-b、--bip、--fixed-cidr、--default-gateway、--dns以及--mtu等选项进行设定

- 创建docker网络：https://docs.docker.com/engine/reference/commandline/network_create/
    - create
        - bridge
        - overlay
    - connect
    - disconnect

### Dockerfile

- Dockerfile is nothing but the source code for building Docker images
    - Docker can **build images** automatically by reading the instructions from a Dockerfile
    - A Dockerfile is a text document that contains all the commands a user could call on the command line to assemble an image
    - Using docker build users can create an automated build that executes several command-line instructions in succession

- Dockerfile Format
    - 组成
        - `# Comment`
        - INSTRUCTION arguments
    - The instruction is not case-sensitive. However, convention is for them to be UPPERCASE to distinguish them from arguments more easily
    - Docker runs instructions in a Dockerfile in order
    - The first instruction must be `FROM` in order to specify the Base Image from which you are building

- Environment replacement
    - Environment variables (declared with the ENV statement) can also be used in certain instructions as variables to be interpreted by the Dockerfile
    - Environment variables are notated in the Dockerfile either with `$variable_name` or `${variable_name}`
    - The `${variable_name}` syntax also supports a few of the standard bash modifiers（bash修饰符）
        - `${variable:-word}` indicates that if variable is set then the result will be that value. If variable is not set then word will be the result.
        - `${variable:+word}` indicates that if variable is set then word will be the result, otherwise the result is the empty string.

- .dockerignore file
    - Before the docker CLI sends the context to the docker daemon, it looks for a file named .dockerignore in the root directory of the context
    - If this file exists, the CLI modifies the context to exclude files and directories that match patterns in it
    - The CLI interprets the .dockerignore file as a newline-separated list of patterns similar to the file globs of Unix shells

- Dockerfile Instructions
    - FROM:
        - FROM指令是最重的一个且必须为Dockerfile文件开篇的第一个非注释行，用于为映像文件构建过程指定基准镜像，后续的指令运行于此基准镜像所提供的运行环境
        - 实践中，基准镜像可以是任何可用镜像文件，默认情况下，docker build会在docker主机上查找指定的镜像文件，在其不存在时，则会从Docker Hub Registry上拉取所需的镜像文件
            - 如果找不到指定的镜像文件，docker build会返回一个错误信息
        - Syntax
            - `FROM <image>[:<tag>]` 或
            - `FROM <image>@<digest>`
                - `<image>`：指定作为base image的名称；
                - `<tag>`：base image的标签，为可选项，省略时默认为latest；
    - MAINTANIER
        - 用于让镜像制作者提供本人的详细信息
        - Dockerfile并不限制MAINTAINER指令可在出现的位置，但推荐将其放置于FROM指令之后
        - Syntax
            - `MAINTAINER <authtor's detail>`，`<author's detail>`可是任何文本信息，但约定俗成地使用作者名称及邮件地址
    - COPY
        - 用于从Docker主机复制文件至创建的新映像文件
        - Syntax
            - `COPY <src> ... <dest>` 或
            - `COPY ["<src>",... "<dest>"]`
                - `<src>`：要复制的源文件或目录，支持使用通配符
                - `<dest>`：目标路径，即正在创建的image的文件系统路径；建议为`<dest>`使用绝对路径，否则，COPY指定则以WORKDIR为其起始路径；
            - 注意：在路径中有空白字符时，通常使用第二种格式
        - 文件复制准则
            - `<src>`必须是build上下文中的路径，不能是其父目录中的文件
            - 如果`<src>`是目录，则其内部文件或子目录会被递归复制，但`<src>`目录自身不会被复制
            - 如果指定了多个`<src>`，或在`<src>`中使用了通配符，则`<dest>`必须是一个目录，且必须以/结尾
            - 如果`<dest>`事先不存在，它将会被自动创建，这包括其父目录路径






































---

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
