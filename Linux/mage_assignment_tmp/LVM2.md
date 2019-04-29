# LVM

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
