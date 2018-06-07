# 第四周作业
1. 复制/etc/skel目录为/home/tuser1，要求/home/tuser1及其内部文件的属组和其他用户均没有任何访问权限

```
cp -r /etc/skel/ /home/tuser1
chmod go= /home/tuser1/ -R
```

2. 编辑/etc/group文件，添加组hadoop

```
vim /etc/group
hadoop:x:2020
```

3. 手动编辑/etc/passwd文件新增一行，添加用户hadoop，其基本组ID为hadoop组的id号；其家目录为/home/hadoop

```
echo "hadoop:x:2020:2020::/home/hadoop:/bin/bash" >> /etc/passwd
id hadoop
uid=2020(hadoop) gid=2020 groups=2020
```

4. 复制/etc/skel/目录为/home/hadoop/，要求修改hadoop目录的属组和其他用户没有任何访问权限

```
cp -r /etc/skel/ /home/hadoop 
chmod go= /home/hadoop/ 
```

5. 修改/home/hadoop目录及其内部的所有文件的属主为hadoop，属组为hadoop

```
chown hadoop:hadoop /home/hadoop/ -R
```

6. 显示/proc/meminfo文件中以大写或小写s开头的行；用两种方式

```
cat /proc/meminfo | grep -i '^s'
cat /proc/meminfo | grep -E '^(S|s)'
```

7. 显示/etc/passwd文件中其默认shell为非/sbin/nologin的用户

```
cat /etc/passwd | grep -v "/sbin/nologin$" | cut -d: -f1
```

8. 显示/etc/passwd文件中其默认shell为/bin/bash的用户

```
cat /etc/passwd | grep  "/bin/bash$" | cut -d: -f1
```

9. 找出/etc/passwd文件中的一位数或两位数

```
cat /etc/passwd | grep  -oE "\<[0-9]{1,2}\>" 
```

10. 显示/boot/grub2/grub.cfg中以至少一个空白字符开头的行

```
cat /boot/grub2/grub.cfg | grep -E "^[[:space:]]+"
```

11. 显示/etc/rc.d/rc.sysinit文件中以#开头，后面跟至少一个空白字符，而后又有至少一个非空白字符的行

```
cat /etc/rc.d/rc.local |grep -E '^#[[:space:]]+[^[:space:]]+'
```

12. 打出netstat -tan 命令执行结果中以’LISTEN’后或跟空白字符结尾的行

```
netstat -tan | grep -E "(LISTEN)|(LISTEN[[:space:]]*$)"
```


13. 添加用户bash testbash basher nologin (此一个用户的shell为/sbin/nologin),而后找出当前系统上其用户名和默认shell相同的用户信息

```
useradd bash
useradd testbash
useradd basher
useradd -s /sbin/nologin nologin
cat /etc/passwd |grep "^\(\<.*\>\).*\1$"
```

# 磁盘分区及文件系统管理
- 设备类型：
    - block，块设备，存取单位是块，如硬盘
    - char，字符设备，存取单位是字符，如键盘
- 设备文件FHS：/dev，关联设到设备的驱动程序；设备访问的入口
    - 设备号：
        - 主设备号：表示设备类型，即所需要的驱动程序
        - 次设备号：表示同意类型下的不同设备，特定设备的访问入口
    - mknod：make block or character special files
        - `mknod [OPTION]... NAME TYPE [MAJOR MINOR]`
            - -m, --mode=MODE：创建后的设备文件权限
        - 分区：/dev/sda#，centos6和7，硬盘文件表示为/dev/sd[a-z]#
        - 设备文件名：ICANN
            - 硬盘：
                - IDE：/dev/hd[ab]，可以接两个
                - SCSI, SATA, USB, SAS：/dev/sd[a-z]
        - 设备的引用：设备文件名、卷标、UUID
- 磁盘分区：MBR，GPT
    - MBR：0磁道0扇区，MBR即Master Boot Record：分为三个部分
        - 446Byte：存储boot loader，引导加载器
        - 64Byte：存储分区表，每16字节，标识一个分区，最多4个分区；
            - 若4个主分区，不够用，可以划分出一个逻辑分区，将逻辑分区再进行划分
        - 2Byte：MBR区域的有效性标识；55AA为有效，
        - 主分区只能是1-4，逻辑分区为5+
    - GPT：
- fdisk：manipulate disk partition table
    - fdisk -l [-u] [device...]：查看分区
    - fdisk device：管理分区，提供了一个交互式接口，有多种子命令来管理分区，其所有操作均在内存中完成，没有同步到磁盘，直到w命令保存到磁盘上
    - [其他命令介绍](http://cache.baiducontent.com/c?m=9d78d513d99717f419b480394d48d83c5f12c2222bd6a3086284cd15c6735b361627b5e7302267588483613f52fe1017adf431712a5060f1c099d61dc0edc56e7cd379756d1b874317d11dadce&p=882a9e4ec7904ead0db3dc295f00&newp=882a9e4ea4af50f90dbe9b7c5a5192695d0fc20e3dd4d701298ffe0cc4241a1a1a3aecbf2026120fd9c1766d04a9495fecf033763d0034f1f689df08d2ecce7e5de4366225&user=baidu&fm=sc&query=fdisk&qid=c88d74e600023eb0&p1=1)
    - 注意：在已经分区并且已经挂载其中某个分区的磁盘设备上创建的新分区，内核可能在创建完成后无法直接识别，在`/proc/partitions`中查看
        - 让内核强制重读磁盘分区表
            - centos 5：partprobe [device]
            - centos 6, 7：`partx -a [device]`或者`kpartx -af [device]`
    - 分区创建工具：parted，sfdisk
- 创建文件系统
    - 格式化：
        - 低级格式化：区分之前进行，划分磁道
        - 高级格式化：分区之后记性，创建文件系统
    - 元数据区、数据区：
        - 元数据区：
            - 文件元数据（inode，index node）：大小，权限，属主属组、时间戳，数据块指针
        - 连接文件：存储数据指针的空间当中存储的是真是文件的访问路径，没有占用的数据空间
        - 设备文件：存储数据指针的空间当中存储的是设备号，没有占用的数据空间
    - bitmap index：位图索引
- VFS：virtual file system
    - Linux文件系统：ext2（无日志）, ext3, ext4, xfs, reiserfs, btrfs
    - 光盘：iso 9660
    - 网络文件系统：nfs，cifs
    - 集群文件系统：gfs2，ocfs2
    - windows文件系统：vfat，ntfs
    - 伪文件系统：proc，sysfs，tmpfs，hugepagefs
    - unix文件系统：UFS，FFS，JFS
    - 交换分区文件熊：swap
- 文件系统的管理工具：
    - 创建文件系统的工具：mkfs：mkfs.ext2, ...
    - 检测及修复文件系统的工具：fsck：fsck.ext2, ...
    - 查看其属性的工具：dumpe2fs, tune2fs
    - 调整文件系统特性：tune2fs
- journal：
- 链接文件
    - 硬链接：指向同一个inode的多个文件路径
        - 特性：
            1. 目录不支持链接；
            2. 硬链接不能跨文件系统；
            3. 创建硬链接会增加inode引用次数
            4. 文件大小和原文件相同
        - 创建：`ln SOURCE LINK_FILE`
    - 软链接：符号链接，指向一个文件路径的另外一个文件路径
        - 特性：
            1. 符号链接与文件是两人各自独立的文件，各有自己的inode。对原文件创建符号链接不会增加引用计数；
            2. 支持对目录创建符号链接，可以跨文件系统；
            3. 删除符号链接文件不影响原文件；但删除原文件，符号指定的路径即不存在，此时会变成无效链接
            4. 文件大小是指定的文件的路径字符串字节数
        - 创建：`ln -s SRC LINK_FILE`
    - -v，--verbose：
- https://www.jianshu.com/p/bf939474d69b
- 内核级文件系统的组成部分：文件系统驱动：由内核提供；文件系统管理工具：由用户空间的应用程序提供
- ext系列文件系统的创建工具：mkfs.ext2, mkfs.ext3, mkfs.ext4
    - mke2fs：
        - mke2fs [OP] device
            - -t {ext2 | ext3 | ext4}：指定文件系统类型：mkfs.ext4 = mkfs -t ext4 = mke2fs -t ext4
            - -b {1024 | 2048 | 4096}：指定块大小
            - -L new-volume-label：打标
            - -j：创建有日志功能的文件系统ext3：              
            - -i #：每多少字节创建一个inode
            - -N #：指定inode数
            - -O ：指定区特性：`mke2fs -j = mke2fs -t ext3 = mkfs -t ext3 = mkfs.ext3 = mke2fs -O has_journal`
            - -m：指定预留空间占整个分区空间的百分比，默认为5%
- blkid：查看指定块设备的属性信息：`blkid [-L label | -U uuid] DEVIC`
- e2label：卷标的查看与设定：`e2label device [LABEL]`
- tune2fs：查看或修改ext系列文件系统的某些属性
- dumpe2fs
- 文件系统检测

`8.3 65 min`