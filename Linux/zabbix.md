# ZABBIX
- 一个开源的监控软件，其他类似的软件还有：cacti，nagios，ganglia

## 监控
- 监控指标：硬件(CPU、内存、终端次数)、软件、业务
- 被监控的对象：主机、交换机、路由器、UPS等
- 监控的几个功能
    - 采样：使用传感器（sensor）采样，周期性地获取某个关注指标的数据
        - 采集数据的通道：
            - SSH/telnet
            - agent/master
            - IPMI
            - SNMP
            - JMX
    - 存储：数据（历史数据、趋势数据）
        - 存储系统
            - 关系型数据库：MySQL，PGSQL，Oracle，
            - RRD：
            - NoSQL：redis/mongo/时间序列数据库
    - 展示：图形化展示
    - 报警：通知管理员。途径有：邮件、短信、脚本

## zabbix系统架构
![zabbix_arch](https://github.com/Minions1128/net_tech_notes/blob/master/img/zabbix_arch.png)
![zabbix_arch_ver](https://github.com/Minions1128/net_tech_notes/blob/master/img/zabbix_arch_ver.png)
![zabbix_arch_logic](https://github.com/Minions1128/net_tech_notes/blob/master/img/zabbix_arch_logic.png)

- zabbix程序组件：
    - zabbix_server: 服务端守护进程；
    - zabbix_agentd: agent守护进程；
    - zabbix_proxy: 代理服务器，可选；
    - zabbix_database: 存储系统，MySQL/PGSQL
    - zabbix_web: Web GUI；
    - zabbix_get: 命令行工具，测试向agent端发起数据采集请求；
    - zabbix_sender: 命令行，测试向server段发送数据；
    - zabbix_java_gaetway: Java网关；
- zabbix逻辑组件：
    - hosts -> host groups
    - items -> applications
    - triggers
    - events
    - actions: conditions & operations
    - media: 发送通知的通道
    - notifications
    - remote command: 远程命令
    - escalation: 报警升级
    - templates
    - graphs -> screens -> slide show

## 安装
- server:
    1. zbx db : mysql
        - `mysql> CREATE DATABASE zabbix CHARSET 'utf8'; `
        - `mysql> GRANT ALL ON zabbix.*TO 'zbxuser'@'10.1.%.%' IDENTIFIED BY 'zbxpass';`
    2. 安装服务器端：zabbix_server_mysql, zabbix_get
        - 程序环境：
            - 配置文件：`/etc/zabbix/zabbix_server.conf`
            - unit file: `zabbix-server.service`
        - 导入数据库脚本，
            - `gzip -d /usr/share/doc/zabbix-server-mysql-3.0.2/create.sql.gz`
            - `mysql -ubxuser -h127.0.0.1 -pzabpass zabbix < /usr/share/doc/zabbix-server-mysql-3.0.2/create.sql`
    3. zabbix server配置启动
        - 配置文件：`/etc/zabbix/zabbix_server.conf`
        - 配置参数
            ```
                ##### GENERAL PARAMETERS
                     # ListenPort=10051
                     # SourceIP=
                     # LogType=file
                     # LogFile=/var/log/zabbix/zabbix_server.log
                     # LogFileSize=0
                     # DebugLevel=3
                     # DBHost=localhost
                     # DBName=zabbix
                     # DBUser=r*t
                     # DBPassword=O*a
                     # DBSocket=/tmp/mysql.sock
                     # DBPort=3306
                ##### ADVANCED PARAMETERS
                ##### LOADABLE MODULES
                ##### TLS-RELATED PARAMETERS
            ```
    4. 启动zabbix服务
        - 启动进程：`systemctl start zabbix-server.service`
        - 查看监听10051端口 `ss -tnl`
        - 查看`systemctl status zabbix-server.service`

- zabbix web配置
    1. 解决依赖关系：`yum install httpd php php-mysql php-mbstring php-gd php-bcmath php-ldap php-xml`
    2. 安装web GUI：zabbix-web, zabbix-web-mysql
    3. 配置php时区：```vim /etc/conf.d/zabbix.conf
                          php_value date.timezone Asia/Chongqing```
    4. 启动web服务：`systemctl start httpd.service`
    5. 访问web界面，安装后生成的web配置文件：`/etc/zabix/web/zabbix.conf.php`，user/pass：`admin/zabbix`

- zabbix agent安装配置
    1. 安装：zabbix-agent, zabbix-sender
        - 程序环境：
            - 配置文件：`/etc/zabbix/zabbix_agentd.conf`
            - unit file: `zabbix-agent.service`
    2. 配置文件：
        ```
            ##### GENERAL PARAMETERS
                ##### Passive checks related    被动监控相关配置
                    # Server=127.0.0.1
                    # ListenPort=10050
                    # ListenIP=0.0.0.0
                    # StartAgents=3
                ##### Active checks related     主动监控相关配置
                    # ServerActive=127.0.0.1
                    # Hostname=com.host.name
                    # 
            ##### ADVANCED PARAMETERS
            ##### USER-DEFINED MONITORED PARAMETERS     用户自定义监控项
            ##### LOADABLE MODULES
            ##### TLS-RELATED PARAMETERS
        ```
    3. 启动服务：`systemctl start zabbix-agent.service`

- proxy 安装
    - zabbix_proxy

- 配置监控：
    - quick start：
        ```
            host group --> host
            application --> items
            host --> items --> trigger(events) --> action(conditions, operations)
            operations(remote comand, alert)
            graphs --> screens --> slide show
        ```

## 部分配置
### Action
- Action配置包括两部分：conditions和operatios；
- conditions：触发此动作的条件，一般通过“事件”出发；
- operations：满足conditions时，所做到动作，一般有两类：send message和remote command
- send message
    - Email
    - script：报警脚本
        - 位于server端配置文件`/etc/zabbix/zabbix_server.conf`的`AlertScriptsPath`参数
        - 脚本的默认路径为`/usr/lib/zabbix/alertscripts`
        - 可以给脚本传递参数
            - 3.0之前的版本，默认有三个参数`$1, $2, $3`，分别接受人，消息主题，消息内容
            - 3.0之后的版本，默认不再传递这三个参数，需要自行定义：`{ALERT.SENDTO}, {ALERT.SUBJECT}, {ALERT.MESSAGE}`
- remote command
    - 功能：在agent所在的主机上，运行用户指定的命令或脚本来尝试着恢复故障；如：重启、自定义脚本等
    - 类型：
        - IPMI
        - custom script
            - 实现前提：
                - 在agent端配置：
                    1. zabbix拥有执行相应脚本的权限，在文件`/etc/sudoers`添加：
                        ```
                            zabbix ALL=(ALL) NOPASSWD: ALL
                            注释如下行：
                            Defaults requiretty
                        ```
                    2. agent要允许执行远程命令，编辑`/etc/zabbix/zabbix-agentd.conf`：
                        ```
                            EnableRemoteCommands=1
                        ```
                    3. 重启agent服务生效
        - ssh/telnet
        - global script

### 展示
- graph --> screen --> slide show

### 模版
- 主机配置模版，可以link到主机，从而实现主机的快速监控配置；
- 从主机上删除模版：unlink, unlink and clear(old data)
- 模版支持继承功能，可以从其他模版继承到相应功能。
- 支持导入、导出功能

### 宏：MACRO
- 预设的文本替换模式，只能为大写字母、数字和下划线；
-  级别：
    - 全局宏
    - 模版宏
    - 主机宏
- 类型：
    - 内建宏：`{MACRO_NAME}`
    - 自定义：`{$MACRO_NAME}`

### 网络发现：
- zabbix server扫描指定网络范围的主机
- 发现方式：
    - IP地址范围：
        - 可用的服务探测（ftp，ssh，http，...）
        - snmp_agent响应
- 发现步骤：
    - discovery，会产生相应的事件
        - Service up/down, Host up/down
        - Service discoverd/lost, host discovered/lost：标识第一次服务发现、服务丢失
    - actions：添加主机，链接到模版
        - conditions：discovered
        - operations：
            - send message, remote command, ..
            - add/remove host
            - enable/disable host
            - add host to group
            - link template to host

### 自定义key
- 在zabbix agent端的配置文件中，由用户通过UserParameter指令定义用户自定义参数；
    - UserParameter=<key>,<shell command>
        - 例如：`UserParameter=system.memory.free,awk '/^MemFree/{print $2}' /proc/meminfo`
    - UserParameter=<key[*]>,<shell command> $1, ..., $9
        - 例如：`UserParameter=system.memory.free[*],awk '/^$1/{print $$2}' /proc/meminfo`
    - 命令自带的参数，如awk，需要改写$$1, ..., $$9

### SNMP方式
- 简单网络管理协议
    - 基于UDP协议，默认监听161，agent端；和162，server端
- 安装：`yum install net-snmp net-snmp-utils`
- 配置
    - 配置文件：`/etc/snmp/snmpd.conf`和`/etc/snmp/snmptrapd.conf`
    - 共享所有数据：`view systemview included .1`
    - 默认的community为public：`com2sec notConfigUser default public`
- snmpwalk
    - `snmpwalk -c public -v 2c 127.0.0.1 .1.3.6.1.2.1.1.1`

### 分布式监控
- comming soon

### 优化
- NVPS，New Value Per Second：100w/min, 15000/s
- zabbix服务器进程数量调整：
    - alert
    - discovery
    - escalator
    - http poller，
    - housekeeper
    - poller
    - trapper
    - configruation syncer
    - ipmi poller
- 建议的参数：
    - StartPollers=50
    - StartPinger=10
    - StartDBSyncers=2
- 数据库优化：
    - 分表：
        - history_*
        - trend*
        - events*
- 建议：
    - 历史数据不要保存太长时间；尽量让数据缓存在数据库服务器的内存中；
    - 触发器的表达式：减少使用min(), max(), avg()，尽量使用last(), nodata();
    - 数据收集：polling较慢时，减少使用snmp/agentless/agent，尽量使用trapping方式，agent（active）
    - 数据类型：文本型数据处理速度较慢，尽量少手机类型为text或string或log型数据，多使用numveric型数据


# end
--------------
coming soon.
```
zabbix 进阶1&2
ansible实现zabbix server，zabbix agent即porxy的部署
```
