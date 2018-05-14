# Linux基础目录名称命名法则及功用规定
FHS：Filesystem Hierarchy Standard
* /bin，供所有用户使用的，基本命令程序文件
* /sbin，/usr/sbin, /local/usr/sbin，供系统管理使用的工具程序；
* /boot，引导加载器必须用到的各静态文件：kernel，initramfs（initrd），grub等；
* /dev，设备文件或设备文件；
    * 设备类型：字符设备（线性设备：键盘、显示器），块设备（随机设备：硬盘）；
* /ect，主机特有的配置文件，只为静态
* /home，普通用户的家目录集中位置；
* /lib，/lib<qual>，为系统启动或根文件系统上的应用程序（/bin和/sbin）提供共享库，以及为内核提供内核模块
    * libc.so.*：动态链接的C库；
    * ld*：运行时链接器/加载器
    * modules：用于存储内核模块的目录；
* /media，便携性设备实现挂载，cdrom，floppy等；
* /mnt，其他文件的临时挂载点；
* /opt，附加程序的安装位置；


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