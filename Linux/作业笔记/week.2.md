# Linux基础目录
Linux发行版基础目录名称命名法和用途规定的标准,FHS：Filesystem Hierarchy Standard
* /bin，供所有用户使用的，基本命令程序文件，二进制可执行命令
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
* /srv，当前主机为服务提供的数据；
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

## Linux系统上的文件类型
* **-**：常规文件，即，f
* **d**：目录文件
* **b**：block device：块设备文件，支持以“block”为单位进行随机线性访问
* **c**：character device，字符设备文件，支持以“character”为单位线性访问
  * 设备类型文件中，其文件大小的位置有两个数字，其含义为：
    * major number：主设备号，标识设备类型，进而确定要加载的驱动程序
    * minor number：次设备好，标识同种设备的不同设备
* **l**：symbolic link：符号连接文件，类似于快捷方式
* **p**：pipe，命名管道
* **s**：socket，套接字文件，两个进程进行通信时使用。

## 基本命令
命令类型：内部命令、外部命令。通过`type COMMAND`类查看。命令有别名，别名可以与原名相同，此时原名被隐藏。如果要运行原命令，需要在使用`/`
### aslias
* 查看所有可用的别名定义：`aslias`
* 定义别名：`alias fping='ping -w 1 -n 10 -i 0.01'`，仅本次登录有效
* 撤销别名：`unalias fping`

### witch
* **witch**：显示命令的完整路径
  * 用法：which [options] [--] programname [...]
  * 参数：
    * --skip-alias：忽略别名

### whereis
* **whereis**：显示二进制程序路径、手册路径和源地址路径
  * 用法：whereis [options] [-BMS directory... -f] name...
  * 选项：
    * -b：仅显示二进制程序路径
    * -m：Search only for manuals.
    * -s：Search only for sources.

### who
* **who**：登录当前系统的用户
  * 选项：
    * -b：系统上一次的启动时间
    * -r：运行级别

### w
* w：增强版的who命令

### history
* shell进程会在其会话中，保存此前用户提交执行的命令。使用`history`命令查看
* 定制history的功能，可通过环境变量来实现：
  * `echo $HISTSIZE`：命令历史的条数
  * `echo $HISTFILE`：查看当前用户持久保存命令历史的文件路径
  * `echo $HISTFILESIZE`：查看HISTFILE中的命令大小
  * 用法：
    * `history [-c] [-d 偏移量] [n]`：对历史命令进行操作
      * **-c**：清空命令历史
      * **-c -d 偏移量**：从指定偏移量清除历史，偏移量标识
      * `history 10`：显示最近10条命令
    * `history -anrw [filename]`：操作历史文件
      * **-r**：从文件中，读取历史命令到缓存中（read the history file and append the contents to the history list）
      * **-w**：读取缓存中的历史命令，追加到文件中（write the current history to the history file and append them to the history list）
* 调用history中的命令：
  * `!10`，再次执行第10条命令
* 调用上一条命令的最后一个参数：`ESC .`、`!$`
* 控制命令历史的方式：
  * HISTCONTROL，其取值有：
    * ignoredups：忽略重复命令
    * ignorespace：忽略以空白开头的命令
    * ignoreboth：忽略以上两种
    * 修改方式：`HISTCONTROL=ignorespace`，仅对当前shell有效


----------------------------------------------------------------------------
# 1、Linux上的文件管理类命令都有哪些，其常用的使用方法及其相关示例演示。
从根开始，自顶向下


# 2、bash的工作特性之命令执行状态返回值和命令行展开所涉及的内容及其示例演示。
## bash的基础特性

# 3、请使用命令行展开功能来完成以下练习：
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