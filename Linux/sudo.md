# sudo

- su: switch user, 用户切换
    - (1) su -l user
    - (2) su -l user -c 'COMMAND'

- sudo: 能够让获得授权的用户以另外一个用户的身份运行指定的命令;
    - 授权机制: 授权文件 /etc/sudoers
        ```
        root        ALL=(ALL)       ALL
        %wheel      ALL=(ALL)       ALL
        ```
    - 编译此文件的专用命令: visudo
        - 授权项:
            - users: 支持将多个用户定义为一组用户, 称之为用户别名, 即user_alias;
                - username
                - #uid
                - %groupname
                - %#gid
                - user_alias
            - hosts:
                - ip
                - hostname
                - NetAddr
                - host_alias
            - runas:
                - runas_alias
            - commands:
                - command
                - directory
                - sudoedit: 特殊权限, 可用于向其它用户授予sudo权限;
                - cmnd_alias
            - Example:
                ```
                who         where=(whom)        commands
                users       hosts=(runas)       commands
                ```
        - 定义别名的方法:
            - ALIAS_TYPE  NAME=item1, item2, item3, ...
                - NAME: 别名名称, 必须使用全大写字符;
            - ALIAS_TYPE:
                - User_Alias
                - Host_Alias
                - Runas_Alias
                - Cmnd_Alias
            - 例如:
                ```
                User_Alias  NETADMIN=tom, jerry
                Cmnd_Alias NETCMND=ip, ifconfig, route
                NETADMIN     localhost=(root)     NETCMND
                ```

- sudo命令:
    - 检票机制: 能记录成功认证结果一段时间, 默认为5分钟;
    - 以sudo的方式来运行指定的命令;
        - `sudo [options] COMMAND`
            - -l[l] command 列出用户能执行的命令
            - -k 清除此前缓存用户成功认证结果;

- /etc/sudoers应用示例:

```
Cmnd_Alias USERADMINCMNDS = /usr/sbin/useradd, /usr/sbin/usermod, /usr/bin/passwd [a-z]*, !/usr/bin/passwd root
User_Alias USERADMIN = bob, alice
USERADMIN       ALL=(root)      USERADMINCMNDS
```

- 常用标签:
    - NOPASSWD:
    - PASSWD:
