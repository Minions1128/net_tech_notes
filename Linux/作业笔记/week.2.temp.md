# Linux基础目录
## Linux目录构成
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

### 目录管理类的命令
- **mkdir**：make directory，创建目录的基目录必须存在
  - -p：递归创建目录
  - -v：verbose，显示过程
  - -m：直接设定目录权限
- **rmdir**：remove empty directory，只用于删除空目录
  - -p：递归删除空目录，
  - -v：verbose，显示过程

### 命令行展开
- ~：自动展开为用户的家目录
- {}：实现多个变量的复合使用：
```
mkdir ./{a,b,c}d{e,f,g}
在当前目录下创建，ade adf adg bde bdf bdg cde cdf cdg

mkdir -vp ./mylixux/{bin,boot/grub,dev,etc/{rc.d/init.d,sysconfig/network-scripts},lib/modules,lib64 \
  ,proc,sbin,sys,tmp,usr/local/{bin,sbin},var/{lock,log,run}}
在当前目录下创建，如下目录
./mylixux/
├── bin
├── boot
│   └── grub
├── dev
├── etc
│   ├── rc.d
│   │   └── init.d
│   └── sysconfig
│       └── network-scripts
├── lib
│   └── modules
├── lib64
├── proc
├── sbin
├── sys
├── tmp
├── usr
│   └── local
│       ├── bin
│       └── sbin
└── var
    ├── lock
    ├── log
    └── run
```
- tree：以树形结构展示目录

### bash的基本特性
- 命令执行的状态结果：bash通过状态返回值，成功0，失败用非0（1-255）值。其会在命令执行完成之后，保存在$?的变量中
- 命令执行结果：引用命令的执行结果$(COMMAND)或者\`COMMAND\`来应用命令的执行结果
- 引用：
  - 强引用''
  - 弱引用""
  - 命令引用\`\`
- 快捷键：
  - ctrl+a：跳转至命令行首
  - ctrl+e：跳转至命令行尾
  - ctrl+u：删除行首到光标所在处之间的所有字符
  - ctrl+k：删除光标所在处到行尾之间的所有字符
  - ctrl+l：清屏，相当于clear

### 文本查看类命令：
- **head**：查看文件前n行，默认前10行
  - `head [-20 | -n 20] 1.txt`
- **tail**：查看文件后n行，默认为10
  - -f --follow：查看文件尾部结束后，跟随显示的新增行
- 分屏查看命令
  - **more**：`more FILE`
    - 特点：翻屏查看文件尾部后自动推出
  - **less**：`less FILE`
- **stat**：显示文件的状态
  - 文件有两类数据：
    - 元数据：metadata
  - 数据：data
  - touch命令更改这三个时间，还可以创建文件，
    - -c，可以不创建不存在的文件
  - -a，至修改access time
  - -m，只修改modify time
  - -t，改为指定时间

```
]# stat known_hosts.bak 
Size: 26011           Blocks: 56         IO Block: 4096   regular file
Device: 806h/2054d      Inode: 526224      Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2018-05-14 13:12:26.921902662 +0800     # 最后访问
Modify: 2018-01-18 10:28:22.928253961 +0800    # 最后更改，更改数据，即文件内容
Change: 2018-01-18 10:41:46.563200338 +0800 # 最后改动，更改元数据，即不变文件内容
Birth: -
```
### 文件管理工具
- cp：copy，复制文件的数据
  - `cp [OPTION]... [-T] SOURCE DEST`：单文件复制
    - 若DEST不存在：创建此文件，然后将数据流填充到该文件中
  - 若DEST存在：
    - 若DEST是非目录文件：覆盖目标文件
    - 若DEST是目录文件：现在DEST目录下创建一个与源文件同名文件，并复制其数据流。
  - `cp [OPTION]... SOURCE... DIRECTORY`，或者`cp [OPTION]... -t DIRECTORY SOURCE...`：多源复制
    - 若DEST不存在：错误
  - 若DEST存在：
    - 若DEST为非目录文件：错误
    - 所DEST为目录文件：将所有文件复制到目标目录
  - 选项：
    - -i, --interactive：交互式复制，提示是否覆盖已有文件
  - -f, --force：强制复制目标文件
  - -R, -r, --recursive：递归复制目录
  - -d：只复制符号连接文件本身，不是连接的目标文件本身
  - --preserve={mode | ownership | timestamps}：
    - mode：保留原来权限
    - ownership：从属关系
    - timestamps：时间戳
    - context：安全标签
    - xazttr：扩展属性
    - links：符号连接
    - all：上述所有属性
  - -a, --archive：用于实现归档，其等价于：-dR --preserve=all
- mv：move，移动或者重命名文件
  - 用法和cp类似：其没有-r选项
  - 选项：
    - -i, --interactive：prompt before overwrite
    - -f, --force：do not prompt before overwriting
- rm：remove
  - rm [OPTION]... FILE...
  - 选项：
    - -i：prompt before every removal
  - -f, --force：ignore nonexistent files and arguments, never prompt
  - -r, -R, --recursive：remove directories and their contents recursively

### bash 基础特性：globbing
文件名通配
- 匹配模式：元字符
  - \*：任意长度的任意字符
  - ?：任意单个字符
  - []：匹配指定范围内的任意单个字符
    - [a-z]：任意单个字母a-z
  - [0-9]：任意单个数字
  - [a-z0-9]：任意单个字母或者数字
  - [abcxyz]：a, b, c, x, y, z中的任意单个字符
  - [[:upper:]]：所有大写字母
  - [[:lower:]]：所有小写字母
  - [[:alpha:]：所有字母
  - [[:digit:]]：所有数字
  - [[:alnum:]]：所有字母和数字
  - [[:space:]]：空白字符
    - \为转义字符
  - [[:punct:]]：所有标点符号
  - [^]：匹配指定范围外的任意单个字符：
    - [^[:alnum:]]：任意非字母和数字的字符

### I/0重定向及管道
- 程序三种数据流：
  - 输入的数据流：<-- 标准输入（stdin），键盘
  - 输出数据流：-->标准输出（stdout），显示器
  - 错误输出流：-->错误输出（stderr），显示器
- fd：file descriptor，文件描述符
  - 标准输入：0
  - 标准输出：1
  - 错误输出：2

## 用户、用户组和管理权限
- 用户
  - 用户类别
    - 管理员
    - 普通用户
      - 系统用户
      - 登录用户
  - 用户标识：UserID，UID
    - 16bits二进制数
      - 管理员的UID为0
      - 普通用户为1-65535
        - 系统用户：1-499（centos 6），1-999（centos 7）
        - 登录用户：500-60000，10000-60000
  - 名称解析：username <--> UID
    - 根据名称解析库：/etc/passwd
- 用户组
  - 组类别1:
    - 管理员组
    - 普通用户组
      - 系统用户组：为了能让那后台进程或者服务类进程以非管理员身份运行，通常需要为此创建多个普通年用户，这类用户从不用登录系统；
      - 登录用户组
  - 组标识：GroupID，GID
    - 管理员组：0
      - 普通用户组：1-65535
        - 系统用户组：1-499（centos 6），1-999（centos 7）
        - 登录用户组：500-60000，10000-60000
  - 名称解析：groupname <--> gid
    - 解析库：/etc/group
  - 组类别2：
    - 用户的基本组
    - 用户的附加组
  - 组类别3：
    - 用户私有组：组名同用户名，且包含一个用户
    - 公共租：组内包含了多个用户
- 认证信息
  - password：/etc/shadow
  - group password：/etc/gshadow
  - 加密算法
    - 对称加密
    - 非对成加密
    - 单向加密：只能加密，不能解密，提取数据特征码
      - 定长输出
      - 雪崩效用
      - 算法
        - md5：message digest，128 bits
        - sha：secure hash algorithm，160 bits
        - sha256，sha384，sha512
      - 在计算密码时，要加一些salt，添加随机数
    - 一些文件中的内容
      - /etc/passwd：用户信息：
        - name:password:UID:GID:GECOS:directory:shell
        - password：早起为密码
        - GECOS：用户注释信息
        - directory：用户的家目录：
        - shell：用户的默认shell
      - /etc/shadow：用户密码
        - login name : encrypted password : date of last password change : minimum password age : maximum password age : password warning period : password inactivity period : account expiration date : reserved field

      - /etc/group：组的信息
       - group_name:password:GID:user_list

### 相关命令：
- groupadd：添加组
  - groupadd [op] group_name
  - 选项：
    - -g：手动GID，默认是上一个组的GID+1
    - -r：创建系统用户组
  - groupmod：
    - -g GID：修改GID
    - -n new_name：修改组名
  - groupdel
- useradd：添加
  - useradd [OP] user_name
  - 选项：
    - -u, --uid UID：指定UID
    - -g, --gid GID：指定GID，此组得事先存在
    - -G, --groups GROUP1[,GROUP2,...[,GROUPN]]]：指明用户所属的附加组，多个组之间用都好分割
    - -c, --comment COMMENT：指明注释信息
    - -d, --home-dir HOME_DIR：指明用户的家目录。通过复制/etc/skel此目录并重命名实现。如果指定的家目录实现存在，则不会为用户复制环境配置文件。
    - -s, --shell SHELL：指明用户的shell。可用的所有shell列表存储为/etc/shells文件中
    - -r, --system：创建系统用户
    - -M, --no-create-home：不创建家目录
    - -D, --defaults：显示创建用户时，其默认配置，可以自行添加选项更改
      - 创建用户的许多默认设定配置文件为`/etc/login.defs`
      - 而使用命令`useradd -D`修改的配置的结果保存与`/etc/default/useradd`文件中，或者可以编辑此文件来实现
- usermod：修改用户信息
  - usermod [options] LOGIN
  - 选项：
    - -u, --uid UID：修改UID
    - -g, --gid GID：修改GID，此组得事先存在
    - -G, --groups GROUP1[,GROUP2,...[,GROUPN]]]：修改用户所属附加组
    - -a, --append：与-G一起使用，用于为用户追加新的附加组
    - -c, --comment COMMENT：修改注释信息
    - -d, --home-dir HOME_DIR：修改用户的家目录。用户原有的文件不会转移到新位置
    - -m, --move-home：只能与-d一起使用，用于将原来的家目录，移动为新的家目录
    - -l, --login [USERNAME]：修改用户名
    - -s, --shell SHELL：指明用户的shell。可用的所有shell列表存储为/etc/shells文件中
    - -L, --lock：锁定用户密码。即在用户原来的密码串之前加一个`!`
    - -U, --unlock：解锁用户的密码
- userdel：删除用户
  - userdel [options] LOGIN
  - 选项：
    - -r, --remove删除用户时，一并删除其家目录。默认不删除
- passwd：命令管理命令
  - passwd [-k] [-l] [-u [-f]] [-d] [-e] [-n mindays] [-x maxdays] [-w warndays] [-i inactivedays] [-S] [--stdin] [username]
  - `passwd`：修改用户自己的密码
  - `passwd USERNAME`：修改指定用户的密码，默认仅root用户有此权限
  - 选项：
    - -l, --lock， -u, --unlock，锁定、解锁用户
    - -d, --delete，清除用户密码
    - -e, --expire DATE，过期期限
    - -i, --inactive DAYS，非活动期限
    - -n, --minimum DAYS，密码最短使用期限
    - -x, --maximum DAYS，密码最长使用期限
    - -w, --warning DAYS，警告期限
    - --stdin，This option is used to indicate that passwd should read the new password from standard input, which can be a pipe. e.g.. `echo "PASSWORD1" | passwd --stdin USERNAME1`
- gpasswd：给组定义密码
    - 组密码文件：/etc/gshadow
    - gpasswd [option] group
    - 选项：
      - -a, --add user，-d, --delete user，向组中添加、删除用户
- newgrp [-] [group]：临时切换用户的基本组，[-]，会模拟用户重新登录
- chage：修改密码的过期信息
  - chage [OP] 登录名
  - 选项：-d, -E, -W, -m, -M
- id：查看用户、组实际、有效的ID
  - id [OPTION]... [USER]
  - 选项：
      - -u：仅显示有效的ID
      - -g：仅显示基本组ID
      - -G：显示所有组的ID
      - -n：显示名字而非ID
- su：switch user
    - 登录式切换非登录式切换：
        - 登录式切换：会通过重新读取用户的配置文件来重新初始化：`su - USERNAME`or` su -l USERNAME`
        - 非……：不会……：`su USERNAME`
        - 管理员切换到任何用户都无需密码
    - -c 'COMMAND'：不切换用户，仅以用户的身份执行命令：`su - USERNAME -c 'whoami'`
- 其他命令：chsh, chfn, finger, whoami, pwck, grpck

