# CentOS 系统安装

- 安装程序: anaconda
    - bootloader --> kernel(initrd(rootfs)) --> anaconda
    - tui: 基于cureses的文本配置窗口
    - gui: 图形界面

- CentOS的安装过程启动流程:
    - MBR: boot.cat
    - Stage2: isolinux/isolinux.bin
        - 配置文件: isolinux/isolinux.cfg
        - 每个对应的菜单选项:
            - 加载内核: isolinux/vmlinuz
            - 向内核传递参数: append initrd=initrd.img
        - 装载根文件系统, 并启动anaconda
            - 默认界面是图形界面: 512MB+内存空间;
            - 若需要显式指定启动TUI接口:  向启动内核传递一个参数"text"即可;
            - ESC --> boot: linux  text
        - 注意: 上述内容一般位于引导设备, 例如可通过光盘, U盘或网络等; 后续的anacona及其安装用到的程序包等可以来自于程序包仓库, 此仓库的位置可以为:
            - 本地光盘
            - 本地硬盘
            - ftp server
            - http server
            - nfs server
            - 如果想手动指定安装仓库: ESC --> boot: linux method

- anaconda的工作过程:
    - 安装前配置阶段
        - 安装过程使用的语言;
        - 键盘类型
        - 安装目标存储设备
            - Basic Storage: 本地磁盘
            - Special Storage: iSCSI
        - 设定主机名
        - 配置网络接口
        - 时区
        - 管理员密码
        - 设定分区方式及MBR的安装位置;
        - 创建一个普通用户;
        - 选定要安装的程序包;
    - 安装阶段
        - 在目标磁盘创建分区并执行格式化;
        - 将选定的程序包安装至目标位置;
        - 安装bootloader;
    - 首次启动
        - iptables
        - selinux
        - core dump

- anaconda的配置方式:
    - (1) 交互式配置方式;
    - (2) 支持通过读取配置文件中事先定义好的配置项自动完成配置; 遵循特定的语法格式, 此文件即为kickstart文件;

- 安装引导选项: boot:
    - text: 文本安装方式
    - method: 手动指定使用的安装方法
    - 与网络相关的引导选项:
        - ip=IPADDR
        - netmask=MASK
        - gateway=GW
        - dns=DNS_SERVER_IP
    - 远程访问功能相关的引导选项:
        - vnc
        - vncpassword='PASSWORD'
    - 启动紧急救援模式: rescue
    - 装载额外驱动: d
    - whats more: www.redhat.com/docs, 《installation guide》

- el6 安装引导选项: ks: 指明kickstart文件的位置;
    - DVD drive: ks=cdrom:/PATH/TO/KICKSTART_FILE
    - Hard Drive: ks=hd:/DEVICE/PATH/TO/KICKSTART_FILE
    - HTTP Server: ks=http://HOST[:PORT]/PATH/TO/KICKSTART_FILE
    - FTP Server: ks=ftp://HOST[:PORT]/PATH/TO/KICKSTART_FILE
    - HTTPS Server: ks=https://HOST[:PORT]/PATH/TO/KICKSTART_FILE

## kickstart

- kickstart 文件的格式
    - 命令段: 指定各种安装前配置选项, 如键盘类型等;
        - 必备命令
        - 可选命令
    - 程序包段: 指明要安装程序包, 以及包组, 也包括不安装的程序包;
        - `%packages`
        - `@group_name`
        - `package`
        - `-package`
        - `%end`
    - 脚本段:
        - `%pre`: 安装前脚本; 运行环境: 运行安装介质上的微型Linux系统环境;
        - `%post`: 安装后脚本; 运行环境: 安装完成的系统;

- 命令段中的必备命令:
    - authconfig: 认证方式配置, `authconfig --enableshadow --passalgo=sha512`
    - bootloader: 定义 bootloader 的安装位置及相关配置, `bootloader --location=mbr --driveorder=sda --append="crashkernel=auto rhgb quiet"`
    - keyboard: 设置键盘类型, `keyboard us`
    - lang: 语言类型, `lang zh_CN.UTF-8`
    - part: 分区布局
        - `part /boot --fstype=ext4 --size=500`
        - `part pv.008002 --size=51200`
    - rootpw: 管理员密码, `rootpw --iscrypted $6$4Yh15kMGDWOPtbbW$SGax4DsZwDAz4201.O97WvaqVJfHcISsSQEokZH054juNnoBmO/rmmA7H8ZsD08.fM.Z3Br/67Uffod1ZbE0s.`
    - timezone: 时区, `timezone Asia/Shanghai`

- 补充: 分区相关的其它指令
    - clearpart: 清除分区, `clearpart --none --drives=sda`: 清空磁盘分区;
    - volgroup: 创建卷组, `volgroup myvg --pesize=4096 pv.008002`
    - logvol: 创建逻辑卷, `logvol /home --fstype=ext4 --name=lv_home --vgname=myvg --size=5120`

- 生成加密密码的方式:

```sh
openssl passwd -1 -salt `openssl rand -hex 4`
```

- 可选命令:
    - install OR upgrade: 安装或升级;
    - text: 安装界面类型, text为tui, 默认为GUI
    - network: 配置网络接口, `network --onboot yes --device eth0 --bootproto dhcp --noipv6`
    - firewall: 防火墙, `firewall --disabled`
    - selinux: SELinux, `selinux --disabled`
    - halt, poweroff 或 reboot: 安装完成之后的行为;
    - repo: 指明安装时使用的repository, `repo --name="CentOS" --baseurl=cdrom:sr0 --cost=100`
    - url: 指明安装时使用的repository, 但为url格式, `url --url=http://172.16.0.1/cobbler/ks_mirror/CentOS-6.7-x86_64/`

- 参考官方文档: 《Installation Guide》

- 系统安装完成之后禁用防火墙:
    - CentOS 6:
        - `service   iptables stop`
        - `chkconfig iptables off`
    - CentOS 7:
        - `systemctl stop    firewalld.service`
        - `systemctl disable firewalld.service`

- 系统安装完成后禁用SELinux:
    - 编辑/etc/sysconfig/selinux或/etc/selinux/config文件, 修改SELINUX参数的值为下面其中之一:
        - permissive
        - disabled
    - 立即生效:
        - # getenforce
        - # setenforce  0

- 定制kickstart文件:

```sh
yum install  system-config-kickstart
system-config-kickstart

# 检查语法错误:
ksvalidator
```

- 创建光盘镜像:

```sh
mkisofs -R -J -T -v --no-emul-boot \
    --boot-load-size 4 --boot-info-table \
    -V "CentOS 6 x86_64 boot" \
    -c isolinux/boot.cat \
    -b isolinux/isolinux.bin \
    -o /root/boot.iso myboot/
```
