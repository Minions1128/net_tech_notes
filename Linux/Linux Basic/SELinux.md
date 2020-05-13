# Security Enhanced Linux

- 参考: https://www.phpyuan.com/235739.html

- 工作于Linux内核中, 两种工作级别:
    - strict: 每个进程都受到selinux的控制
    - targeted: 仅有限个进程受到selinux控制

- 配置
    - 开启, 关闭
    - 给文件重新打标
    - 设定某些bool特性

- 查看SELinux状态
    - `/usr/sbin/sestatus -v`
    - `getenforce`

- 开启, 关闭SELinux
    - 临时关闭(不用重启机器):
        - `setenforce 0`    # 设置SELinux 成为permissive模式, 关闭, 但会记录到审计日志
        - `setenforce 1`    # 设置SELinux 成为enforcing模式, 开启
    - 修改配置文件(需要重启机器): 修改/etc/selinux/config文件
        - `SELINUX={enforcing | permissive | disabled}`
        - 重启机器
