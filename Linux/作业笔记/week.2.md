# Linux基础目录名称命名法则及功用
Linux发行版基础目录名称命名法和用途规定的标准
FHS：Filesystem Hierarchy Standard
* /bin，供所有用户使用的，基本命令程序文件
* /sbin，/usr/sbin, /local/usr/sbin，供系统管理使用的工具程序；
* /boot，引导加载器必须用到的各静态文件：kernel，initramfs（initrd），grub等；
* /dev，设备文件或设备文件；
    * 设备类型：字符设备（线性设备：键盘、显示器），块设备（随机设备：硬盘）；
* /ect，主机特有的配置文件，只为静态
* /home，普通用户的家目录集中位置；
* /root，管理员的家目录，可选；
* /lib，/lib<qual>，为系统启动或根文件系统上的应用程序（/bin和/sbin）提供共享库，以及为内核提供内核模块
    * libc.so.*：动态链接的C库；
    * ld*：运行时链接器/加载器
    * modules：用于存储内核模块的目录；
* /media，便携性设备实现挂载，cdrom，floppy等；
* /mnt，其他文件的临时挂载点；
* /opt，附加程序的安装位置；
* /src，当前主机为服务提供的数据；
* /tmp，临时文件，可供所有用户执行写入操作，有特殊权限；
* /usr，第二重要的文件，为universal shareable read-only，
    * bin, sbin, lib, lib64等；
    * include：C语言的头文件
    * shared：命令手册页，命令自带文档等架构特有的文件的存储位置
    * local，另一个层级目录，安装本地应用程序；也通常用于安装第三方程序；
    * src，程序源码文件的存储位置
* /var，存储变化数据文件:
    * cache：应用程序缓存数据目录
    * lib，应用程序状态信息数据
    * local，专用于/usr/local下应用程序存储可变数据
    * lock，锁文件
    * log，日志目录及文件
    * opt，专用/opt下的应用程序存储可变数据
    * run，运行中的进程相关数据
    * spool，应用程序的数据池
    * tmp，保存系统两次重启之间产生的临时数据
* /proc，基于内存的，内核和进程信息的虚拟文件系统，多为内核参数；
    * 例如：net.ipv4.ip_forward，虚拟为net/ipv4/ip_forward。存储于/proc/sys/，其完整路径为/proc/sys/ipv4/ip_forward；
* /sys，sysfs虚拟文件系统，提供了一种比proc更为理想的访问内核数据的途径；
    * 主要作用：为管理Linux设备提供一种统一模型的接口；

----------------------------------------------------------------------------
# 1、Linux上的文件管理类命令都有哪些，其常用的使用方法及其相关示例演示。
从根开始，自顶向下

# 2、bash的工作特性之命令执行状态返回值和命令行展开所涉及的内容及其示例演示。
3、请使用命令行展开功能来完成以下练习：
   (1)、创建/tmp目录下的：a_c, a_d, b_c, b_d
   (2)、创建/tmp/mylinux目录下的：
mylinux/
    ├── bin
    ├── boot
    │   └── grub
    ├── dev
    ├── etc
    │   ├── rc.d
    │   │   └── init.d
    │   └── sysconfig
    │       └── network-scripts
    ├── lib
    │   └── modules
    ├── lib64
    ├── proc
    ├── sbin
    ├── sys
    ├── tmp
    ├── usr
    │   └── local
    │       ├── bin
    │       └── sbin
    └── var
        ├── lock
        ├── log
        └── run