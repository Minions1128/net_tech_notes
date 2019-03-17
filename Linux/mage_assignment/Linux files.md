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
- install命令：

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
