# CentOS系统启动流程

Linux系统的组成部分:
    - 内核:
        - 进程管理
        - 内存管理
            - IPC: Inter Process Communication
                - 消息队列, semerphor, shm
                - socket
        - 网络协议栈, 文件系统, 驱动程序, 安全功能
    - 根文件系统

- 运行中的系统环境可分为两层:
    - 用户空间: 应用程序（进程或线程）
    - 内核空间: 内核代码（系统调用）

- 内核设计流派:
    - 单内核设计: 把所有功能集成于同一个程序 - Linux
    - 微内核设计: 每种功能使用一个单独的子系统实现 - Windows, Solaris

- Linux内核特点:
    - 支持模块化: .ko (kernel object)
    - 支持模块运行时动态装载或卸载;
    - 组成部分:
        - 核心文件: /boot/vmlinuz-VERSION-release
        - ramdisk(临时根):
            - CentOS 5: /boot/initrd-VERSION-release.img
            - CentOS 6,7: /boot/initramfs-VERSION-release.img
        - 模块文件: /lib/modules/VERSION-release

- CentOS 系统的启动流程:
    - 系统初始化流程（内核级别）: POST --> BootSequence(BIOS) --> BootLoader（MBR）--> Kernel（ramdisk）--> rootfs（readonly）--> /sbin/init ()
    - POST: Power On and Self Test
        - ROM: CMOS, 加载自检程序
    - Boot Sequence: 按次序查找各引导设备, 第一个有引导程序的设备即为本次启动要用到的设备;
        - bootloader: 引导加载器, 程序;
            - 功能: 提供一个菜单, 允许用户选择要启动的系统或不同的内核版本; 把用户选定的内核装载到RAM中的特定空间中, 解压, 展开, 而后把系统控制权移交给内核;
            - Windows: ntloader
            - Linux:
                - LILO: LIinux  LOader
                - GRUB: Grand Uniform Bootloader
                    - GRUB 0.X: Grub Legacy
                    - GRUB 1.X: Grub2
            - MBR: Master Boot Record, 512bytes:
                - 446bytes: bootloader
                - 64bytes: fat
                - 2bytes: 55AA
            - GRUB: 可以在操作系统之前提供一个交互式系统
                - bootloader: 1st stage, 为了加载第二阶段
                - Partition: filesystem driver, 1.5 stage,
                - Partition: /boot/grub, 2nd stage, 加载操作系统内核文件
        - Kernel:
            - 自身初始化:
                - 探测可识别到的所有硬件设备;
                - 加载硬件驱动程序; （有可能会借助于ramdisk加载驱动）
                - 以只读方式挂载根文件系统;
                - 运行用户空间的第一个应用程序: /sbin/init
            - init程序的类型:
                - CentOS 5-: SysV init
                    - 配置文件: /etc/inittab
                - CentOS 6: Upstart
                    - 配置文件: /etc/inittab, `/etc/init/*.conf`
                - CentOS 7: Systemd
                    - 配置文件: /usr/lib/systemd/system/, /etc/systemd/system/
            - ramdisk: Linux内核的特性之一, 使用缓冲和缓存来加速对磁盘上的文件访问;
                - ramdisk --> ramfs
                - CentOS 5: initrd
                    - 工具程序: mkinitrd
                - CentOS 6,7: initramfs
                    - 工具程序: dracut, mkinitrd
- /sbin/init:
    - CentOS 5: SysV init
        - 运行级别: 为了系统的运行或维护等目的而设定的机制, 0-6: 7个级别;
            - 0: 关机, shutdown
            - 1: 单用户模式(single user), root用户, 无须认证; 维护模式;
            - 2: 多用户模式(multi user), 会启动网络功能, 但不会启动NFS; 维护模式;
            - 3: 多用户模式(mutli user), 完全功能模式; 文本界面;
            - 4: 预留级别: 目前无特别使用目的, 但习惯以同3级别功能使用;
            - 5: 多用户模式(multi user), 完全功能模式, 图形界面;
            - 6: 重启, reboot
            - 默认级别: 3, 5
            - 级别切换: `init #`
            - 级别查看:
                - `who -r`
                - `runlevel`
        - 配置文件: /etc/inittab
            - 每行定义一种action以及与之对应的process
            - id:runlevels:action:process
                - id: 一个任务的标识符;
                - runlevels: 在哪些级别启动此任务; #; ###; 也可以为空, 表示所有级别;
                - action: 在什么条件下启动此任务;
                    - wait: 等待切换至此任务所在的级别时执行一次;
                    - respawn: 一旦此任务终止, 就自动重新启动之;
                    - initdefault: 设定默认运行级别; 此时, process省略;
                    - sysinit: 设定系统初始化方式, 此处一般为指定/etc/rc.d/rc.sysinit脚本;
                - process: 任务;
                - rc脚本: 接受一个运行级别数字为参数;
            - 例如:
                ```sh
                id:3:initdefault:   # 设定默认运行界别是3
                si::sysinit:/etc/rc.d/rc.sysinit    # 设定系统初始化方式
                l0:0:wait:/etc/rc.d/rc  3
                # 意味着去启动或关闭/etc/rc.d/rc3.d/目录下的服务脚本所控制服务;
                    # K*: 要停止的服务; K##*, 优先级, 数字越小, 越是优先关闭; 依赖的服务先关闭, 而后关闭被依赖的;
                    # S*: 要启动的服务; S##*, 优先级, 数字越小, 越是优先启动; 被依赖的服务先启动, 而依赖的服务后启动;
                ```
            - `/etc/init.d/* (/etc/rc.d/init.d/*)`脚本执行方式:
                - /etc/init.d/SRV_SCRIPT {start|stop|restart|status}
                - service     SRV_SCRIPT {start|stop|restart|status}
            - chkconfig命令:
                - 管控/etc/init.d/每个服务脚本在各级别下的启动或关闭状态;
                - 查看: chkconfig  --list [name]
                - 添加: chkconfig  --add  name
                - 能被添加的服务的脚本定义格式之一, 包含举例:
                    ```sh
                    #!/bin/bash
                    # testsrv       service testing script
                    # chkconfig: 2345 50 60

                    prog=$(basename $0)

                    usage() {
                        echo "Usage: $prog {start|stop|status|restart}"
                        exit 1
                    }

                    if [ $# -lt 1 ]; then
                        usage
                    fi

                    if [ $1 == "start" ]; then
                        echo "start $prog successfully."
                    elif [ $1 == "stop" ]; then
                        echo "stop $prog successfully."
                    elif [ $1 == "restart" ]; then
                        echo "stop $prog successfully."
                        sleep 1
                        echo "start $prog successfully."
                    elif [ $1 == "status" ]; then
                        if pidof $prog &> /dev/null; then
                            echo "$prog is running."
                        else
                            echo "$prog is not running."
                        fi
                    else
                        usage
                    fi
                    ```
                - 删除: chkconfig  --del  name
                    - 修改指定的链接类型:
                        - `chkconfig  [--level  LEVELS]  name  <on|off|reset>`
                            - --level LEVELS: 指定要控制的级别; 默认为2345;
                - 开启, 关闭: chkconfig name {on|off}
                - 注意: 正常级别下, 最后启动的一个服务S99local没有链接至/etc/init.d下的某脚本, 而是链接至了/etc/rc.d/rc.local (/etc/rc.local)脚本; 因此, 不便或不需写为服务脚本的程序期望能开机自动运行时, 直接放置于此脚本文件中即可。
                - 其他例子:
                    ```
                    tty1:2345:respawn:/usr/sbin/mingetty tty1
                    ... ...
                    tty6:2345:respawn:/usr/sbin/mingetty tty6
                        （1）mingetty会调用login程序;
                        （2）打开虚拟终端的程序除了mingetty之外, 还有诸如getty等;
                    ```
                - 系统初始化脚本: /etc/rc.d/rc.sysinit
                    - (1) 设置主机名;
                    - (2) 设置欢迎信息;
                    - (3) 激活udev和selinux;
                    - (4) 挂载/etc/fstab文件中定义的所有文件系统;
                    - (5) 检测根文件系统, 并以读写方式重新挂载根文件系统;
                    - (6) 设置系统时钟;
                    - (7) 根据/etc/sysctl.conf文件来设置内核参数;
                    - (8) 激活lvm及软raid设备;
                    - (9) 激活swap设备;
                    - (10) 加载额外设备的驱动程序;
                    - (11) 清理操作;
        - 总结（用户空间的启动流程）: /sbin/init (/etc/inittab): 设置默认运行级别 --> 运行系统初始化脚本, 完成系统初始化 --> 关闭对应级别下需要停止的服务, 启动对应级别下需要开启的服务--> 设置登录终端 [--> 启动图形终端]
    - CentOS 6:
        - init程序: upstart, 但依然为/sbin/init, 其配置文件: `/etc/init/*.conf`, `/etc/inittab`（仅用于定义默认运行级别）
            - 注意: `*.conf`为upstart风格的配置文件;
                - rcS.conf
                - rc.conf
                - start-ttys.conf
    - CentOS 7:
        - init程序: systemd, 配置文件: `/usr/lib/systemd/system/*`, `/etc/systemd/system/*`
        - 完全兼容SysV脚本机制; 因此, service命令依然可用; 不过, 建议使用systemctl命令来控制服务;
            - `systemctl {start|stop|restart|status} name[.service]`
