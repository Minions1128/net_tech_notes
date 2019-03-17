# Linux文件相关

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


## 文本查看类命令：

- **head**：查看文件前n行，默认前10行
  - `head [-20 | -n 20] 1.txt`
- **tail**：查看文件后n行，默认为10
  - -f --follow：查看文件尾部结束后，跟随显示的新增行
- 分屏查看命令
  - **more**：`more FILE`
    - 特点：翻屏查看文件尾部后自动推出
  - **less**：`less FILE`
    - less可以向前、向后翻页
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

## 文件管理工具

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
- [install命令](http://man.linuxde.net/install "install命令")

## 命令行展开

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

## 权限管理命令：
- chmod：
  - 三类用户：u(ser), g(roup), o(ther), a(ll)
  - chmod [OPTION]... MODE[,MODE]... FILE...：对文件单独操作
    - MODE表示法：
      - 赋值表示：操作一类用户的所有权限位，`chmod g=rx FILE`, `chmod ug=r FILE`，`chmod u=rwx,g=rw,o= FILE` 
      - 授权表示：操作一类用户的一个权限位，`chmod o+r FILE`，`chmod go-x FILE`，`chmod u+x,g+r FILE`
  - chmod [OPTION]... OCTAL-MODE FILE...：将文件修为对应的8进制标识的权限：`chmod 777 FILE`
  - chmod [OPTION]... --reference=RFILE FILE...：将RFILE所对应的权限也赋给FILE：`chmod --reference=RFILE FILE`
  - 选项：
    - -R, --recursive：递归修改
  - 修改文件权限，仅管理员可以修改文件权限
- chown：修改属主属组命令
  - chown [OPTION]... [OWNER][:[GROUP]] FILE...
  - chown [OPTION]... --reference=RFILE FILE...
  - 选项：
    - -R, --recursive，递归修改
  - 修改文件属主，仅仅是管理员，或者文件属主为自己的文件
- chgrp：修改属组的命令
  - chgrp [OPTION]... GROUP FILE...
  - chgrp [OPTION]... --reference=RFILE FILE...
- 用户对目录有写权限，对目录下的文件无写权限，无法修改该目录，可以删除该文件。
- umask：文件权限反向掩码，遮罩码；
  - 文件默认权限：使用`666-umask`，默认不可以有执行权限，如果得到的结果有执行权限，则需要将其+1
  - 目录默认权限：使用`777-umask`，默认可以有执行权限
  - umask命令：
    - 查看umask：`umask`
    - 修改umask：`umask 027`
    - 此类命令仅对当前shell有效
- install命令：copy files and **set attributes**
  - install [OPTION]... [-T] SOURCE DEST：将单个源文件复制到目的
  - install [OPTION]... SOURCE... DIRECTORY：将多个源复制到目的
  - install [OPTION]... -t DIRECTORY SOURCE...：同上
  - install [OPTION]... -d DIRECTORY...：创建空目录
  - 选线：
    - -m, --mode=MODE：设定目标文件权限，默认为755
    - -o, --owner=OWNER：设定文件属主
    - -g, --group=GROUP：设定文件属组
    - -d, --directory：创建目录
- mktemp：创建临时文件、目录
  - mktemp [OPTION]... [TEMPLATE]：`mktemp ./1.tXXXX`，在当前目录下，创建名为1.XXXX的文件，XXX为随机字符，且至少为3个X
  - 选项：
    - -d, --directory：创建临时目录
    - -u, --dry-run：用于测试，不会真正创建出文件
  - 该命令会将文件名直接返回，可以将其文件名保存起来

## Linux文件的特殊权限
特殊权限：SUID、SGID、STICKY
- 安全上下文：
  - 进程以某用户身份运行；进程是发起此进程用户的代理，因此以此用户的身份和权限完成所有操作；
  - 权限匹配模型：
    - 判断进程的属主，是否为被访问的文件属主：如果是，应用属主的权限；否则进行下一步
    - 判断进程的属主，是否为被访问的文件属组：如果是，应用属组的权限；否则进入下一步
    - 应用other的权限
- SUID：
  - 功能：默认情况下，用户发起进程，进程的属主是其发起者。用户运行某程序（文件）时，如果此程序文件拥有SUID权限，当程序运行为进程时，其属主不是发起者，而是程序文件自己的属主。
  - 添加方法：`chmod u{+|-}s FILE`
  - 展示位置：属主执行权限位。如果文件属主本来有执行权限，显示为`s`，否则显示为`S`
- SGID：一般用在修改目录的权限上
  - 功能：当目录拥有写权限，且有SGID权限时，所有属于此目录的属组，且以组身份在此目录中创建文件或目录时，新文件或目录不是用户的基本组，而是此目录的属组
  - 添加方法：`chmod g{+|-}s FILE`
  - 展示位置：属组执行权限位。如果文件属组本来有执行权限，显示为`s`，否则显示为`S`
- STICKY：
  - 功能：对于属组或全局可写的目录，组内的所有用户或系统上的所有用户对在此目录中都能创建或删除文件。如果该目录设置STICK权限，则每个用户能创建新文件，且只能删除自己的文件。
  - 添加方法：`chmod o{+|-}t FILE`
  - 展示位置：other执行权限位。如果文件other本来有执行权限，显示为`t`，否则显示为`T`
  - 默认的`/tmp`和`/var/tmp`目录均有该权限
- 另一种管理方式：
```
suid sgid sticky
0    0    0          0
0    0    1          1
...
1    1    0          6
1    1    1          7
```
  - 举例：`chmod 1777 FILE`，加在最左侧
- facl：file access control lists
  - 文件的额外的赋权机制：在原有的ugo之外的另一层让普通用户能控制赋权给另外的用户或组的赋权机制；
  - 相关命令：
    - `getfacl FILE`：查看该文件的其他权限
    - `setfacl -m {u:USER|g:GROUP}:MODE FILE`：让某一用户、组拥有MODE（读、写、执行，或者为空）的权限
    - `setfac; -x {user:USER|group:GROUP} FILE`：撤销赋权

## 文件查找

实现工具：locate，find

### locate

- locate：依赖于事先构建好的索引库，其系统自动实现（周期性任务），或者手动更新数据库（updatedb）；
  - 工作特点：
    - 模糊查找文件
    - 查找速度快
    - 非实时查找
    - 建立索引需要遍历整个根文件系统，及其消耗系统资源
  - locate [OPTION]... PATTERN...
    - -b, --basename：指定只查找基名
    - -c, --count，统计找出来的个数
    - -r, --regexp REGEXP，匹配正则表达式

### find

- find：实时查找工具，通过遍历指定起始路径下文件系统层级结构完成文件查找
  - 工作特点：
    - 查找速度略慢
    - 精确查找
    - 实时查找
  - `find [选项] [查找起始路径] [查找条件] [处理动作]`
    - 查找起始路径：默认为当前目录
    - 查找条件：文件名、大小、类型、从属关系、权限等；默认为所有文件
      - 根据文件名查找：支持glob风格的通配符查找：`*`，?，[]，[^]
        - -name：根据文件名查找
        - -iname：忽略文件名大小写。
      - 根据文件从属关系：
        - -user：根据属主查找
        - -group：根据属组查找
        - -uid：根据uid查找文件
        - -gid：根据gid查找文件
        - -nouser：查找没有属主的文件
        - -nogroup：查找没有属组的文件
      - 根据文件类型查找：-type TYPE
      - 根据文件大小查找：-size [+ | -]#UNIT
        - `find /tmp -size 172k`
        - 常用单位：k，M，G
        - #UNIT：(#-1, #]
        - -#UNIT：[0, #-1]
        - +#UNIT：(#, +oo]
      - 根据时间戳查找：-OP [+-]#
        - 计算方法：#：(now-#-1, now-#]，第#天；+#：(-oo, now-#-1]，#天外；-#：(now-#, now)，#天内
        - 以天为单位：-atime，-mtime，-ctime
        - 以分钟为单位：-amin，-mmin，-cmin
      - 根据权限查找：
        - `-perm [/|-] mode`：
          - mode：精确选线查找：`find ./ -perm 644`，精确查找权限为644的文件
          - /mode：任何一类用户(u,g,o)的任何一位(r,w,x)符合条件，即满足
          - -mode：任何一类用户(u,g,o)的任何一位(r,w,x)同时符合条件，即满足
      - 组合测试：
        - 与：-a，`find /tmp -user root -type f -ls`
        - 或：-o，`find /tmp -nouser -o -type f -ls`
        - 非：-not，!，`find /tmp {-not | !} -type f -ls`
        - 组合举例：`find /tmp -not  \( -user root -o -iname "*fstab*" \) -ls`
    - 处理动作：先查找文件，将查找到的文件路径一次性传递给命令
      - -print：显示到屏幕
      - -ls：将结果ls到屏幕
      - -delete：删除查找到的文件
      - -fls /PATH/FILE：将文件ls到屏幕，且保存到/PATH/FILE中
      - `-ok COMMAND {} \;`：对查找到的文件进行执行，COMMAND表示执行命令，每次需要确认
      - `-exec COMMAND {} \;`：对查找到的文件进行执行，COMMAND表示执行命令，不需要每次确认
      - find .... | xargs：将find到的内容传递给xargs

### Examples
1. 查找/var目录下属主为root，且属组为mail的所有文件或目录；
`~]# find /var -user root -a -group mail -ls`

2. 查找/usr目录下不属于root, bin或hadoop的所有文件或目录；用两种方法；
```
~]# find /usr -not -user root -a -not -user bin -a -not -user hadoop
~]# find /usr -not \( -user root -o -user bin -o -user hadoop \) -ls
```

3. 查找/etc目录下最近一周内其内容修改过，且属主不是root用户也不是hadoop用户的文件或目录；
```
~]# find /etc -mtime -7 -a -not \( -user root -o -user hadoop \) -ls
~]# find /etc -mtime -7 -a -not -user root -a -not -user hadoop -ls
```

4. 查找当前系统上没有属或属组，且最近一周内曾被访问过的文件或目录；
`~]# find  /  \( -nouser -o -nogroup \)  -atime  -7  -ls`

5. 查找/etc目录下大于1M且类型为普通文件的所有文件；
`~]# find /etc -size +1M -type f -exec ls -lh {} \;`

6. 查找/etc目录下所有用户都没有写权限的文件；
`~]# find /etc -not -perm /222 -type f -ls`

7. 查找/etc目录至少有一类用户没有执行权限的文件；
`~]# find /etc -not -perm -111 -type f -ls`

8. 查找/etc/init.d/目录下，所有用户都有执行权限，且其它用户有写权限的所有文件；
`~]# find /etc -perm -113 -type f -ls`
