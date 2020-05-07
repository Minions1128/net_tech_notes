# GRUB(Boot Loader)

- grub: GRand Unified Bootloader
    - grub 0.x: grub legacy
    - grub 1.x: grub2

- grub legacy:
    - 配置文件: `/boot/grub/grub.conf`, `/etc/grub2.cfg -> ../boot/grub2/grub.cfg`
    - stage1: mbr
    - stage1_5: mbr之后的扇区, 让stage1中的bootloader能识别stage2所在的分区上的文件系统;
    - stage2: 磁盘分区(/boot/grub/), stage2及内核等通常放置于一个基本磁盘分区; 功用:
        - (1) 提供菜单、并提供交互式接口
            - e: 编辑模式, 用于编辑菜单;
            - c: 命令模式, 交互式接口;
        - (2) 加载用户选择的内核或操作系统
            - 允许传递参数给内核
            - 可隐藏此菜单
        - (3) 为菜单提供了保护机制
            - 为编辑菜单进行认证
            - 为启用内核或操作系统进行认证

- grub的命令行接口
    - help: 获取帮助列表
    - help KEYWORD: 详细帮助信息
    - find (hd#,#) `/PATH/TO/SOMEFILE`:
    - root (hd#,#): 设置跟设备
    - kernel /PATH/TO/KERNEL_FILE: 设定本次启动时用到的内核文件; 额外还可以添加许多内核支持使用的cmdline参数;
        - 例如: init=/path/to/init, selinux=0
    - initrd /PATH/TO/INITRAMFS_FILE: 设定为选定的内核提供额外文件的ramdisk;
    - boot: 引导启动选定的内核;
    - 手动在grub命令行接口启动系统:
        ```
        grub> root (hd#,#)
        grub> kernel /vmlinuz-VERSION-RELEASE ro root=/dev/DEVICE
        grub> initrd /initramfs-VERSION-RELEASE.img
        grub> boot
        ```

- 如何识别设备: (hd#,#)
    - hd#: 磁盘编号, 用数字表示; 从0开始编号
    - #: 分区编号, 用数字表示; 从0开始编号
    - (hd0,0), 第一个磁盘的第0个分区

- 配置文件: /boot/grub/grub.conf: 配置项:
    - default=#: 设定默认启动的菜单项; 落单项(title)编号从0开始;
    - timeout=#: 指定菜单项等待选项选择的时长;
    - splashimage=(hd#,#)/PATH/TO/XPM_PIC_FILE: 指明菜单背景图片文件路径;
    - hiddenmenu: 隐藏菜单;
    - password [--md5] STRING: 菜单编辑认证;
    - title TITLE: 定义菜单项"标题", 可出现多次;
        - root (hd#,#): grub查找stage2及kernel文件所在设备分区; 为grub的"根";
        - kernel /PATH/TO/VMLINUZ_FILE [PARAMETERS]: 启动的内核
        - initrd /PATH/TO/INITRAMFS_FILE: 内核匹配的ramfs文件;
        - password [--md5] STRING: 启动选定的内核或操作系统时进行认证; grub-md5-crypt命令, 生成密码串

- 进入单用户模式:
    - (1) 编辑grub菜单(选定要编辑的title, 而后使用e命令);
    - (2) 在选定的kernel后附加
        - 1, s, S或single都可以;
    - (3) 在kernel所在行, 键入"b"命令;

- 安装grub:
    - (1) grub-install: `grub-install --root-directory=ROOT /dev/DISK`
    - (2) grub
        - grub> root (hd#,#)
        - grub> setup (hd#)
