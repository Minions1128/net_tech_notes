# 虚拟化技术

## 概述

- 虚拟化技术类型:
    - 主机虚拟化: xen, kvm, virtualbox
    - 容器(用户空间隔离): lxc(LinuX Container), openvz, libcontainer, runC, rkt, Linux V Servers, Virtuozzo
    - 系统库虚拟化: wine
    - 应用程序级虚拟化: jvm, pvm
    - 模拟, Emulation: Qemu, PearPC, Bochs
    - 云栈的类别: IaaS, PaaS, SaaS, FWaaS, DBaaS, LBaaS

### 主机虚拟化

- CPU
    - 模拟: emulation, 虚拟机的arch与物理平台的arch可以不相同; qemu;
    - 虚拟: virtualization
        - 完全虚拟化(full-virt): VMWare Workstation, VirtualBox, VMWare Server, Parallels Desktop, KVM(hvm), XEN(hvm)
            - BT: 二进制转换 (软件)
            - HVM: 硬件辅助的虚拟化(硬件)
        - 半(准)虚拟化 (para-virt): GuestOS得明确知道自己运行于虚拟化技术, xen, UML(user-mode linux)

- qemu
    - 处理器模拟器
    - 仿真各种IO设备
    - 将仿真设备连接至主机的物理设备
    - 提供用户接口

- 内存
    - MMU virtualization:
        - Intel: EPT, Extended Page Table
        - AMD: NPT, Nested Page Table
    - TLB virtualization: tagged TLB

- IO
    - Emulation
    - Para-virtualization
    - IO-through: IO透传

- 主机虚拟化的类型
    - TYPE-I:
        - 于硬件级别直接运行hypervisor;
        - xen, vmware ESX/ESXI
    - TYPE-II:
        - 于硬件级别运行一个OS(Host OS), 而此OS上运行一个VMM;
        - vmware workstation, virtualbox, kvm

## KVM

- Kernel-based Virtual Machine, Qumranet公司 --> RedHat
    - (1) X86_64
    - (2) HVM: Intel VT, AMD AMD-v

- KVM的组件
    - kvm.ko: 模块, (kvm.ko)/dev/kvm:, 工作为hypervisor, 在用户空间可通过系统调用ioctl()与内核中的kvm模块交互, 从而完成虚拟机的创建, 启动, 停止, 删除等各种管理功能;
    - qemu-kvm: qemu-kvm is an open source virtualizer that provides hardware emulation for the KVM hypervisor. 用户空间的工具程序; 工作于用户空间, 用于实现IO设备模拟; 用于实现一个虚拟机实例;
    - libvirt: Libvirt is a C toolkit to interact with the virtualization capabilities of recent versions of Linux (and other OSes). The main package includes the libvirtd server exporting the virtualization support. 其为C/S:
        - Client:
            - libvirt-client
            - virt-manager
        - Daemon: libvirt-daemon

- 安装
    - 判断CPU是否支持硬件虚拟化: `grep -i -E '(vmx|svm|lm)' /proc/cpuinfo`
        - vmx: Intel VT-x
        - svm: AMD AMD-v

```sh
yum install libvirt-daemon-kvm qemu-kvm virt-manager
modprobe kvm # 装载内核模块, kvm-intel|kvm-amd
systemctl start libvirtd.service
virsh iface-bridge INTERFACE BRIDGE_NAME
virt-manager &
```

- 网络虚拟化:
    - 二层的虚拟网络设备:
        - kernel net bridge/brctl
        - openvswitch
    - CentOS 7创建物理桥, 使用内核自带的桥接模块实现:
        - 桥接口配置文件保留地址信息;
            - TYPE=Bridge
            - Device=BRIDGE_NAME
        - 物理网卡配置文件:
            - 删除地址, 掩码和网关等相关的配置, 添加`BRIDGE=BRIDGE_NAME`
        - 重启网络服务

- KVM模块load进内存之后, 系统的运行模式:
    - 内核模式: GuestOS执行IO类的操作时, 或其它的特殊指令操作时的模式; 它也被称为“Guest-Kernel”模式;
    - 用户模式: Host OS的用户空间, 用于代为GuestOS发出IO请求;
    - 来宾模式: GuestOS的用户模式; 所有的非IO类请求;

- 运行中的一个kvm虚拟机就是一个qemu-kvm进程, 运行qemu-kvm程序并传递给它合适的选项及参数即能完成虚拟机启动, 终止此进程即能关闭虚拟机;

- kvm工具栈:
    - qemu:
        - qemu-kvm
        - qemu-img
    - libvirt:
        - GUI: virt-manager, virt-viewer
        - CLI: virsh, virt-install
            - C/S: libvirtd

### 使用qemu-kvm管理vms

- qemu-kvm命令语法: `qemu-kvm [options] [disk_image]`

- options: 标准选项, 块设备相关选项, 显示选项, 网络选项, ...
    - 标准选项:
        - -machine [type=]name: -machine help来获取列表, 用于指定模拟的主机类型;
        - -cpu cpu: -cpu help来获取列表; 用于指定要模拟的CPU型号;
        - -smp n[,maxcpus=cpus][,cores=cores][,threads=threads][,sockets=sockets]: 指明虚拟机上vcpu的数量及拓扑;
        - -boot [order=drives][,once=drives][,menu=on|off] [,splash=sp_name][,splash-time=sp_time][,reboot-timeout=rb_time][,strict=on|off]
            - - order: 各设备的引导次序: c表示第一块硬盘, d表示第一个光驱设备; -boot order=dc,once=d
        - -m megs: 虚拟机的内存大小;
        - -name NAME: 当前虚拟机的名称, 要惟一;
    - 块设备相关的选项:
        - -hda/-hdb file: 指明IDE总线类型的磁盘映射文件路径; 第0和第1个;
        - -hdc/-hdd file: 第2和第3个;
        - -cdrom file: 指定要使用光盘映像文件;
        - -drive [file=file][,if=type][,media=d][,index=i] [,cache=writethrough|writeback|none|directsync|unsafe][,format=f]:
            - file=/PATH/TO/SOME_IMAGE_FILE: 映像文件路径;
            - if=TYPE: 块设备总线类型, ide, scsi, sd, floppy, virtio,...
            - media=TYPE: 介质类型, cdrom和disk;
            - index=i: 设定同一类型设备多个设备的编号;
            - cache=writethrough|writeback|none|directsync|unsafe: 缓存方式;
            - format=f: 磁盘映像文件的格式;
    - 显示选项:
        - -display type: 显示的类型, sdl, curses, none和vnc;
        - -nographic: 不使用图形接口;
        - -vga [std|cirrus|vmware|qxl|xenfb|none]: 模拟出的显卡的型号;
        - -vnc display[,option[,option[,...]]]]: 启动一个vnc server来显示虚拟机接口;  让qemu进程监听一个vnc接口;
            - display:
                - (1) HOST:N; 在HOST主机的第N个桌面号输出vnc; 5900+N
                - (2) unix:/PATH/TO/SOCK_FILE
                - (3) none
            - options:
                - password: 连接此服务所需要的密码;
                - -monitor stdio: 在标准输出上显示monitor界面;
                    - Ctrl-a, c: 在console和monitor之间切换;
                    - Ctrl-a, h
    - 网络选项:
        - -net nic[,vlan=n][,macaddr=mac][,model=type][,name=str][,addr=str][,vectors=v]: 为虚拟机创建一个网络接口, 并将其添加至指定的VLAN;
            - model=type: 指明模拟出的网卡的型号, ne2k_pci,i82551,i82557b,i82559er,rtl8139,e1000,pcnet,virtio;
            - macaddr=mac: 指明mac地址; 52:54:00:
        - -net tap[,vlan=n][,name=str][,fd=h][,fds=x:y:...:z][,ifname=name][,script=file][,downscript=dfile]: 通过物理的TAP网络接口连接至vlan n;
            - script=file: 启动虚拟机时要执行的脚本, 默认为/etc/qemu-ifup
            - downscript=dfile: 关闭虚拟机时要执行的脚本, /etc/qemu-ifdown
            - ifname=NAME: 自定义接口名称;
    - 其它选项: -daemonize: 以守护进程运行;

- 示例1: `qemu-kvm -name c2 -smp 2,maxcpus=4,sockets=2,cores=2 -m 128 -drive file=/images/kvm/cos-i386.qcow2,if=virtio -vnc  :1 -daemonize -net nic,model=e1000,macaddr=52:54:00:00:00:11 -net tap,script=/etc/qemu-ifup`

- 示例2: `qemu-kvm -name winxp -smp 1,maxcpus=2,sockets=1,cores=2 -m 1024 -drive file=/data/vms/winxp.qcow2,media=disk,cache=writeback,format=qcow2 file=/tmp/winxp.iso,media=cdrom -boot order=dc,once=d -vnc :1 -net nic,model=rtl8139,macaddr=52:54:00:00:aa:11 -net tap,ifname=tap1,script=/etc/qemu-ifup -daemonize`

```sh
cat /etc/qemu-ifup

#!/bin/bash
bridge=br0
if [ -n "$1" ];then
    ip link set $1 up
    sleep 1
    brctl addif $bridge $1
    [ $? -eq 0 ] && exit 0 || exit 1
else
    echo "Error: no interface specified."
    exit 1
fi
```

- 半虚拟化: virtio; 建议: Network IO, Disk IO使用virtio, 性能会有显著提升;

### virsh命令

- 虚拟机的生成需要依赖于预定义的xml格式的配置文件; 其生成工具有两个: virt-manager, virt-install;

- `virsh [OPTION]... COMMAND [ARG]..`

- 子命令的分类:
    - Domain Management (help keyword 'domain')
        - create: 从xml格式的配置文件创建并启动虚拟机;
        - define: 从xml格式的配置文件创建虚拟机;
        - destroy: 强行关机;
        - shutdown: 关机;
        - reboot: 重启;
        - undefine: 删除虚拟机;
        - suspend/resume: 暂停于内存中, 或继续运行暂停状态的虚拟机;
        - save/restore: 保存虚拟机的当前状态至文件中, 或从指定文件恢复虚拟机;
        - console: 连接至指定domain的控制台;
        - attach-disk/detach-disk: 磁盘设备的热插拔;
        - attach-interface/detach-interface: 网络接口设备的热插拔;
            - type: bridge
            - source: BRIDGE_NAME
            - 注意: 无须事先创建网络接口设备;
    - Domain Monitoring (help keyword 'monitor')
        - domiflist
        - domblklist
    - Host and Hypervisor (help keyword 'host')
    - Interface (help keyword 'interface')
    - Networking (help keyword 'network')
    - Network Filter (help keyword 'filter')
    - Snapshot (help keyword 'snapshot')
    - Storage Pool (help keyword 'pool')
    - Storage Volume (help keyword 'volume')

### 图形管理工具

- kimchi: 基于H5研发web GUI; virt-king;

- OpenStack: IaaS

- oVirt:
