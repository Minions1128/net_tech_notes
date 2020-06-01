# rsyslog

## 概述

- 事件: 系统引导启动, 应用程序启动, 应用程序尤其是服务类应用程序运行过程中的一些事件;
    - 系统日志服务, syslog:
        - syslogd: system
        - klogd: kernel
    - 事件格式较为简单时, 可统一由syslog进行记录: `事件产生的日期时间  主机  进程[pid] : 事件内容`
    - 支持C/S架构: 可通过UDP或TCP协议提供日志记录服务;

## rsyslog

- rsyslog: rsyslogd, 特性:
    - 多线程;
    - 支持协议: UDP, TCP, SSL, TLS, RELP;
    - 存储日志信息于MySQL, PGSQL, Oracle等数据管理系统;
    - 强大的过滤器, 实现过滤日志信息中任何部分的内容;
    - 自定义输出格式;

- rsyslog日志收集器重要术语:
    - facility: 设施, 从功能或程序上对日志收集进行分类: auth, authpriv, cron, daemon, kern, lpr, mail, mark, news, security, user, uucp, local0-local7, syslog
    - priority: 优先级, 日志级别: debug, info, notice, warn(warning), err(error), crit(critical), alert, emerg(panic), 指定级别:
        - `*`: 所有级别;
        - `none`: 没有级别;
        - `priority`: 此级别以高于此级别的所有级别;
        - `=priorty`: 仅此级别;

- 程序环境:
    - 主程序: rsyslogd
    - 主配置文件: `/etc/rsyslog.conf`, `/etc/rsyslog.d/*.conf`
    - 服务脚本(centos6): /etc/rc.d/init.d/rsyslog
    - Unit File(CentOS 7): /usr/lib/systemd/system/rsyslog.service

- 配置文件`rsyslog.conf`格式, 主要由三部分组成:
    - MODULES
    - GLOBAL DRICTIVES
    - RULES
        - `facilty.priority    target`
            - target:
                - 文件: 记录日志事件于指定的文件中; 通常应该位于/var/log目录下; 文件路径之前的"-"表示异步写入;
                - 用户: 将日志事件通知给指定的用户; 是通过将信息发送给登录到系统上的用户的终端进行的;
                - 日志服务器: @host, 把日志送往指定的服务器主机;
                    - host: 即日志服务器地址, 监听在tcp或udp协议的514端口以提供服务;
                - 管道: | COMMAND
                - 数据库存储

- 其它日志文件:
    - /var/log/wtmp: 当前系统成功登录系统的日志; 需要使用last命令查看
    - /var/log/btmp: 当前系统尝试登录系统失败相关的日志; 需要使用lastb命令查看
    - lastlog: 显示当前系统上的所有用户最近一次登录系统的时间;
    - /var/log/dmesg: 系统引导过程中的日志信息; 也可以使用dmesg命令进行查看;

- rsyslog服务器:
    - Provides UDP syslog reception
        ```sh
        $ModLoad imudp
        $UDPServerRun 514
        ```
    - Provides TCP syslog reception
        ```sh
        $ModLoad imtcp
        $InputTCPServerRun 514
        ```

- 记录日志于mysql中:
    - (1) 于MySQL服务器: 准备好MySQL服务器, 创建用户, 授权对Syslog数据库拥有全部访问权限;
    - (2) 于rsyslog主机: 安装rsyslog-mysql程序包;
    - (3) 于rsyslog主机: 通过导入createDB.sql脚本创建依赖到的数据库及表; `mysql -uUSER -hHOST -pPASSWORD < /usr/share/doc/rsyslog-mysql-VERSION/createDB.sql`
    - (4) 配置rsyslog使用ommysql模块
        ```sh
        ### MODULES ####
        $ModLoad  ommysql

        #### RULES ####
        facility.priority           :ommysql:DBHOST,DB,DBUSER,DBUSERPASS
        # 重启rsyslog服务;
        ```
    - (5) web展示接口: loganalyzer
        - (a) 配置lamp组合: httpd, php, php-mysql, php-gd
        - (b) 安装loganalyzer
            ```sh
            tar xzf loganalyzer-3.6.5.tar.gz
            cp -r loganalyzer-3.6.5/src  /var/www/html/loganalyzer
            cp -r loganalyzer-3.6.5/contrib/*.sh  /var/www/html/loganalyzer/
            cd /var/www/html/loganalyzer/
            chmod  +x *.sh
            ./configure.sh
            ###
            ./secure.sh
            ```
        - (c) 通过URL访问: http://HOST/loganalyzer
