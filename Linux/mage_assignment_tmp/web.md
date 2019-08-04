# Web Service

## TCP协议概述

- 端口：
    - IANA：
        - 0-1023：众所周知，永久地分配给固定的应用使用，特权端口；
        - 1024-41951：亦为注册端口，但要求不是特别严格，分配给程序注册为某应用使用；
        - 41952+：客户端程序随机使用的端口，动态端口，或私有端口；
            - 其范围定义在`/proc/sys/net/ipv4/ip_local_port_range`；
    - BSD Socket：IPC的一种实现，允许位于不同主机（也可以是同一主机）上的进程之间进行通信；
        - Socket API(封装了内核中的socket通信相关的系统调用)
            - SOCK_STREAM: tcp套接字
            - SOCK_DGRAM: UDP套接字
            - SOCK_RAW：raw套按字
        - 根据套按字所使用的地址格式，Socket Domain：
            - AF_INET：Address Family，IPv4
            - AF_INET6：ipv6
            - AF_UNIX：同一主机上的不同进程间基于socket套接字通信使用的一种地址；Unix_SOCK

- TCP FSM：CLOSED -> LISTEN -> SYN_SENT -> SYN_RECV -> ESTABLISHED -> FIN_WAIT1 -> CLOSE_WAIT -> FIN_WAIT2 -> LAST_ACK -> TIMEWAIT -> CLOSED

- TCP协议的特性：
    - 建立连接：三次握手；
    - 将数据打包成段：校验和(CRC32)
    - 确认、重传及超时；
    - 排序：逻辑序号；
    - 流量控制：滑动窗口算法；
    - 拥塞控制：慢启动和拥塞避免算法；

## HTTP协议

- 协议版本：
    - http/0.9：原型版本，功能简陋
    - http/1.0: cache, MIME, method,              
        - MIME：Multipurpose Internet Mail Extesion
        - method：GET， POST， HEAD，PUT， DELETE，TRACE， OPTIONS
    - http/1.1：增强了缓存功能；
        - spdy
    - http/2.0

- HTTP工作模式：
    - http请求报文：http request
    - http响应报文: http response

- web资源：web resource
    - 静态资源（无须服务端做出额外处理）： .jpg, .png, .gif, .html, txt, .js, .css, .mp3, .avi                  
    - 动态资源（服务端需要通过执行程序做出处理，发送给客户端的是程序的运行结果）： .php, .jsp
    - 注意：一个页面中展示的资源可能有多个；每个资源都需要单独请求；
    - 资源的标识机制：URL，Uniform Resource Locator：用于描述服务器某特定资源的位置；
        - 例如：  http://www.ifeng.com/
        - Scheme://Server[:Port][/PATH/TO/SOME_RESOURCE]

- 一次完整的http请求处理过程：
    - 一次http事务：请求<-->响应
    - (1) 建立或处理连接：接收请求或拒绝请求；
    - (2) 接收请求：接收来自于网络上的主机请求报文中对某特定资源的一次请求的过程；
    - (3) 处理请求：对请求报文进行解析，获取客户端请求的资源及请求方法等相关信息；
    - (4) 访问资源：获取请求报文中请求的资源；
    - (5) 构建响应报文
    - (6) 发送响应报文
    - (7) 记录日志

- 接收请求的模型：并发访问响应模型：
    - 单进程I/O模型：启动一个进程处理用户请求；这意味着，一次只能处理一个请求，多个请求被串行响应；
    - 多进程I/O结构：由父进程并行启动多个进程，每个子进程响应一个请求；
    - 复用的I/O结构：一个进程响应n个请求；
        - 多线程模式：一个进程生成n个线程，一个线程处理一个请求；
        - 事件驱动(event-driven)：一个进程直接n个请求；
    - 复用的多进程I/O结构：启动多个（m）个进程，每个进程生成（n）个线程；
        - 响应的请求的数量：`m*n`

- 处理请求：分析请求报文的http请求报文首部
    - http协议：
        - http请求报文首部
        - http响应报文首部
    - 请求报文首部的格式：
        - `<method> <URL> <VERSION>`
        - HEADERS: (name: value)
        - `<request body>`

- http服务器程序：
    - httpd (apache)
    - nginx
    - lighttpd

- 应用程序服务器：
    - IIS： .Net 
    - tomcat： .jsp

- httpd的安装和使用：
    - ASF： apache software foundation
        - httpd：apache (a patchy server)

- httpd的特性：
    - 高度模块化： core + modules
    - DSO：dynamic shared object
    - MPM：Multipath processing Modules (多路处理模块)
        - prefork：多进程模型，每个进程响应一个请求；
            - 一个主进程：负责生成子进程及回收子进程；负责创建套接字；负责接收请求，并将其派发给某子进程进行处理；
            - n个子进程：每个子进程处理一个请求；
            - 工作模型：会预先生成几个空闲进程，随时等待用于响应用户请求；最大空闲和最小空闲；
        - worker：多进程多线程模型，每线程处理一个用户请求；
            - 一个主进程：负责生成子进程；负责创建套接字；负责接收请求，并将其派发给某子进程进行处理；
            - 多个子进程：每个子进程负责生成多个线程；
            - 每个线程：负责响应用户请求；
            - 并发响应数量：`m*n`
                - m：子进程数量
                - n：每个子进程所能创建的最大线程数量；
        - event：事件驱动模型，多进程模型，每个进程响应多个请求；
            - 一个主进程 ：负责生成子进程；负责创建套接字；负责接收请求，并将其派发给某子进程进行处理；
            - 子进程：基于事件驱动机制直接响应多个请求；
            - httpd-2.2: 仍为测试使用模型；
            - httpd-2.4：event可生产环境中使用；

- httpd的程序版本：
    - httpd 1.3：官方已经停止维护；
    - httpd 2.0
    - httpd 2.2
    - httpd 2.4：目前最新稳定版；

- 安装httpd：
    - rpm包：CentOS 发行版中直接提供；
    - 编译安装：定制新功能，或其它原因；

- CentOS 6：httpd-2.2
    - 程序环境：
        - 配置文件：
            - `/etc/httpd/conf/httpd.conf`
            - `/etc/httpd/conf.d/*.conf`
        - 服务脚本：
            - /etc/rc.d/init.d/httpd
            - 脚本配置文件：/etc/sysconfig/httpd
        - 主程序文件：
            - /usr/sbin/httpd
            - /usr/sbin/httpd.event
            - /usr/sbin/httpd.worker
        - 日志文件：
            - /var/log/httpd:
                - access_log：访问日志
                - error_log：错误日志
        - 站点文档：
            - /var/www/html
        - 模块文件路径：
            - /usr/lib64/httpd/modules
    - 服务控制和启动：
        - chkconfig  httpd  on|off
        - service  {start|stop|restart|status|configtest|reload}  httpd

- CentOS 7：httpd-2.4
    - 程序环境：
        - 配置文件：
            - /etc/httpd/conf/httpd.conf
            - `/etc/httpd/conf.d/*.conf`
            - 模块相关的配置文件：`/etc/httpd/conf.modules.d/*.conf`
        - systemd unit file：
            - /usr/lib/systemd/system/httpd.service
        - 主程序文件：
            - /usr/sbin/httpd（httpd-2.4支持MPM的动态切换）
        - 日志文件：
            - /var/log/httpd:
                - access_log：访问日志
                - error_log：错误日志
        - 站点文档：
            - /var/www/html
        - 模块文件路径：
            - /usr/lib64/httpd/modules    
    - 服务控制：
        - systemctl  enable|disable  httpd.service
        - systemctl  {start|stop|restart|status}  httpd.service

### httpd-2.4的常用配置
    
- 主配置文件：/etc/httpd/conf/httpd.conf
    - 1: Global Environment
    - 2: 'Main' server configuration
    - 3: Virtual Hosts

- 配置格式： directive  value
    - directive：不区分字符大小写；
    - value：为路径时，是否区分字符大小写，取决于文件系统； 

- 常用配置：
    - 1、修改监听的IP和PORT: `Listen [IP-address:]portnumber [protocol]`
        - (1) 省略IP表示为0.0.0.0；
        - (2) Listen指令可重复出现多次；
            ```
            Listen  80
            Listen  8080
            ```
        - (3) 修改监听socket，重启服务进程方可生效；
        - (4) 限制其必须通过ssl通信时，protocol需要定义为https；
    - 2、持久连接（保持连接，长连接）
        - Persistent Connection：tcp连续建立后，每个资源获取完成后不全断开连接，而是继续等待其它资源请求的进行；如何断开？
            - 数量限制
            - 时间限制
        - 副作用：对并发访问量较大的服务器，长连接机制会使得后续某些请求无法得到正常 响应；
        - 折衷：使用较短的持久连接时长，以及较少的请求数量；
            ```
            KeepAlive On|Off
            KeepAliveTimeout 15
            MaxKeepAliveRequests 100
            ```
        - 测试：
            ```
            telnet  WEB_SERVER_IP  PORT
            GET  /URL  HTTP/1.1
            Host: WEB_SERVER_IP
            ```
        - 注意：httpd-2.4的KeepAliveTimeout可是毫秒级；`KeepAliveTimeout num[ms]`
    - 3、MPM
        - httpd-2.2不支持同时编译多个MPM模块，所以只能编译选定要使用的那个；CentOS 6的rpm包为此专门提供了三个应用程序文件，httpd(prefork), httpd.worker, httpd.event，分别用于实现对不同的MPM机制的支持；确认现在使用的是哪下程序文件的方法：`ps aux | grep httpd`
        - 默认使用的为/usr/sbin/httpd，其为prefork的MPM模块；
        - 查看httpd程序的模块列表：
            - 查看静态编译的模块：`httpd  -l`
            - 查看静态编译及动态编译的模块：`httpd  -M`
        - 更换使用httpd程序，以支持其它MPM机制；
            ```
            /etc/sysconfig/httpd
            HTTPD=/usr/sbin/httpd.{worker,event}
            ```
        - 注意：重启服务进程方可生效
        - MPM配置：
            - prefork的配置
                ```
                <IfModule prefork.c>
                    StartServers       8
                    MinSpareServers    5
                    MaxSpareServers   20
                    ServerLimit      256
                    MaxClients       256
                    MaxRequestsPerChild  4000
                </IfModule>
                ```
            - worker的配置：
                ```
                <IfModule worker.c>
                    StartServers         4
                    MaxClients         300
                    MinSpareThreads     25
                    MaxSpareThreads     75
                    ThreadsPerChild     25
                    MaxRequestsPerChild  0
                </IfModule>
                ```
        - PV，UV
            - PV：Page View
            - UV: Unit/User View
            - IP：
    - 4、DSO, 动态共享对象
        - `/etc/httpd/conf.modules.d/00-proxy.conf`
        - 配置指定实现模块加载：`LoadModule  <mod_name>  <mod_path>`
        - 模块文件路径可使用相对路径：相对于ServerRoot（默认/etc/httpd）
    - 5、定义'Main' server的文档页面路径
        - ServerName
            - 语法格式： `ServerName [scheme://]fully-qualified-domain-name[:port]`
        - DocumentRoot "" 文档路径映射：
            - DoucmentRoot指向的路径为URL路径的起始位置, 其相当于站点URL的根路径；
                - URL PATH与FileSystem PATH不是等同的，而是存在一种映射关系: 
                    ```
                    URL /               -->     FileSystem /var/www/html/
                    /images/logo.jpg    -->     /var/www/html/images/logo.jpg
                    ```
    - 6、站点访问控制常见机制
        - 可基于两种机制指明对哪些资源进行何种访问控制
            - 文件系统路径：
                ```
                <Directory  "">
                ...
                </Directory>
                <File  "">
                ...
                </File>
                <FileMatch  "PATTERN">
                ...
                </FileMatch>
                ```
            - URL路径：
                ```
                <Location  "">
                ...
                </Location>
                
                <LocationMatch "PATTERN">
                ...
                </LocationMatch>
                ```
        - `<Directory>`中“基于源地址”实现访问控制：
            - httpd-2.2：order和allow、deny
                - order：定义生效次序；写在后面的表示默认法则；
                - Allow from, Deny from
                    - 来源地址：
                        - IP
                        - NetAddr:
                            - 172.16
                            - 172.16.0.0
                            - 172.16.0.0/16
                            - 172.16.0.0/255.255.0.0
            - httpd-2.4：
                - 基于IP控制：
                    - Require ip  IP地址或网络地址
                    - Require not ip IP地址或网络地址
                - 基于主机名控制：
                    - Require host 主机名或域名
                    - Require not host 主机名或域名
                - 要放置于<RequireAll>配置块中或<RequireAny>配置块中；
            - 控制页面资源允许、拒绝所有来源的主机可访问：
                - httpd-2.2
                    ```
                    <Directory "">
                        ...
                        Order allow,deny
                        Allow from all          # 允许
                        Allow from 172.30.50    # 允许172.30.50端访问
                        Deny from all           # 拒绝
                    </Directory>
                    ```
                - httpd-2.4
                    ```
                    <Directory "">
                        ...
                        Require all granted     # 允许
                        Require all denied      # 拒绝
                    </Directory>
                    ```
        - Options：Configures what features are available in a particular directory，后跟1个或多个以空白字符分隔的“选项”列表；
            - Indexes：指明的URL路径下不存在与定义的主页面资源相符的资源文件时，返回索引列表给用户；
            - FollowSymLinks：允许跟踪符号链接文件所指向的源文件；
            - None：
            - All：All options except for MultiViews.
    - 7、定义站点主页面：
        - DirectoryIndex  index.html  index.html.var
    - 8、定义路径别名
        - 格式：`Alias  /URL/  "/PATH/TO/SOMEDIR/"` 
        - Alias  /download/  "/rpms/pub/"
    - 9、设定默认字符集
        - AddDefaultCharset  UTF-8
        - 中文字符集：GBK, GB2312, GB18030
    - 10、日志设定
        - 日志类型：访问日志 和 错误日志
        - 错误日志：
            - ErrorLog  logs/error_log
            - LogLevel  warn
            - Possible values include: debug, info, notification, warning, error, crital, alert, emergency.
        - 访问日志：
            - LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
            - CustomLog  logs/access_log  combined
            - LogFormat format strings: http://httpd.apache.org/docs/2.2/mod/mod_log_config.html#formats
                - %h：客户端IP地址；
                - %l：Remote User, 通常为一个减号（“-”）；
                - %u：Remote user (from auth; may be bogus if return status (%s) is 401)；非为登录访问时，其为一个减号；
                - %t：服务器收到请求时的时间；
                - %r：First line of request，即表示请求报文的首行；记录了此次请求的“方法”，“URL”以及协议版本；
                - %>s：响应状态码；
                - %b：响应报文的大小，单位是字节；不包括响应报文的http首部；
                - %{Referer}i：请求报文中首部“referer”的值；即从哪个页面中的超链接跳转至当前页面的；
                - %{User-Agent}i：请求报文中首部“User-Agent”的值；即发出请求的应用程序；
    - 11、基于用户的访问控制
        - 认证质询：
            - WWW-Authenticate：响应码为401，拒绝客户端请求，并说明要求客户端提供账号和密码；
        - 认证：
            - Authorization：客户端用户填入账号和密码后再次发送请求报文；认证通过时，则服务器发送响应的资源；
            - 认证方式有两种：
                - basic：明文
                - digest：消息摘要认证
        - 安全域：需要用户认证后方能访问的路径；应该通过名称对其进行标识，以便于告知用户认证的原因；
        - 用户的账号和密码存放于何处？
            - 虚拟账号：仅用于访问某服务时用到的认证标识
            - 存储：
                - 文本文件；
                - SQL数据库；
                - ldap目录存储；
        - basic认证配置示例：
            - (1) 定义安全域
                ```
                <Directory "">
                    Options None
                    AllowOverride None
                    AuthType Basic
                    AuthName "String“
                    AuthUserFile  "/PATH/TO/HTTPD_USER_PASSWD_FILE"
                    Require  user  username1  username2 ...
                    # Require  valid-user 允许账号文件中的所有用户登录访问
                </Directory>
                ```
            - (2) 提供账号和密码存储（文本文件），使用专用命令完成此类文件的创建及用户管理
                - `htpasswd  [options]   /PATH/TO/HTTPD_PASSWD_FILE  username `
                    - -c：自动创建此处指定的文件，因此，仅应该在此文件不存在时使用；
                    - -m：md5格式加密
                    - -s: sha格式加密
                    - -D：删除指定用户
                    - -b：批模式添加用户
                        ```
                        htpasswd -cb /PATH/TO/HTTPD_PASSWD_FILE  username1 password1
                        htpasswd -cb /PATH/TO/HTTPD_PASSWD_FILE  username2 password2
                        ```
        - 另外：基于组账号进行认证
            - (1) 定义安全域
                ```
                <Directory "">
                    Options None
                    AllowOverride None
                    AuthType Basic
                    AuthName "String“
                    AuthUserFile  "/PATH/TO/HTTPD_USER_PASSWD_FILE"
                    AuthGroupFile "/PATH/TO/HTTPD_GROUP_FILE"
                    Require  group  grpname1  grpname2 ...
                </Directory>
                ```
            - (2) 创建用户账号和组账号文件
                - 组文件：每一行定义一个组
                - GRP_NAME: username1  username2  ...
    - 12、虚拟主机
        - 站点标识： socket
            - IP相同，但端口不同；
            - IP不同，但端口均为默认端口；
            - FQDN不同；
                - 请求报文中首部
                - Host: www.magedu.com 
        - 有三种实现方案：
            - 基于ip： 为每个虚拟主机准备至少一个ip地址；
            - 基于port： 为每个虚拟主机使用至少一个独立的port；
            - 基于FQDN: 为每个虚拟主机使用至少一个FQDN；
        - 注意(专用于httpd-2.2)：一般虚拟机不要与中心主机混用；因此，要使用虚拟主机，得先禁用'main'主机；
            - 禁用方法：注释中心主机的DocumentRoot指令即可；
        - 虚拟主机的配置方法：
            ```
            <VirtualHost  IP:PORT>
                ServerName FQDN
                DocumentRoot  ""
            </VirtualHost>
            ```
        - 其它可用指令：
            - ServerAlias：虚拟主机的别名；可多次使用；
            - ErrorLog：
            - CustomLog：
            - `<Directory ""> ... </Directory>`
            - Alias
        - 基于IP的虚拟主机示例：
            ```
            <VirtualHost 172.16.100.6:80>
                ServerName www.a.com
                DocumentRoot "/www/a.com/htdocs"
            </VirtualHost>

            <VirtualHost 172.16.100.7:80>
                ServerName www.b.net
                DocumentRoot "/www/b.net/htdocs"
            </VirtualHost>

            <VirtualHost 172.16.100.8:80>
                ServerName www.c.org
                DocumentRoot "/www/c.org/htdocs"
            </VirtualHost>
            ```
        - 基于端口的虚拟主机：
            ```
            <VirtualHost 172.16.100.6:80>
                ServerName www.a.com
                DocumentRoot "/www/a.com/htdocs"
            </VirtualHost>

            <VirtualHost 172.16.100.6:808>
                ServerName www.b.net
                DocumentRoot "/www/b.net/htdocs"
            </VirtualHost>

            <VirtualHost 172.16.100.6:8080>
                ServerName www.c.org
                DocumentRoot "/www/c.org/htdocs"
            </VirtualHost>
            ```
        - 基于FQDN的虚拟主机：
            ```
            <VirtualHost 172.16.100.6:80>
                ServerName www.a.com
                DocumentRoot "/www/a.com/htdocs"
            </VirtualHost>

            <VirtualHost 172.16.100.6:80>
                ServerName www.b.net
                DocumentRoot "/www/b.net/htdocs"
            </VirtualHost>

            <VirtualHost 172.16.100.6:80>
                ServerName www.c.org
                DocumentRoot "/www/c.org/htdocs"
            </VirtualHost>
            ```
        - 注意：如果是httpd-2.2，则使用基于FQDN的虚拟主机时，需要事先使用如下指令： NameVirtualHost IP:PORT
    - 13、status页面
        - LoadModule  status_module  modules/mod_status.so
        - httpd-2.2
            ```
            <Location /server-status>
                SetHandler server-status
                Order allow,deny
                Allow from 172.16
            </Location>
            ```
        - httpd-2.4
            ```
            <Location /server-status>
                SetHandler server-status
                <RequireAll>
                    Require ip 172.16
                </RequireAll>
            </Location>
            ```
