# btrfs文件系统

技术预览版

Btrfs (B-tree, Butter FS, Better FS), GPL, Oracle, 2007, CoW; 
ext3/ext4, xfs
核心特性：
    多物理卷支持：btrfs可由多个底层物理卷组成；支持RAID，以联机“添加”、“移除”，“修改”；
    写时复制更新机制(CoW)：复制、更新及替换指针，而非“就地”更新；
    数据及元数据校验码：checksum
    子卷：sub_volume
    快照：支持快照的快照；
    透明压缩：
文件系统创建：
    mkfs.btrfs
        -L 'LABEL'
        -d <type>: raid0, raid1, raid5, raid6, raid10, single
        -m <profile>: raid0, raid1, raid5, raid6, raid10, single, dup
        -O <feature>
            -O list-all: 列出支持的所有feature；
    属性查看：
        btrfs filesystem show 
    挂载文件系统：
        mount -t btrfs /dev/sdb MOUNT_POINT
    透明压缩机制：
        mount -o compress={lzo|zlib} DEVICE MOUNT_POINT
子命令：filesystem, device, balance, subvolume
