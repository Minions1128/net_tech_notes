# Linux磁盘及文件系统管理

- [CentOS如何挂载硬盘](https://www.cnblogs.com/chenjian/p/8862524.html "CentOS如何挂载硬盘")

## Summary

- 文件系统管理
    - 管理工具：
    ```
    mkfs, mke2fs, e2label, tune2fs, dumpe2fs, e2fsck, blkid
    mkfs.xfs, mkfs.vfat, fsck
    mkswap, swapon, swapoff
    mount, umount, fuser, lsof
    df, du
    ```
    - fstab文件：
        - `设备  挂载点     文件系统类型  挂载选项    转储频率    自检次序`
    - 文件系统：
        - 目录：文件
            - 元数据：inode, inode table
            - 数据：data blocks
                - 其下级文件或目录的文件名与其inode对应关系
                - dentry
        - 文件名：存在上级目录；
        - 删除文件：将此文件指向的所有data block标记为未使用状态；将此文件的inode标记为未使用；
        - 复制：新建文件；
        - 移动文件：
            - 在同一文件系统：改变的仅是其路径；
            - 在不同文件系统：复制数据至目标文件，并删除原文件；
        - 符号链接：权限：lrwxrwxrwx
        - 硬链接：指向同一个inode；

## 概述

- I/O: Disks(持久存储数据), Ehtercard

- 接口类型：
    - 并口：同一线缆可以接多块设备；
        - IDE(ata)：两个，主，从，IDE(ata)
        - SCSI：Ultrascsi320, 320MB/S, UltraSCSI640, 640MB/S
            宽带：16-1个设备
            窄带：8-1个设备
    - 串口：同一线缆只可以接一个设备；
        - SATA：串口，6gbps
        - SAS：串口，6gbps
        - USB：串口，480MB/s

- iops：io per second

- 硬盘：
    - 机械硬盘：
        - track：磁道
        - sector：扇区，512bytes
        - cylinder：柱面（分区划分基于柱面）
        - 平均寻道时间。5400rpm, 7200rpm, 10000rpm, 15000rpm
    - 固态硬盘

- 设备类型：
    - block，块设备，存取单位是块，如硬盘
    - char，字符设备，存取单位是字符，如键盘

- 设备文件FHS：/dev，关联设到设备的驱动程序；设备访问的入口
    - 设备号：
        - 主设备号：表示设备类型，即所需要的驱动程序
        - 次设备号：表示同意类型下的不同设备，特定设备的访问入口
    - mknod：用于创建Linux中的字符设备文件和块设备文件
        - `mknod [OPTION]... NAME TYPE [MAJOR MINOR]`
            - -m, --mode=MODE：创建后的设备文件权限
        - 分区：/dev/sda[1-9]，centos6和7，硬盘文件表示为/dev/sd[a-z]#
        - 设备文件名：ICANN
            - 硬盘：
                - IDE：/dev/hd[ab]，可以接两个
                - SCSI, SATA, USB, SAS：/dev/sd[a-z]
        - 设备的引用：设备文件名、卷标、UUID

- 磁盘分区：MBR(Master Boot Record)，GPT
    - MBR：0磁道0扇区，512字节：分为三个部分
        - 前446Byte：存储boot loader，引导加载器
        - 64Byte：存储分区表，每16字节，标识一个分区，最多4个分区；
            - 若4个主分区，不够用，可以划分出一个逻辑分区，将逻辑分区再进行划分
        - 2Byte：MBR区域的有效性标识；`55AA`为有效，
        - 主分区只能是1-4，逻辑分区为5+
    - GPT：

- VFS：virtual file system
    - Linux文件系统：ext2（无日志）, ext3, ext4, xfs, reiserfs, btrfs
    - 光盘：iso 9660
    - 网络文件系统：nfs，cifs
    - 集群文件系统：gfs2，ocfs2
    - 内核级分布式文件系统：ceph
    - windows文件系统：vfat，ntfs
    - 伪文件系统：proc，sysfs，tmpfs，hugepagefs
    - unix文件系统：UFS，FFS，JFS
    - 交换分区文件系统：swap
    - 用户空间的分布式文件系统：mogilefs, moosefs, glusterfs

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

- 内核级文件系统的组成部分：
    - 文件系统驱动：由内核提供；
    - 文件系统管理工具：由用户空间的应用程序提供

- 删除文件：将此文件指向的所有data block标记为未使用状态；将此文件的inode标记为未使用；
- 复制：新建文件；
- 移动文件：
    - 在同一文件系统：改变的仅是其路径；
    - 在不同文件系统：复制数据至目标文件，并删除原文件；

## fdisk命令

- fdisk：manipulate disk partition table
    - fdisk -l [-u] [device...]：查看分区
    - fdisk device：管理分区，提供了一个交互式接口，有多种子命令来管理分区，其所有操作均在内存中完成，没有同步到磁盘，直到w命令保存到磁盘上
    - 常用命令：
        - n：创建新分区
        - d：删除已有分区
        - t：修改分区类型
        - l：查看所有已经ID
        - w：保存并退出
        - q：不保存并退出
        - m：查看帮助信息
        - p：显示现有分区信息
    - 注意：在已经分区并且已经挂载其中某个分区的磁盘设备上创建的新分区，内核可能在创建完成后无法直接识别，在`/proc/partitions`中查看
        - 让内核强制重读磁盘分区表
            - centos 5：partprobe [device]
            - centos 6, 7：`partx -a [device]`或者`kpartx -af [device]`
    - 分区创建工具：parted，sfdisk

## 创建文件系统

- 创建文件系统相关概念
    - 格式化：
        - 低级格式化：区分之前进行，划分磁道
        - 高级格式化：分区之后进行，创建文件系统
    - 元数据区、数据区：
        - 元数据区：
            - 文件元数据（inode，index node）：大小，权限，属主属组、时间戳，数据块指针
        - 连接文件：存储数据指针的空间当中存储的是真是文件的访问路径，没有占用的数据空间
        - 设备文件：存储数据指针的空间当中存储的是设备号，没有占用的数据空间
    - bitmap index：位图索引，记录磁盘块是否空闲等信息

- 文件系统的管理工具：
    - 创建文件系统的工具：mkfs：mkfs.ext2, mkfs.ext3, mkfs.ext4, mkfs.xfs, mkfs.vfat
    - 检测及修复文件系统的工具：fsck：sck.ext2, fsck.ext3, ...
    - 查看其属性的工具：dumpe2fs, tune2fs
    - 调整文件系统特性：tune2fs

- ext系列文件系统的创建工具：mkfs.ext[#]
    - mkfs系列文件：
        mkfs -t ext2 = mkfs.ext2
    - mke2fs：
        - mke2fs [OP] device
            - -t {ext2 | ext3 | ext4}：指定文件系统类型
                - `mkfs.ext4 = mkfs -t ext4 = mke2fs -t ext4`
            - -b {1024 | 2048 | 4096}：指定块大小
            - -L new-volume-label：指明卷标；
            - -j：创建有日志功能的文件系统ext3：
                - `mke2fs -j = mke2fs -t ext3 = mkfs -t ext3 = mkfs.ext3`
            - -i #：每多少字节创建一个inode
            - -N #：指定inode数
            - -O ：指定区特性：[^]标识关闭相关特性
                - `mke2fs -j = mke2fs -t ext3 = mkfs -t ext3 = mkfs.ext3 = mke2fs -O has_journal`
            - -m：指定预留空间占整个分区空间的百分比，默认为5%

- blkid：查看指定块设备的属性信息：
    - `blkid [-L label | -U uuid] DEVICE`
    - -L LABEL：根据LABEL定位设备
    - -U UUID：根据UUID定位设备

- e2label命令：卷标的查看与设定
    - 查看：e2label device
    - 设定：e2label device LABEL

- tune2fs：查看或修改ext系列文件系统的某些属性（adjust tunable filesystem parameters on ext2/ext3/ext4 filesystems）
    - 注意：块大小创建后不可修改；
    - tune2fs [OPTIONS] device
        - -l：查看超级块的内容；
        - 修改指定文件系统的属性：
        - -j：ext2 --> ext3；
        - -L LABEL：修改卷标；
        - -m #：调整预留空间百分比；
        - -O [^]FEATHER：开启或关闭某种特性；
            - `tune2fs -O ^has_journal /dev/sda3`
        - -o [^]mount_options：开启或关闭某种默认挂载选项
            - `tune2fs -o acl /dev/sda3`

- dumpe2fs: 显示ext系列文件系统的属性信息
    - `dumpe2fs [-h] device`

- 文件系统检测的工具（因进程意外中止或系统崩溃等原因导致定稿操作非正常终止时，可能会造成文件损坏；此时，应该检测并修复文件系统；建议，离线进行；）
    - ext系列文件系统的专用工具：
        - e2fsck : check a Linux ext2/ext3/ext4 file system
            - `e2fsck [OPTIONS]  device`
            - -y：对所有问题自动回答为yes;
            - -f：即使文件系统处于clean状态，也要强制进行检测；
    - fsck：check and repair a Linux file system.
        -t fstype：指明文件系统类型；
            - `fsck -t ext4 = fsck.ext4`
        -a：无须交互而自动修复所有错误；
        -r：交互式修复；

## 交换分区

- swap文件系统：
    - Linux上的交换分区必须使用独立的文件系统；且文件系统的System ID必须为82；
    - 创建swap设备：mkswap命令
        - `mkswap [OPTIONS] device`
            - -L LABEL：指明卷标
            - -f：强制

- 交换分区的启用和禁用：
    - 创建交换分区的命令：mkswap
        - 启用：swapon
            - `swapon [OPTION] [DEVICE]`
                - -a：定义在/etc/fstab文件中的所有swap设备；
        - 禁用：swapoff
            - `swapoff DEVICE`

## 挂载

- 挂载，mount命令和umount命令
    - 根文件系统这外的其它文件系统要想能够被访问，都必须通过“关联”至根文件系统上的某个目录来实现，此关联操作即为“挂载”；此目录即为“挂载点”；
    - 挂载点：mount_point，用于作为另一个文件系统的访问入口；
        - (1) 事先存在；
        - (2) 应该使用未被或不会被其它进程使用到的目录；
        - (3) 挂载点下原有的文件将会被隐藏；
    - mount命令：`mount [-nrw] [-t vfstype] [-o options] device dir`
        - 命令选项：
            - -r：readonly，只读挂载；
            - -w：read and write, 读写挂载；
            - -n：用于禁止设备挂载或卸载的操作会同步更新至/etc/mtab文件中，在默认情况下会更新到该文件中；
            - -t vfstype：指明要挂载的设备上的文件系统的类型；多数情况下可省略，此时mount会通过blkid来判断要挂载的设备的文件系统类型；
            - -L LABEL：挂载时以卷标的方式指明设备；`mount -L LABEL dir`
            - -U UUID：挂载时以UUID的方式指明设备；`mount -U UUID dir`
            - -o options：挂载选项
                - sync/async：同步/异步操作；
                - atime/noatime：文件或目录在被访问时是否更新其访问时间戳；
                - diratime/nodiratime：目录在被访问时是否更新其访问时间戳；
                - remount：重新挂载；
                - acl：支持使用facl功能；
                    - `# mount -o acl device dir`
                    - `# tune2fs -o acl device`
                - ro：只读
                - rw：读写
                - dev/nodev：此设备上是否允许创建设备文件；
                - exec/noexec：是否允许运行此设备上的程序文件；
                - user/nouser：是否允许普通用户挂载此文件系统；
                - suid/nosuid：是否允许程序文件上的suid和sgid特殊权限生效；
                - defaults：Use default options: rw, suid, dev, exec, auto, nouser, async, and relatime.

        - 可以实现将目录绑定至另一个目录上，作为其临时访问入口；
            - `mount --bind 源目录 目标目录`
        - 查看当前系统所有已挂载的设备：
            - `# mount`
            - `# cat /etc/mtab`
            - `# cat /proc/mounts`
        - 挂载光盘：
            - `mount -r /dev/cdrom mount_point`
            - 光盘设备文件：/dev/cdrom, /dev/dvd
        - 挂载U盘：事先识别U盘的设备文件；
        - 挂载本地的回环设备：`# mount -o loop /PATH/TO/SOME_LOOP_FILE MOUNT_POINT`
    - umount命令：
        - `umount device|dir`
        - 注意：正在被进程访问到的挂载点无法被卸载；
            - 查看被哪个或哪些进程所战用：
                - `# lsof MOUNT_POINT`
                - `# fuser -v MOUNT_POINT`
            - 终止所有正在访问某挂载点的进程：
                - `# fuser -km MOUNT_POINT`

- 设定除根文件系统以外的其它文件系统能够开机时自动挂载：使用/etc/fstab文件
    - 每行定义一个要挂载的文件系统及相关属性：6个字段：
        - (1) 要挂载的设备：
            - 设备文件；
            - LABEL
            - UUID
            - 伪文件系统：如sysfs, proc, tmpfs等
        - (2) 挂载点
            - swap类型的设备的挂载点为swap；
        - (3) 文件系统类型；
        - (4) 挂载选项
            - defaults：使用默认挂载选项；
            - 如果要同时指明多个挂载选项，彼此间以事情分隔：defaults,acl,noatime,noexec
        - (5) 转储频率
            - 0：从不备份；
            - 1：每天备份；
            - 2：每隔一天备份；
        - (6) 自检次序
            - 0：不自检；
            - 1：首先自检，通常只能是根文件系统可用1；
            - 2：次级自检
            - ...
    - mount -a：可自动挂载定义在此文件中的所支持自动挂载的设备；

- 挂载光盘设备
    - 光盘设备文件：
        - IDE: /dev/hdc
        - SATA: /dev/sr0
    - 符号链接文件：
        - /dev/cdrom
        - /dev/cdrw
        - /dev/dvd
        - /dev/dvdrw
    - 挂载命令：
        - `mount -r /dev/cdrom /media/cdrom`
        - `umount /dev/cdrom`

## df、du和dd

- df命令(disk free)：
    - `df [OPTION]... [FILE]...`
    - -l：仅显示本地文件的相关信息；
    - -h：human-readable
    - -i：显示inode的使用状态而非blocks

- du命令(查看目录下各个文件的大小)：
    - `du [OPTION]... [FILE]...`
    - -s: sumary
    - -h: human-readable

- dd命令：convert and copy a file
    - 用法：
    ```
        dd if=/PATH/FROM/SRC of=/PATH/TO/DEST
            bs=#：block size, 复制单元大小；
            count=#：复制多少个bs；
    ```
    - 磁盘拷贝：`dd if=/dev/sda of=/dev/sdb`
    - 备份MBR：`dd if=/dev/sda of=/tmp/mbr.bak bs=512 count=1`
    - 破坏MBR中的bootloader：`dd if=/dev/zero of=/dev/sda bs=256 count=1`

## others

- Windows无法识别Linux的文件系统；因此，存储设备需要两种系统之间交叉使用时，应该使用windows和Linux同时支持的文件系统：fat32(vfat)，命令：`# mkfs.vfat device`

- 两个特殊设备：
    - /dev/null: 数据黑洞；
    - /dev/zero：吐零机；

```
练习：
    1、创建一个10G的分区，并格式化为ext4文件系统；
        (1) block大小为2048；预留空间为2%，卷标为MYDATA；
        (2) 挂载至/mydata目录，要求挂载时禁止程序自动运行，且不更新文件的访问时间戳；
        (3) 可开机自动挂载；
    2、创建一个大小为1G的swap分区，并启动之；
```

## RAID

- Redundant Arrays of Inexpensive(Independent) Disks

- 优点：
    - 提高IO能力：磁盘并行读写
    - 提高耐用性；磁盘冗余来实现

- 级别：多块磁盘组织在一起的工作方式有所不同；

- RAID实现的方式：
    - 外接式磁盘阵列：通过扩展卡提供适配能力
    - 内接式RAID：主板集成RAID控制器
    - Software RAID：

### 级别：level

- [RAID](https://zh.wikipedia.org/wiki/RAID "RAID")

- RAID-0：0, 条带卷，strip，并行组织硬盘，将数据平均分散到n个硬盘
    - 读、写性能提升；
    - 可用空间：N`*`min(S1,S2,...)
    - 无容错能力
    - 最少磁盘数：2

- RAID-1: 1, 镜像卷，mirror，
    - 读性能提升、写性能略有下降；
    - 可用空间：1`*`min(S1,S2,...)
    - 有冗余能力
    - 最少磁盘数：2

- RAID-5：
    - 读、写性能提升
    - 可用空间：(N-1)`*`min(S1,S2,...)
    - 有容错能力：1块磁盘
    - 最少磁盘数：3

- RAID-6：
    - 读、写性能提升
    - 可用空间：(N-2)`*`min(S1,S2,...)
    - 有容错能力：2块磁盘
    - 最少磁盘数：4

- RAID10：
    - 读、写性能提升
    - 可用空间：N`*`min(S1,S2,...)/2
    - 有容错能力：每组镜像最多只能坏一块；
    - 最少磁盘数：4

- RAID01：
    - 读、写性能提升
    - 可用空间：N`*`min(S1,S2,...)/2
    - 有容错能力：每组镜像最多只能坏一块；
    - 最少磁盘数：4

- RAID-50, RAID-7

- JBOD：Just a Bunch Of Disks
    - 功能：将多块磁盘的空间合并一个大的连续空间使用；
    - 可用空间：sum(S1,S2,...)

- 常用级别：RAID-0, RAID-1, RAID-5, RAID-10, RAID-50, JBOD

- 实现方式：
    - 硬件实现方式
    - 软件实现方式

### CentOS 6上的软件RAID的实现

- 结合内核中的md(multi devices)

- mdadm：模式化的工具
    - 命令的语法格式：`mdadm [mode] <raiddevice> [options] <component-devices>`
        - `<raiddevice>: /dev/md#`
        - `<component-devices>`: 任意块设备
    - 支持的RAID级别：LINEAR, RAID0, RAID1, RAID4, RAID5, RAID6, RAID10;
    - 模式：
        - 创建：-C
            - -n #: 使用#个块设备来创建此RAID；
            - -l #：指明要创建的RAID的级别；
            - -a {yes|no}：自动创建目标RAID设备的设备文件；
            - -c CHUNK_SIZE: 指明块大小；
            - -x #: 指明空闲盘的个数；
            - 例如：创建一个10G可用空间的RAID5；
            - `mdadm -C /dev/md0 -a yes -n 3 -x 1 -l 5 /dev/sda{1,2,3,4}`
        - 装配: -A
        - 监控: -F
        - 管理：-f, -r, -a
            - -f: 标记指定磁盘为损坏；
            - -a: 添加磁盘
            - -r: 移除磁盘
        -D：显示raid的详细信息；
            - `mdadm -D /dev/md#`
        - 观察md的状态：`cat /proc/mdstat`
        - 停止md设备：`mdadm -S /dev/md#`

- watch命令：
    - -n #: 刷新间隔，单位是秒；
    - `watch -n# 'COMMAND'`

- 练习1：创建一个可用空间为10G的RAID1设备，要求其chunk大小为128k，文件系统为ext4，有一个空闲盘，开机可自动挂载至/backup目录；
- 练习2：创建一个可用空间为10G的RAID10设备，要求其chunk大小为256k，文件系统为ext4，开机可自动挂载至/mydata目录；

## LVM

- Logical Volume Manager, Version 2

- https://www.linuxidc.com/Linux/2017-05/143724.htm

- dm: device mapper，将一个或多个底层块设备组织成一个逻辑设备的模块；
    - 其真正文件为：`/dev/dm-#`
    - 两个链接访问路径
        - /dev/mapper/VG_NAME-LV_NAME
            - /dev/mapper/vol0-root
        - /dev/VG_NAME/LV_NAME# 链接名称
            - /dev/vol0/root

- pv管理工具：
    - pvs：简要pv信息显示
    - pvdisplay：显示pv的详细信息
    - pvcreate /dev/DEVICE: 创建pv
    - pvremote /dev/DEVICE

- vg管理工具：
    - vgs
    - vgdisplay
    - vgcreate  [-s #[kKmMgGtTpPeE]] VolumeGroupName  PhysicalDevicePath [PhysicalDevicePath...]
    - vgextend  VolumeGroupName  PhysicalDevicePath [PhysicalDevicePath...]
    - vgreduce  VolumeGroupName  PhysicalDevicePath [PhysicalDevicePath...]
        - 先做pvmove
    - vgremove

- lv管理工具：
    - lvs
    - lvdisplay
    - lvcreate -L #[mMgGtT] -n NAME VolumeGroup
    - lvremove /dev/VG_NAME/LV_NAME
    - 扩展逻辑卷：
        - lvextend -L [+]#[mMgGtT] /dev/VG_NAME/LV_NAME # 扩展lv
        - resize2fs /dev/VG_NAME/LV_NAME                # 扩展文件系统
    - 缩减逻辑卷：
        - umount /dev/VG_NAME/LV_NAME                       # 卸载文件系统
        - e2fsck -f /dev/VG_NAME/LV_NAME                    # 强制文件系统检测
        - resize2fs /dev/VG_NAME/LV_NAME #[mMgGtT]          # 缩减其文件系统
        - lvreduce -L [-]#[mMgGtT] /dev/VG_NAME/LV_NAME     # 缩减lv
        - mount                                             # 挂载文件系统

- 快照：snapshot
    - lvcreate -L #[mMgGtT] -p r -s -n snapshot_lv_name original_lv_name

```
练习1：创建一个至少有两个PV组成的大小为20G的名为testvg的VG；要求PE大小为16MB, 而后在卷组中创建大小为5G的逻辑卷testlv；挂载至/users目录；
练习2： 新建用户archlinux，要求其家目录为/users/archlinux，而后su切换至archlinux用户，复制/etc/pam.d目录至自己的家目录；
练习3：扩展testlv至7G，要求archlinux用户的文件不能丢失；
练习4：收缩testlv至3G，要求archlinux用户的文件不能丢失；
练习5：对testlv创建快照，并尝试基于快照备份数据，验正快照的功能；
key: https://blog.51cto.com/arm2012/1955817
```

## btrfs文件系统

- [btrfs的新手指南](https://www.howtoing.com/a-beginners-guide-to-btrfs "btrfs的新手指南")

- 其为：Btrfs (B-tree, Butter FS, Better FS), GPL, Oracle, 2007, CoW, 技术预览版

- ext3/ext4, xfs

- 核心特性：
    - 多物理卷支持：btrfs可由多个底层物理卷组成；支持RAID，以联机“添加”、“移除”，“修改”；
    - 写时复制更新机制(CoW)：复制、更新及替换指针，而非“就地”更新；
    - 数据及元数据校验码：checksum
    - 子卷：sub_volume
    - 快照：支持快照的快照；
    - 透明压缩：

- 文件系统创建：mkfs.btrfs
    - -L 'LABEL'
    - -d <type>: raid0, raid1, raid5, raid6, raid10, single，数据如何实现跨多设备存放的
    - -m <profile>: raid0, raid1, raid5, raid6, raid10, single, dup, 元数据如何存放
    - -O <feature>: 所支持一些扩展特性
        - -O list-all: 列出支持的所有feature；

- 属性查看：btrfs filesystem show
- 挂载文件系统：mount -t btrfs /dev/sdb MOUNT_POINT
- 透明压缩机制：mount -o compress={lzo|zlib} DEVICE MOUNT_POINT
- 动态增减空间：btrfs filesystem resize {{+|-}5G|max} MOUNT_POINT
- 子命令：filesystem, device, balance, subvolume

# 一些命令

```sh
/opt/MegaRAID/MegaCli/MegaCli -pdlist -aall
/opt/MegaRAID/MegaCli/MegaCli  -LDInfo -Lall -aALL
cat /etc/fstab
fdisk -l
fdisk /dev/sdb
mount
mkfs.xfs /dev/sdb1
mount /dev/sdb1 /mysqldata/
blkid
```
