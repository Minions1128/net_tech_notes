# RAID

- Redundant Arrays of Inexpensive(Independent) Disks

- 优点：
    - 提高IO能力：磁盘并行读写
    - 提高耐用性；磁盘冗余来实现

- 级别：多块磁盘组织在一起的工作方式有所不同；

- RAID实现的方式：
    - 外接式磁盘阵列：通过扩展卡提供适配能力
    - 内接式RAID：主板集成RAID控制器
    - Software RAID：

## 级别：level

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

- RAID-4：1101, 0110, 1011
    - 
- RAID-5：
RAID-6
RAID10
RAID01



        RAID-5：
            读、写性能提升
            可用空间：(N-1)*min(S1,S2,...)
            有容错能力：1块磁盘
            最少磁盘数：3, 3+

        RAID-6：
            读、写性能提升
            可用空间：(N-2)*min(S1,S2,...)
            有容错能力：2块磁盘
            最少磁盘数：4, 4+

        
        混合类型
            RAID-10：
                读、写性能提升
                可用空间：N*min(S1,S2,...)/2
                有容错能力：每组镜像最多只能坏一块；
                最少磁盘数：4, 4+
            RAID-01:

            RAID-50、RAID7

            JBOD：Just a Bunch Of Disks
                功能：将多块磁盘的空间合并一个大的连续空间使用；
                可用空间：sum(S1,S2,...)

        常用级别：RAID-0, RAID-1, RAID-5, RAID-10, RAID-50, JBOD

        实现方式：
            硬件实现方式
            软件实现方式 

            CentOS 6上的软件RAID的实现：
                结合内核中的md(multi devices)

                mdadm：模式化的工具
                    命令的语法格式：mdadm [mode] <raiddevice> [options] <component-devices>
                        支持的RAID级别：LINEAR, RAID0, RAID1, RAID4, RAID5, RAID6, RAID10; 

                    模式：
                        创建：-C
                        装配: -A
                        监控: -F
                        管理：-f, -r, -a

                    <raiddevice>: /dev/md#
                    <component-devices>: 任意块设备


                    -C: 创建模式
                        -n #: 使用#个块设备来创建此RAID；
                        -l #：指明要创建的RAID的级别；
                        -a {yes|no}：自动创建目标RAID设备的设备文件；
                        -c CHUNK_SIZE: 指明块大小；
                        -x #: 指明空闲盘的个数；

                        例如：创建一个10G可用空间的RAID5；

                    -D：显示raid的详细信息；
                        mdadm -D /dev/md#

                    管理模式：
                        -f: 标记指定磁盘为损坏；
                        -a: 添加磁盘
                        -r: 移除磁盘

                    观察md的状态：
                        cat /proc/mdstat

                    停止md设备：
                        mdadm -S /dev/md#

                watch命令：
                    -n #: 刷新间隔，单位是秒；

                    watch -n# 'COMMAND'

        练习1：创建一个可用空间为10G的RAID1设备，要求其chunk大小为128k，文件系统为ext4，有一个空闲盘，开机可自动挂载至/backup目录；
        练习2：创建一个可用空间为10G的RAID10设备，要求其chunk大小为256k，文件系统为ext4，开机可自动挂载至/mydata目录；

博客作业：raid各级别特性；
