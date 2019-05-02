# Linux程序包管理
    
## 概述

- API：Application Program Interface
- ABI：Application Binary Interface
    - Unix-like: ELF
    - Windows: exe, msi
                    
- 库级别的虚拟化
    - Linux: WinE
    - Windows: Cywin

- 研发的一般分类
    - 系统级开发：C/C++：httpd, vsftpd, nginx; go
        - C/C++程序格式：
            - 源代码：文本格式的程序代码；
                - 编译开发环境：编译器、头文件、开发库
            - 二进制格式：文本格式的程序代码 --> 编译器 --> 二进制格式（二进制程序、库文件、配置文件、帮助文件）
            - 项目构建工具：make
    - 应用级开发：java/Python/perl/ruby/php：
        - java: hadoop,  hbase, (jvm)
        - Python：openstack, (pvm)
            - java/python程序格式：
                - 源代码：编译成能够在其虚拟机(jvm/pvm)运行的格式；
                    - 开发环境：编译器、开发库
                - 二进制
            - 项目构建工具：maven
        - perl: (perl)
        - ruby: (ruby)
        - php: (php)

## 程序包管理器

- 作用：源代码 --> 目标二进制格式（二进制程序、库文件、配置文件、帮助文件） --> 组织成为一个或有限几个“包”文件；协助用户完成安装、升级、卸载、查询、校验

- 种类
    - debian：dpt, dpkg, ".deb"
    - redhat：redhat package manager, rpm, ".rpm"； rpm is package manager；
    - S.u.S.E：rpm, ".rpm",
    - Gentoo：ports
    - ArchLinux：

- 源代码：name-VERSION.tar.gz
    - VERSION：major.minor.release

- rpm包命名格式：name-VERSION-release.arch.rpm
    - VERSION：major.minor.release
    - release.arch：rpm包的发行号: 
        - release.os: 2.el7.i386.rpm
        - archetecture：i386, x64(amd64), ppc, noarch(平台无关)
    - 例如：redis-3.0.2.tar.gz --> redis-3.0.2-1.centos7.x64.rpm
    - 拆包：主包和支包
        - 主包：name-VERSION-release.arch.rpm
        - 支包：name-function-VERSION-release.arch.rpm
            - function：devel, utils, libs, ...

- 自动解决依赖关系的前端工具
    - yum：rhel系列系统上rpm包管理器的前端工具；
    - apt-get (apt-cache)：deb包管理器的前端工具；
    - zypper：suse的rpm管理器前端工具；
    - dnf：Fedora 22+系统上rpm包管理器的前端工具；

- 程序包的组成格式
    - 1、程序包的组成清单（每个程序包都单独实现）；
        - 文件清单
        - 安装或卸载时运行的脚本
    - 2、数据库（公共）
        - 程序包的名称和版本；
        - 依赖关系；
        - 功能说明；
        - 安装生成的各文件的文件路径及校验码信息；
        - centos存储数据库的路径：/var/lib/rpm/

- 获取程序包的途径：
    - (1) 系统发行版的光盘或官方的文件服务器（或镜像站点）：
        - http://mirrors.aliyun.com, 
        - http://mirrors.sohu.com,
        - http://mirrors.163.com 
    - (2) 项目的官方站点
    - (3) 第三方组织：
        - (a) EPEL
        - (b) 搜索引擎
            - http://pkgs.org
            - http://rpmfind.net 
            - http://rpm.pbone.net 
    - (4) 自动动手，丰衣足食
    - 下载完成后的建议：检查其合法性
        - 来源合法性；
        - 程序包的完整性；

## CentOS系统上rpm命令管理程序包

- rpm命令：rpm  [OPTIONS]  [PACKAGE_FILE]
    - 安装：-i, --install
    - 升级：-U, --update, -F, --freshen
    - 卸载：-e, --erase
    - 查询：-q, --query
    - 校验：-V, --verify
    - 数据库维护：--builddb, --initdb

- 安装：
    - rpm {-i|--install} [install-options] PACKAGE_FILE ...
    - rpm  -ivh  PACKAGE_FILE ...
        - GENERAL OPTIONS：
            - -v：verbose，详细信息
            - -vv：更详细的输出
        - [install-options]：
            - -h：hash marks输出进度条；每个#表示2%的进度；
            - --test：测试安装，检查并报告依赖关系及冲突消息等；
            - --nodeps：忽略依赖关系；不建议；
            - --replacepkgs：重新安装
            - 注意：rpm可以自带脚本；有四类：--noscripts
                - preinstall：安装过程开始之前运行的脚本，%pre ， --nopre
                - postinstall：安装过程完成之后运行的脚本，%post , --nopost
                - preuninstall：卸载过程真正开始执行之前运行的脚本，%preun, --nopreun 
                - postuninstall：卸载过程完成之后运行的脚本，%postun , --nopostun
            - --nosignature：不检查包签名信息，不检查来源合法性；
            - --nodigest：不检查包完整性信息；

- 升级：
    - rpm {-U|--upgrade} [install-options] PACKAGE_FILE ...
    - rpm {-F|--freshen} [install-options] PACKAGE_FILE ...
    - rpm  -Uvh PACKAGE_FILE ...
    - rpm  -Fvh PACKAGE_FILE ...
    - options:
        - -U：升级或安装；
        - -F：升级
        - --oldpackage：降级；
        - --force：强制升级；
    - 注意：
        - (1) 不要对内核做升级操作；Linux支持多内核版本并存，因此，直接安装新版本内核；
        - (2) 如果某原程序包的配置文件安装后曾被修改过，升级时，新版本的程序提供的同一个配置文件不会覆盖原有版本的配置文件，而是把新版本的配置文件重命名(FILENAME.rpmnew)后提供；

- 卸载：
    - rpm {-e|--erase} [--allmatches] [--nodeps] [--noscripts] [--test] PACKAGE_NAME ...
    - 选项：
        - --allmatches：卸载所有匹配指定名称的程序包的各版本；
        - --nodeps：忽略依赖关系
        - --test：测试卸载，dry run模式

- 查询：
    - rpm {-q|--query} [select-options] [query-options]
    - [select-options]
        - PACKAGE_NAME：查询指定的程序包是否已经安装，及其版本；
        - -a, --all：查询所有已经安装过的包；
        - -f  FILE：查询指定的文件由哪个程序包安装生成；
            ```sh
            ~]# rpm -qf /etc/dhcp/dhclient.d/ntp.sh 
            ntp-4.2.6p5-28.el7.centos.x86_64
            ```
        - -p, --package PACKAGE_FILE：用于实现对未安装的程序包执行查询操作；
        - --whatprovides CAPABILITY：查询指定的CAPABILITY由哪个程序包提供；
        - --whatrequires CAPABILITY：查询指定的CAPABILITY被哪个包所依赖；
    - [query-options]
        - --changelog：查询rpm包的changlog；
        - -l, --list：程序安装生成的所有文件列表；
        - -i, --info：程序包相关的信息，版本号、大小、所属的包组，等；
        - -c, --configfiles：查询指定的程序包提供的配置文件；
        - -d, --docfiles：查询指定的程序包提供的文档；
        - --provides：列出指定的程序包提供的所有的CAPABILITY；
        - -R, --requires：查询指定的程序包的依赖关系；
        - --scripts：查看程序包自带的脚本片断；
    - 用法：
        - -qi  PACKAGE, -qf FILE, -qc PACKAGE, -ql PACKAGE, -qd PACKAGE
        - -qpi  PACKAGE_FILE, -qpl PACKAGE_FILE, -qpc PACKAGE_FILE, ...

- 校验：
            rpm {-V|--verify} [select-options] [verify-options] 
                
                
            S file Size differs
            M Mode differs (includes permissions and file type)
            5 digest (formerly MD5 sum) differs
            D Device major/minor number mismatch
            L readLink(2) path mismatch
            U User ownership differs
            G Group ownership differs
            T mTime differs
            P caPabilities differ
            
    包来源合法性验正和完整性验正：
        来源合法性验正：
        完整性验正：
        
        获取并导入信任的包制作者的密钥：
            对于CentOS发行版来说：rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
            
        验正：
            (1) 安装此组织签名的程序时，会自动执行验正；
            (2) 手动验正：rpm -K PACKAGE_FILE
            
    数据库重建：
        rpm管理器数据库路径：/var/lib/rpm/
            查询操作：通过此处的数据库进行；
            
        获取帮助：
            CentOS 6：man rpm
            CentOS 7：man rpmdb
            
            rpm {--initdb|--rebuilddb} [--dbpath DIRECTORY] [--root DIRECTORY]
                --initdb：初始化数据库，当前无任何数据库可实始化创建一个新的；当前有时不执行任何操作；
                --rebuilddb：重新构建，通过读取当前系统上所有已经安装过的程序包进行重新创建；
            
        博客作业：rpm包管理功能全解；

回顾：Linux程序包管理的实现、rpm包管理器

    rpm命令实现程序管理：
        安装：-ivh, --nodeps, --replacepkgs
        卸载：-e, --nodeps
        升级：-Uvh, -Fvh, --nodeps, --oldpackage
        查询：-q, -qa, -qf, -qi, -qd, -qc, -q --scripts, -q --changlog, -q --provides, -q --requires
        校验：-V

        导入GPG密钥：--import, -K, --nodigest, --nosignature
        数据库重建：--initdb, --rebuilddb

Linux程序包管理(2)

    CentOS: yum, dnf

    URL: ftp://172.16.0.1/pub/  

    YUM: yellow dog, Yellowdog Update Modifier

    yum repository: yum repo
        存储了众多rpm包，以及包的相关的元数据文件（放置于特定目录下：repodata）；

        文件服务器：
            ftp://
            http://
            nfs://
            file:///

    yum客户端：
        配置文件：
            /etc/yum.conf：为所有仓库提供公共配置
            /etc/yum.repos.d/*.repo：为仓库的指向提供配置

        仓库指向的定义：
        [repositoryID]
        name=Some name for this repository
        baseurl=url://path/to/repository/
        enabled={1|0}
        gpgcheck={1|0}
        gpgkey=URL
        enablegroups={1|0}
        failovermethod={roundrobin|priority}
            默认为：roundrobin，意为随机挑选；
        cost=
            默认为1000


        教室里的yum源：http://172.16.0.1/cobbler/ks_mirror/CentOS-6.6-x86_64/
        CentOS 6.6 X84_64 epel: http://172.16.0.1/fedora-epel/6/x86_64/

    yum命令的用法：
        yum [options] [command] [package ...]

       command is one of:
        * install package1 [package2] [...]
        * update [package1] [package2] [...]
        * update-to [package1] [package2] [...]
        * check-update
        * upgrade [package1] [package2] [...]
        * upgrade-to [package1] [package2] [...]
        * distribution-synchronization [package1] [package2] [...]
        * remove | erase package1 [package2] [...]
        * list [...]
        * info [...]
        * provides | whatprovides feature1 [feature2] [...]
        * clean [ packages | metadata | expire-cache | rpmdb | plugins | all ]
        * makecache
        * groupinstall group1 [group2] [...]
        * groupupdate group1 [group2] [...]
        * grouplist [hidden] [groupwildcard] [...]
        * groupremove group1 [group2] [...]
        * groupinfo group1 [...]
        * search string1 [string2] [...]
        * shell [filename]
        * resolvedep dep1 [dep2] [...]
        * localinstall rpmfile1 [rpmfile2] [...]
           (maintained for legacy reasons only - use install)
        * localupdate rpmfile1 [rpmfile2] [...]
           (maintained for legacy reasons only - use update)
        * reinstall package1 [package2] [...]
        * downgrade package1 [package2] [...]
        * deplist package1 [package2] [...]
        * repolist [all|enabled|disabled]
        * version [ all | installed | available | group-* | nogroups* | grouplist | groupinfo ]
        * history [info|list|packages-list|packages-info|summary|addon-info|redo|undo|rollback|new|sync|stats]
        * check
        * help [command]

    显示仓库列表：
        repolist [all|enabled|disabled]

    显示程序包：
        list
            # yum list [all | glob_exp1] [glob_exp2] [...]
            # yum list {available|installed|updates} [glob_exp1] [...]

    安装程序包：
        install package1 [package2] [...]

        reinstall package1 [package2] [...]  (重新安装)

    升级程序包：
        update [package1] [package2] [...]

        downgrade package1 [package2] [...] (降级)

    检查可用升级：
        check-update

    卸载程序包：
        remove | erase package1 [package2] [...]

    查看程序包information：
        info [...]

    查看指定的特性(可以是某文件)是由哪个程序包所提供：
        provides | whatprovides feature1 [feature2] [...]

    清理本地缓存：
        clean [ packages | metadata | expire-cache | rpmdb | plugins | all ]

    构建缓存：
        makecache

    搜索：
        search string1 [string2] [...]

        以指定的关键字搜索程序包名及summary信息；

    查看指定包所依赖的capabilities：
        deplist package1 [package2] [...]

    查看yum事务历史：
        history [info|list|packages-list|packages-info|summary|addon-info|redo|undo|rollback|new|sync|stats]

    安装及升级本地程序包：
        * localinstall rpmfile1 [rpmfile2] [...]
           (maintained for legacy reasons only - use install)
        * localupdate rpmfile1 [rpmfile2] [...]
           (maintained for legacy reasons only - use update)

    包组管理的相关命令：
        * groupinstall group1 [group2] [...]
        * groupupdate group1 [group2] [...]
        * grouplist [hidden] [groupwildcard] [...]
        * groupremove group1 [group2] [...]
        * groupinfo group1 [...]

    如何使用光盘当作本地yum仓库：
        (1) 挂载光盘至某目录，例如/media/cdrom
            # mount -r -t iso9660 /dev/cdrom /media/cdrom
        (2) 创建配置文件
        [CentOS7]
        name=
        baseurl=
        gpgcheck=
        enabled=

    yum的命令行选项：
        --nogpgcheck：禁止进行gpg check；
        -y: 自动回答为“yes”；
        -q：静默模式；
        --disablerepo=repoidglob：临时禁用此处指定的repo；
        --enablerepo=repoidglob：临时启用此处指定的repo；
        --noplugins：禁用所有插件；

    yum的repo配置文件中可用的变量：
        $releasever: 当前OS的发行版的主版本号；
        $arch: 平台；
        $basearch：基础平台；
        $YUM0-$YUM9

        http://mirrors.magedu.com/centos/$releasever/$basearch/os

    创建yum仓库：
        createrepo [options] <directory>

    程序包编译安装：
        testapp-VERSION-release.src.rpm --> 安装后，使用rpmbuild命令制作成二进制格式的rpm包，而后再安装；

        源代码 --> 预处理 --> 编译(gcc) --> 汇编 --> 链接 --> 执行

        源代码组织格式：
            多文件：文件中的代码之间，很可能存在跨文件依赖关系；

            C、C++： make (configure --> Makefile.in --> makefile)
            java: maven


            C代码编译安装三步骤：
                ./configure：
                    (1) 通过选项传递参数，指定启用特性、安装路径等；执行时会参考用户的指定以及Makefile.in文件生成makefile；
                    (2) 检查依赖到的外部环境；
                make：
                    根据makefile文件，构建应用程序；
                make install

            开发工具：
                autoconf: 生成configure脚本
                automake：生成Makefile.in

            建议：安装前查看INSTALL，README

        开源程序源代码的获取：
            官方自建站点：
                apache.org (ASF)
                mariadb.org
                ...
            代码托管：
                SourceForge
                Github.com
                code.google.com

        c/c++: gcc (GNU C Complier)

        编译C源代码：
            前提：提供开发工具及开发环境
                开发工具：make, gcc等
                开发环境：开发库，头文件
                    glibc：标准库

                通过“包组”提供开发组件
                    CentOS 6: "Development Tools", "Server Platform Development",

            第一步：configure脚本
                选项：指定安装位置、指定启用的特性

                --help: 获取其支持使用的选项
                    选项分类：
                        安装路径设定：
                            --prefix=/PATH/TO/SOMEWHERE: 指定默认安装位置；默认为/usr/local/
                            --sysconfdir=/PATH/TO/SOMEWHERE：配置文件安装位置；

                        System types:

                        Optional Features: 可选特性
                            --disable-FEATURE
                            --enable-FEATURE[=ARG]

                        Optional Packages: 可选包
                            --with-PACKAGE[=ARG]
                            --without-PACKAGE

            第二步：make

            第三步：make install

        安装后的配置：
            (1) 导出二进制程序目录至PATH环境变量中；
                编辑文件/etc/profile.d/NAME.sh
                    export PATH=/PATH/TO/BIN:$PATH

            (2) 导出库文件路径
                编辑/etc/ld.so.conf.d/NAME.conf
                    添加新的库文件所在目录至此文件中；

                让系统重新生成缓存：
                    ldconfig [-v]

            (3) 导出头文件
                基于链接的方式实现：
                    ln -sv 

            (4) 导出帮助手册
                编辑/etc/man.config文件
                    添加一个MANPATH

    练习：
        1、yum的配置和使用；包括yum repository的创建；
        2、编译安装apache 2.2; 启动此服务；

    博客作业：程序包管理：rpm/yum/编译               

桌面环境：Windows 7， OpenSUSE 13.2,  Kubuntu(KDE)
