# DNS and Bind

## 概述

- FQDN：(Fully Qualified Domain Name)完全合格域名/全称域名，是指主机名加上全路径，全路径中列出了序列中所有域成员。如：主机名为jesse，在域example.com中，则其FQDN为jesse.example.com。全域名可以从逻辑上准确地表示出主机在什么地方，也可以说全域名是主机名的一种完全表示形式。从全域名中包含的信息可以看出主机在域名树中的位置。其解析过程同DNS解析流程。

- DNS名称解析方式：
    - 名称 --> IP：正向解析
    - IP --> 名称：反向解析
    - 注意：二者的名称空间，非为同一个空间，即非为同一棵树；因此，也不是同一个解析库；

- 域：example.com.
    - www.example.com.      1.1.1.1
    - ftp.example.com.      2.2.2.2
    - bbs.example.com.      3.3.3.3
    - cloud.example.com.    4.4.4.4

- 递归查询和迭代查询：
    - 递归查询：如果主机所询问的本地域名服务器不知道被查询域名的 IP 地址，那么本地域名服务器就以 DNS 客户的身份，向其他根域名服务器继续发出查询请求报文。
    - 迭代查询：当根域名服务器收到本地域名服务器的迭代查询请求报文时，要么给出所要查询的IP地址，要么告诉本地域名服务器：“你下一步应当向哪一个域名服务器进行查询”。然后让本地域名服务器进行后续的查询。

- DNS服务器类型：
    - 负责解析至少一个域：
        - 主名称服务器；
        - 辅助名称服务器；
    - 不负责的解析：
        - 缓存名称服务器；

- 一次完整的查询请求经过的流程：
    - Client --> hosts文件 --> DNS Local Cache --> DNS  Server (recursion)
        - --> 自己负责解析的域：直接查询数据库并返回答案；
        - --> 不是自己负责解析域：Server Cache --> iteration(迭代)
    - 解析答案：
        - 肯定答案：
        - 否定答案：不存在查询的键，因此，不存在与其查询键对应的值；
        - 权威答案：由直接负责的DNS服务器返回的答案；
        - 非权威答案：例如，缓存返回的结果

- 主-辅DNS服务器：
    - 主DNS服务器：维护所负责解析的域数据库的那台服务器；读写操作均可进行；
    - 从DNS服务器：从主DNS服务器那里或其它的从DNS服务器那里“复制”一份解析库；但只能进行读操作；
    - “复制”操作的实施方式：
        - 序列号：serial, 也即是数据库的版本号；主服务器数据库内容发生变化时，其版本号递增；
        - 刷新时间间隔：refresh, 从服务器每多久到主服务器检查序列号更新状况；
        - 重试时间间隔：retry, 从服务器从主服务器请求同步解析库失败时，再次发起尝试请求的时间间隔；
        - 过期时长：expire，从服务器始终联系不到主服务器时，多久之后放弃从主服务器同步数据；停止提供服务；
        - 否定答案的缓存时长：
    - 主服务器”通知“从服务器随时更新数据；
    - 区域传送：
        - 全量传送：axfr (all transfer), 传送整个数据库；
        - 增量传送：ixfr (incremental transfer), 仅传送变量的数据；

- 区域(zone)和域(domain)：example.com域：
    - FQDN --> IP: 正向解析库；区域
    - IP --> FQDN: 反向解析库；区域

- 区域数据库文件：
    - 资源记录：Resource Record, 简称rr；
    - 记录有类型：A, AAAA, PTR, SOA, NS, CNAME, MX
        - SOA：Start Of Authority，起始授权记录；一个区域解析库有且只能有一个SOA记录，而且必须放在第一条；
        - NS：Name Service，域名服务记录；一个区域解析库可以有多个NS记录；其中一个为主的；
        - A：Address, 地址记录，FQDN --> IPv4；
        - AAAA：地址记录， FQDN --> IPv6；
        - CNAME：Canonical Name，别名记录；
        - PTR：Pointer，IP --> FQDN
        - MX：Mail eXchanger，邮件交换器；有优先级的概念，优先级：0-99，数字越小优先级越高；

- 资源记录的定义格式：`name [TTL] IN RR_TYPE value`
    - SOA：
        - name: 当前区域的名字；例如"example.com."，或者“2.3.4.in-addr.arpa.”；
        - value：有多部分组成
            - (1) 当前区域的区域名称（也可以使用主DNS服务器名称）；
            - (2) 当前区域管理员的邮箱地址；但地址中不能使用@符号，一般使用点号来替代；
            - (3) `(主从服务协调属性的定义以及否定答案的TTL)`
        - 例如：
            ```
            example.com.    86400    IN    SOA    example.com.    admin.example.com.  (
                                        2017010801  ; serial
                                        2H          ; refresh
                                        10M         ; retry
                                        1W          ; expire
                                        1D          ; negative answer ttl
            )
            ```
    - NS：
        - name: 当前区域的区域名称
        - value：当前区域的某DNS服务器的名字，例如ns.example.com.；注意：一个区域可以有多个ns记录；
        - 例如：
            ```
            example.com.     86400   IN  NS      ns1.example.com.
            example.com.     86400   IN  NS      ns2.example.com.
            ```
    - MX：
        - name: 当前区域的区域名称
        - value：当前区域某邮件交换器的主机名；**注意：MX记录可以有多个；但每个记录的value之前应该有一个数字表示其优先级；**
        - 例如：
            ```
            example.com.         IN  MX  10      mx1.example.com.
            example.com.         IN  MX  20      mx2.example.com.
            ```
    - A：
        - name：某FQDN，例如www.example.com.
        - value：某IPv4地址；
        - 例如：
            ```
            www.example.com.     IN  A   1.1.1.1
            www.example.com.     IN  A   1.1.1.2
            bbs.example.com.     IN  A   1.1.1.1
            ```
    - AAAA：
        - name：FQDN
        - value: IPv6
    - PTR：
        - name：IP地址，有特定格式，IP反过来写，而且加特定后缀；例如1.2.3.4的记录应该写为4.3.2- n-addr.arpa.；
        - value：FQND
        - 例如：`4.3.2.1.in-addr.arpa.   IN  PTR  www.example.com.`
    - CNAME：
        - name：FQDN格式的别名；
        - value：FQDN格式的正式名字；
        - 例如：`web.example.com.     IN      CNAME  www.example.com.`
    - 注意：
        - (1) TTL可以从全局继承；
        - (2) @表示当前区域的名称；
        - (3) 相邻的两条记录其name相同时，后面的可省略；
        - (4) 对于正向区域来说，各MX，NS等类型的记录的value为FQDN，此FQDN应该有一个A记录；

## Bind安装配置

- BIND: Berkeley Internet Name Domain, ISC.org
    - dns: 协议
    - bind： dns协议的一种实现
    - named：bind程序的运行的进程名

- 程序包：
    - bind-libs：被bind和bind-utils包中的程序共同用到的库文件；
    - bind-utils：bind客户端程序集，例如dig, host, nslookup等；
    - bind：提供的dns server程序、以及几个常用的测试程序；
    - bind-chroot：选装，让named运行于jail模式下；
            
- bind：
    - 主配置文件：/etc/named.conf, 或包含进来其它文件；
        - /etc/named.iscdlv.key
        - /etc/named.rfc1912.zones
        - /etc/named.root.key
    - 解析库文件：/var/named/目录下；
        - 一般名字为：ZONE_NAME.zone
        - 注意：
            - (1) 一台DNS服务器可同时为多个区域提供解析；
            - (2) 必须要有根区域解析库文件： named.ca；
            - (3) 还应该有两个区域解析库文件：localhost和127.0.0.1的正反向解析库；
                - 正向：named.localhost
                - 反向：named.loopback
    - rndc：remote name domain contoller: 953/tcp，但默认监听于127.0.0.1地址，因此仅允许本地使用；
    - bind程序安装完成之后，默认即可做缓存名称服务器使用；如果没有专门负责解析的区域，直接即可启动服务；
        - CentOS 6: `service named start`
        - CentOS 7: `systemctl start named.service`
    - 主配置文件格式：
        - 注意：每个配置语句必须以分号结尾；
        - 全局配置段：options { ... }
        - 日志配置段：logging { ... }
        - 区域配置段：zone { ... } 那些由本机负责解析的区域，或转发的区域；
        - 缓存名称服务器的配置：监听能与外部主机通信的地址；
            ```
            listen-on port 53 { 0.0.0.0; };
            listen-on port 53 { 172.16.100.67; };
            ```
        - 学习时，建议关闭dnssec
            ```
            dnssec-enable no;
            dnssec-validation no;
            dnssec-lookaside no;
            ```
        - 关闭仅允许本地查询：`//allow-query  { localhost; };`or`allow-query  { any; };`
        - 检查配置文件语法错误：`named-checkconf [/etc/named.conf]`
                    
- 测试工具：dig, host, nslookup等
    - dig命令：`dig  [-t RR_TYPE]  name  [@SERVER]  [query options]`
        - 用于测试dns系统，因此其不会查询hosts文件；
        - 查询选项[query options]：
            - +[no]trace：跟踪解析过程；
            - +[no]recurse：进行递归解析；
        - 注意：反向解析测试`dig  -x  IP`
        - 模拟完全区域传送：`dig -t axfr DOMAIN [@server]`
    - host命令：`host [-t RR_TYPE] name SERVER_IP`
    - nslookup命令：`nslookup  [-options]  [name]  [server]`
        - 交互式模式：nslookup>
            - server  IP：以指定的IP为DNS服务器进行查询；
            - set  q=RR_TYPE：要查询的资源记录类型；
            - name：要查询的名称；
    - rndc命令：named服务控制命令
        - `rndc  status`
        - `rndc  flush`

- 配置解析一个正向区域：以example.com域为例：
    - (1) 定义区域: 在主配置文件中或主配置文件辅助配置文件中实现；注意：区域名字即为域名；
        ```
        zone  "ZONE_NAME"  IN  {
            type  {master|slave|hint|forward};
            file  "ZONE_NAME.zone"; 
        };
        ```
    - (2) 建立区域数据文件（主要记录为A或AAAA记录）在/var/named目录下建立区域数据文件；
        - 文件为：/var/named/example.com.zone
            ```
            $TTL 3600
            $ORIGIN example.com.
            @       IN      SOA     ns1.example.com.   dnsadmin.example.com. (
                    2017010801
                    1H
                    10M
                    3D
                    1D )
                IN      NS      ns1
                IN      MX   10 mx1
                IN      MX   20 mx2
            ns1     IN      A       172.16.100.67
            mx1     IN      A       172.16.100.68
            mx2     IN      A       172.16.100.69
            www     IN      A       172.16.100.67
            web     IN      CNAME   www
            bbs     IN      A       172.16.100.70
            bbs     IN      A       172.16.100.71
            ```
        - 权限及属组修改：
            ```
            chgrp  named  /var/named/example.com.zone
            chmod  o=  /var/named/example.com.zone
            ```       
        - 检查语法错误：
            ```
            named-checkzone  ZONE_NAME   ZONE_FILE
            named-checkconf
            ```
    - (3) 让服务器重载配置文件和区域数据文件
        ```
        rndc  reload # 或
        systemctl  reload  named.service
        ```

- 配置解析一个反向区域
    - (1) 定义区域
        - 在主配置文件中或主配置文件辅助配置文件中实现；
            ```
            zone  "ZONE_NAME"  IN  {
                type  {master|slave|hint|forward};
                file  "ZONE_NAME.zone"; 
            };
            ```
        - 注意：反向区域的名字：
            - 反写的网段地址.in-addr.arpa
            - 100.16.172.in-addr.arpa
    - (2) 定义区域解析库文件（主要记录为PTR）
        - 示例，区域名称为100.16.172.in-addr.arpa；
            ```
            $TTL 3600
            $ORIGIN 100.16.172.in-addr.arpa.
            @       IN      SOA     ns1.example.com.  nsadmin.example.com. (
                    2017010801
                    1H
                    10M
                    3D
                    12H )
                IN      NS      ns1.example.com.
            67      IN      PTR     ns1.example.com.
            68      IN      PTR     mx1.example.com.
            69      IN      PTR     mx2.example.com.
            70      IN      PTR     bbs.example.com.
            71      IN      PTR     bbs.example.com.
            67      IN      PTR     www.example.com.
            ```
        - 权限及属组修改：
            ```
            chgrp  named  /var/named/172.16.100.zone
            chmod  o=  /var/named/172.16.100.zone
            ```
        - 检查语法错误：
            ```
            named-checkzone  ZONE_NAME   ZONE_FILE
            named-checkconf
            ```
    - (3) 让服务器重载配置文件和区域数据文件
        ```
        rndc  reload #或
        systemctl  reload  named.service
        ```

## 主从服务器配置

- 主从服务器：
    - 注意：
        - 从服务器是区域级别的概念；
        - 时间要同步；ntpdate命令；
    - 配置一个从区域：
        - On Slave 
            - (1) 定义区域：
                - 定义一个从区域；
                    ```
                    zone "ZONE_NAME"  IN {
                        type  slave;
                        file  "slaves/ZONE_NAME.zone";
                        masters  { MASTER_IP; };
                    };
                    ```
                - 配置文件语法检查：named-checkconf
            - (2) 重载配置
                ```
                rndc reload     # or
                systemctl reload named.service
                ```
        - On Master
            - (1) 确保区域数据文件中为每个从服务配置NS记录，并且在正向区域文件需要每个从服务器的NS记录的主机名配置一个A记录，且此A后面的地址为真正的从服务器的IP地址；
            - (2) 修改住配置文件之后，要修改其序列号，并且重在配置。

- 子域授权：
    - 正向解析区域授权子域的方法：
        - ops.example.com.         IN  NS       ns1.ops.example.com.
        - ops.example.com.         IN  NS       ns2.ops.example.com.
        - ns1.ops.example.com.     IN  A        IP.AD.DR.ESS
        - ns2.ops.example.com.     IN  A        IP.AD.DR.ESS
    - 定义转发：注意：被转发的服务器必须允许为当前服务做递归；
        - (1) 区域转发：仅转发对某特定区域的解析请求；
            ```
            zone  "ZONE_NAME"  IN {
                type  forward;
                forward  {first|only};
                    # first：首先转发；转发器不响应时，自行去迭代查询；
                    # only：只转发；
                forwarders  { SERVER_IP; };
            };
            ```
        - (2) 全局转发：针对凡本地没有通过zone定义的区域查询请求，通通转给某转发器；
            ```
            options {
                ... ...
                forward  {only|first};
                    # first：首先转发；转发器不响应时，自行去迭代查询；
                    # only：只转发；
                forwarders  { SERVER_IP; };
                .. ...
            };
            ```

- bind中的安全相关的配置：
    - acl：访问控制列表；把一个或多个地址归并一个命名的集合，随后通过此名称即可对此集全内的所有主机实现统一调用；
        ```
        acl  acl_name  {
            ip;
            net/prelen;
        };
        # 示例：
        acl  mynet {
            172.16.0.0/16;
            127.0.0.0/8;
        };
        ```
    - bind有四个内置的acl
        - none：没有一个主机；
        - any：任意主机；
        - local：本机；
        - localnet：本机所在的IP所属的网络；
    - 访问控制指令：
        - allow-query  {};  允许查询的主机；白名单；
        - allow-transfer {};  允许向哪些主机做区域传送；默认为向所有主机；应该配置仅允许从服务器；
        - allow-recursion {}; 允许哪此主机向当前DNS服务器发起递归查询请求； 
        - allow-update {}; DDNS，允许动态更新区域数据库文件中内容；

- bind view：视图：
    - 格式：
        ```
        view  VIEW_NAME {
            zone
            zone
            zone
        }
        ```
    - examples：
        ```
        view internal  {
            match-clients { 172.16.0.0/8; };
            zone "example.com"  IN {
                type master;
                file  "example.com/internal";
            };
        };
        
        view external {
            match-clients { any; };
            zone "example.com" IN {
                type master;
                file example.com/external";
            };
        };
        ```

## 编译安装DNS

- [编译安装DNS](https://www.jianshu.com/p/658065f81c99)

- 课外练习：
    - 注册一个域名，修改其域名解析服务器为dnspod.cn，dns.la；
    - whois命令；
