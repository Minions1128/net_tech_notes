# Web Service

## TCP协议概述

- 端口: 
    - IANA: 
        - 0-1023: 众所周知，永久地分配给固定的应用使用，特权端口;
        - 1024-41951: 亦为注册端口，但要求不是特别严格，分配给程序注册为某应用使用;
        - 41952+: 客户端程序随机使用的端口，动态端口，或私有端口;
            - 其范围定义在`/proc/sys/net/ipv4/ip_local_port_range`;
    - BSD Socket: IPC的一种实现，允许位于不同主机（也可以是同一主机）上的进程之间进行通信;
        - Socket API(封装了内核中的socket通信相关的系统调用)
            - SOCK_STREAM: tcp套接字
            - SOCK_DGRAM: UDP套接字
            - SOCK_RAW: raw套按字
        - 根据套按字所使用的地址格式，Socket Domain: 
            - AF_INET: Address Family，IPv4
            - AF_INET6: ipv6
            - AF_UNIX: 同一主机上的不同进程间基于socket套接字通信使用的一种地址;Unix_SOCK

- TCP FSM: CLOSED -> LISTEN -> SYN_SENT -> SYN_RECV -> ESTABLISHED -> FIN_WAIT1 -> CLOSE_WAIT -> FIN_WAIT2 -> LAST_ACK -> TIMEWAIT -> CLOSED

- TCP协议的特性: 
    - 建立连接: 三次握手;
    - 将数据打包成段: 校验和(CRC32)
    - 确认、重传及超时;
    - 排序: 逻辑序号;
    - 流量控制: 滑动窗口算法;
    - 拥塞控制: 慢启动和拥塞避免算法;

## HTTP协议

- 协议版本: 
    - http/0.9: 原型版本，功能简陋
    - http/1.0: cache, MIME, method,              
        - MIME: Multipurpose Internet Mail Extesion
        - method: GET， POST， HEAD，PUT， DELETE，TRACE， OPTIONS
    - http/1.1: 增强了缓存功能;
        - spdy
    - http/2.0

- http协议: stateless, 服务器无法持续追踪访问者来源, cookie, session

- HTTP工作模式: 
    - http请求报文: http request
        ```
        <method> <request-URL> <version>
        <headers>
        <entity-body>
        ```
    - http响应报文: http response
        ```
        <version> <status> <reason-phrase>
        <headers>
        <entity-body>
        ```
    - version: `HTTP/<major>.<minor>`
    - reason-phrase: 状态码所标记的状态的简要描述;
    - entity-body: 请求时附加的数据或响应时附加的数据;
    - method: 请求方法，标明客户端希望服务器对资源执行的动作
        - GET: 从服务器获取一个资源;
        - HEAD: 只从服务器获取文档的响应首部;
        - POST: 向服务器发送要处理的数据;
        - PUT: 将请求的主体部分存储在服务器上;
        - DELETE: 请求删除服务器上指定的文档;
        - TRACE: 追踪请求到达服务器中间经过的代理服务器;
        - OPTIONS: 请求服务器返回对指定资源支持使用的请求方法;
        - 协议查看或分析的工具: tcpdump, tshark, wireshark
    - status: 三位数字，如200，301, 302, 404, 502; 标记请求处理过程中发生的情况;
        - 1xx: 100-101, 信息提示;
        - 2xx: 200-206, 成功
        - 3xx: 300-305, 重定向
        - 4xx: 400-415, 错误类信息，客户端错误
        - 5xx: 500-505, 错误类信息，服务器端错误
        - 常用的状态码: 
            - 200: 成功，请求的所有数据通过响应报文的entity-body部分发送;OK
            - 301: 请求的URL指向的资源已经被删除;但在响应报文中通过首部Location指明了资源现在所处的新位置;Moved Permanently
            - 302: 与301相似，但在响应报文中通过Location指明资源现在所处临时新位置; Found
            - 304: 客户端发出了条件式请求，但服务器上的资源未曾发生改变，则通过响应此响应状态码通知客户端;Not Modified
            - 401: 需要输入账号和密码认证方能访问资源;Unauthorized
            - 403: 请求被禁止;Forbidden
            - 404: 服务器无法找到客户端请求的资源;Not Found
            - 500: 服务器内部错误;Internal Server Error
            - 502: 代理服务器从后端服务器收到了一条伪响应;Bad Gateway
    - headers: 
        - 每个请求或响应报文可包含任意个首部;
        - 每个首部都有首部名称，后面跟一个冒号，而后跟上一个可选空格，接着是一个值;
        - 格式: 
            ```
            Name: Value

            Cache-Control:public, max-age=600
            Connection:keep-alive
            Content-Type:image/png
            Date:Tue, 28 Apr 2015 01:43:54 GMT
            ETag:"5af34e-ce6-504ea605b2e40"
            Last-Modified:Wed, 08 Oct 2014 14:46:09 GMT

            Accept:image/webp,*/*;q=0.8
            Accept-Encoding:gzip, deflate, sdch
            Accept-Language:zh-CN,zh;q=0.8
            Cache-Control:max-age=0
            Connection:keep-alive
            Host:access.redhat.com
            If-Modified-Since:Wed, 08 Oct 2014 14:46:09 GMT
            If-None-Match:"5af34e-ce6-504ea605b2e40"
            Referer:https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html-single/Installation_Guide/index.html
            User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.101 Safari/537.36
            ```
        - 首部的分类: 
            - 通用首部
                - Date: 报文的创建时间
                - Connection: 连接状态，如keep-alive, close
                - Via: 显示报文经过的中间节点
                - Cache-Control: 控制缓存
                - Pragma: 
            - 请求首部
                - Accept: 通过服务器自己可接受的媒体类型;
                - Accept-Charset: 
                - Accept-Encoding: 接受编码格式，如gzip
                - Accept-Language: 接受的语言
                - Client-IP: 
                - Host: 请求的服务器名称和端口号
                - Referer: 包含当前正在请求的资源的上一级资源;
                - User-Agent: 客户端代理
                - 条件式请求首部: 
                    - Expect: 
                    - If-Modified-Since: 自从指定的时间之后，请求的资源是否发生过修改;
                    - If-Unmodified-Since: 
                    - If-None-Match: 本地缓存中存储的文档的ETag标签是否与服务器文档的Etag不匹配;
                    - If-Match: 
                - 安全请求首部: 
                    - Authorization: 向服务器发送认证信息，如账号和密码;
                    - Cookie: 客户端向服务器发送cookie
                    - Cookie2: 
                - 代理请求首部:
                    - Proxy-Authorization: 向代理服务器认证
            - 响应首部
                - 信息性: 
                    - Age: 响应持续时长
                    - Server: 服务器程序软件名称和版本
                - 协商首部: 某资源有多种表示方法时使用
                    - Accept-Ranges: 服务器可接受的请求范围类型
                    - Vary: 服务器查看的其它首部列表;
                - 安全响应首部: 
                    - Set-Cookie: 向客户端设置cookie;
                    - Set-Cookie2: 
                    - WWW-Authenticate: 来自服务器的对客户端的质询认证表单
            - 实体首部
                - Allow: 列出对此实体可使用的请求方法
                - Location: 告诉客户端真正的实体位于何处
                - Content-Encoding:
                - Content-Language:
                - Content-Length: 主体的长度
                - Content-Location: 实体真正所处位置;
                - Content-Type: 主体的对象类型
                - 缓存相关: 
                    - ETag: 实体的扩展标签;
                    - Expires: 实体的过期时间;
                    - Last-Modified: 最后一次修改的时间
            - 扩展首部

- web资源: web resource
    - 静态资源（无须服务端做出额外处理）: .jpg, .png, .gif, .html, txt, .js, .css, .mp3, .avi
    - 动态资源（服务端需要通过执行程序做出处理，发送给客户端的是程序的运行结果）: .php, .jsp
    - 注意: 一个页面中展示的资源可能有多个;每个资源都需要单独请求;
    - 资源的标识机制: URL，Uniform Resource Locator: 用于描述服务器某特定资源的位置;
        - 例如: http://www.ifeng.com/
        - Scheme://Server[:Port][/PATH/TO/SOME_RESOURCE]

- 一次完整的http请求处理过程: 
    - 一次http事务: 请求<-->响应
    - (1) 建立或处理连接: 接收请求或拒绝请求;
    - (2) 接收请求: 接收来自于网络上的主机请求报文中对某特定资源的一次请求的过程;
    - (3) 处理请求: 对请求报文进行解析，获取客户端请求的资源及请求方法等相关信息;
    - (4) 访问资源: 获取请求报文中请求的资源;
    - (5) 构建响应报文
    - (6) 发送响应报文
    - (7) 记录日志

- 接收请求的模型: 并发访问响应模型: 
    - 单进程I/O模型: 启动一个进程处理用户请求;这意味着，一次只能处理一个请求，多个请求被串行响应;
    - 多进程I/O结构: 由父进程并行启动多个进程，每个子进程响应一个请求;
    - 复用的I/O结构: 一个进程响应n个请求;
        - 多线程模式: 一个进程生成n个线程，一个线程处理一个请求;
        - 事件驱动(event-driven): 一个进程直接n个请求;
    - 复用的多进程I/O结构: 启动多个（m）个进程，每个进程生成（n）个线程;
        - 响应的请求的数量: `m*n`

- 处理请求: 分析请求报文的http请求报文首部
    - http协议: 
        - http请求报文首部
        - http响应报文首部
    - 请求报文首部的格式: 
        - `<method> <URL> <VERSION>`
        - HEADERS: (name: value)
        - `<request body>`

- http服务器程序: 
    - httpd (apache)
    - nginx
    - lighttpd

- 应用程序服务器: 
    - IIS: .Net 
    - tomcat: .jsp

- URL: Unifrom Resource Locator
    - URL方案: scheme
    - 服务器地址: ip:port
    - 资源路径: 
        - http://www.example.com:80/bbs/index.php,
        - https://
    - 基本语法: `<scheme>://<user>:<password>@<host>:<port>/<path>[;<params>][?<query>][#<frag>]`
        - params: 参数，http://www.example.com/bbs/hello;gender=f
        - query: http://www.example.com/bbs/item.php?username=tom&title=abc
        - frag: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html-single/Installation_Guide/index.html#ch-Boot-x86
        - 相对URL
        - 绝对URL

- httpd的安装和使用: 
    - ASF: apache software foundation
        - httpd: apache (a patchy server)

- httpd的特性: 
    - 高度模块化: core + modules
    - DSO: dynamic shared object
    - MPM: Multipath processing Modules (多路处理模块)
        - prefork: 多进程模型，每个进程响应一个请求;
            - 一个主进程: 负责生成子进程及回收子进程;负责创建套接字;负责接收请求，并将其派发给某子进程进行处理;
            - n个子进程: 每个子进程处理一个请求;
            - 工作模型: 会预先生成几个空闲进程，随时等待用于响应用户请求;最大空闲和最小空闲;
        - worker: 多进程多线程模型，每线程处理一个用户请求;
            - 一个主进程: 负责生成子进程;负责创建套接字;负责接收请求，并将其派发给某子进程进行处理;
            - 多个子进程: 每个子进程负责生成多个线程;
            - 每个线程: 负责响应用户请求;
            - 并发响应数量: `m*n`
                - m: 子进程数量
                - n: 每个子进程所能创建的最大线程数量;
        - event: 事件驱动模型，多进程模型，每个进程响应多个请求;
            - 一个主进程 : 负责生成子进程;负责创建套接字;负责接收请求，并将其派发给某子进程进行处理;
            - 子进程: 基于事件驱动机制直接响应多个请求;
            - httpd-2.2: 仍为测试使用模型;
            - httpd-2.4: event可生产环境中使用;

- httpd的程序版本: 
    - httpd 1.3: 官方已经停止维护;
    - httpd 2.0
    - httpd 2.2
    - httpd 2.4: 目前最新稳定版;

- 安装httpd: 
    - rpm包: CentOS 发行版中直接提供;
    - 编译安装: 定制新功能，或其它原因;

- CentOS 6: httpd-2.2
    - 程序环境: 
        - 配置文件: 
            - `/etc/httpd/conf/httpd.conf`
            - `/etc/httpd/conf.d/*.conf`
        - 服务脚本: 
            - /etc/rc.d/init.d/httpd
            - 脚本配置文件: /etc/sysconfig/httpd
        - 主程序文件: 
            - /usr/sbin/httpd
            - /usr/sbin/httpd.event
            - /usr/sbin/httpd.worker
        - 日志文件: 
            - /var/log/httpd:
                - access_log: 访问日志
                - error_log: 错误日志
        - 站点文档: 
            - /var/www/html
        - 模块文件路径: 
            - /usr/lib64/httpd/modules
    - 服务控制和启动: 
        - chkconfig  httpd  on|off
        - service  {start|stop|restart|status|configtest|reload}  httpd

- CentOS 7: httpd-2.4
    - 程序环境: 
        - 配置文件: 
            - /etc/httpd/conf/httpd.conf
            - `/etc/httpd/conf.d/*.conf`
            - 模块相关的配置文件: `/etc/httpd/conf.modules.d/*.conf`
        - systemd unit file: 
            - /usr/lib/systemd/system/httpd.service
        - 主程序文件: 
            - /usr/sbin/httpd（httpd-2.4支持MPM的动态切换）
        - 日志文件: 
            - /var/log/httpd:
                - access_log: 访问日志
                - error_log: 错误日志
        - 站点文档: 
            - /var/www/html
        - 模块文件路径: 
            - /usr/lib64/httpd/modules    
    - 服务控制: 
        - systemctl  enable|disable  httpd.service
        - systemctl  {start|stop|restart|status}  httpd.service

### httpd的常用配置
    
- 主配置文件: /etc/httpd/conf/httpd.conf
    - 1: Global Environment
    - 2: 'Main' server configuration
    - 3: Virtual Hosts

- 配置格式: directive  value
    - directive: 不区分字符大小写;
    - value: 为路径时，是否区分字符大小写，取决于文件系统; 

- 常用配置: 
    - 1、修改监听的IP和PORT: `Listen [IP-address:]portnumber [protocol]`
        - (1) 省略IP表示为0.0.0.0;
        - (2) Listen指令可重复出现多次;
            ```
            Listen  80
            Listen  8080
            ```
        - (3) 修改监听socket，重启服务进程方可生效;
        - (4) 限制其必须通过ssl通信时，protocol需要定义为https;
    - 2、持久连接（保持连接，长连接）
        - Persistent Connection: tcp连续建立后，每个资源获取完成后不全断开连接，而是继续等待其它资源请求的进行;如何断开？
            - 数量限制
            - 时间限制
        - 副作用: 对并发访问量较大的服务器，长连接机制会使得后续某些请求无法得到正常 响应;
        - 折衷: 使用较短的持久连接时长，以及较少的请求数量;
            ```
            KeepAlive On|Off
            KeepAliveTimeout 15
            MaxKeepAliveRequests 100
            ```
        - 测试: 
            ```
            telnet  WEB_SERVER_IP  PORT
            GET  /URL  HTTP/1.1
            Host: WEB_SERVER_IP
            ```
        - 注意: httpd-2.4的KeepAliveTimeout可是毫秒级;`KeepAliveTimeout num[ms]`
    - 3、MPM
        - httpd-2.2不支持同时编译多个MPM模块，所以只能编译选定要使用的那个;CentOS 6的rpm包为此专门提供了三个应用程序文件，httpd(prefork), httpd.worker, httpd.event，分别用于实现对不同的MPM机制的支持;确认现在使用的是哪下程序文件的方法: `ps aux | grep httpd`
        - 默认使用的为/usr/sbin/httpd，其为prefork的MPM模块;
        - 查看httpd程序的模块列表: 
            - 查看静态编译的模块: `httpd  -l`
            - 查看静态编译及动态编译的模块: `httpd  -M`
        - 更换使用httpd程序，以支持其它MPM机制;
            ```
            /etc/sysconfig/httpd
            HTTPD=/usr/sbin/httpd.{worker,event}
            ```
        - 注意: 重启服务进程方可生效
        - MPM配置: 
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
            - worker的配置: 
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
            - PV: Page View
            - UV: Unit/User View
            - IP: 
    - 4、DSO, 动态共享对象
        - `/etc/httpd/conf.modules.d/00-proxy.conf`
        - 配置指定实现模块加载: `LoadModule  <mod_name>  <mod_path>`
        - 模块文件路径可使用相对路径: 相对于ServerRoot（默认/etc/httpd）
    - 5、定义'Main' server的文档页面路径
        - ServerName
            - 语法格式: `ServerName [scheme://]fully-qualified-domain-name[:port]`
        - DocumentRoot "" 文档路径映射: 
            - DoucmentRoot指向的路径为URL路径的起始位置, 其相当于站点URL的根路径;
                - URL PATH与FileSystem PATH不是等同的，而是存在一种映射关系: 
                    ```
                    URL /               -->     FileSystem /var/www/html/
                    /images/logo.jpg    -->     /var/www/html/images/logo.jpg
                    ```
    - 6、站点访问控制常见机制
        - 可基于两种机制指明对哪些资源进行何种访问控制
            - 文件系统路径: 
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
            - URL路径: 
                ```
                <Location  "">
                ...
                </Location>
                
                <LocationMatch "PATTERN">
                ...
                </LocationMatch>
                ```
        - `<Directory>`中“基于源地址”实现访问控制: 
            - httpd-2.2: order和allow、deny
                - order: 定义生效次序;写在后面的表示默认法则;
                - Allow from, Deny from
                    - 来源地址: 
                        - IP
                        - NetAddr:
                            - 172.16
                            - 172.16.0.0
                            - 172.16.0.0/16
                            - 172.16.0.0/255.255.0.0
            - httpd-2.4: 
                - 基于IP控制: 
                    - Require ip  IP地址或网络地址
                    - Require not ip IP地址或网络地址
                - 基于主机名控制: 
                    - Require host 主机名或域名
                    - Require not host 主机名或域名
                - 要放置于<RequireAll>配置块中或<RequireAny>配置块中;
            - 控制页面资源允许、拒绝所有来源的主机可访问: 
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
        - Options: Configures what features are available in a particular directory，后跟1个或多个以空白字符分隔的“选项”列表;
            - Indexes: 指明的URL路径下不存在与定义的主页面资源相符的资源文件时，返回索引列表给用户;
            - FollowSymLinks: 允许跟踪符号链接文件所指向的源文件;
            - None: 
            - All: All options except for MultiViews.
    - 7、定义站点主页面: 
        - DirectoryIndex  index.html  index.html.var
    - 8、定义路径别名
        - 格式: `Alias  /URL/  "/PATH/TO/SOMEDIR/"` 
        - Alias  /download/  "/rpms/pub/"
    - 9、设定默认字符集
        - AddDefaultCharset  UTF-8
        - 中文字符集: GBK, GB2312, GB18030
    - 10、日志设定
        - 日志类型: 访问日志 和 错误日志
        - 错误日志: 
            - ErrorLog  logs/error_log
            - LogLevel  warn
            - Possible values include: debug, info, notification, warning, error, crital, alert, emergency.
        - 访问日志: 
            - LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
            - CustomLog  logs/access_log  combined
            - LogFormat format strings: http://httpd.apache.org/docs/2.2/mod/mod_log_config.html#formats
                - %h: 客户端IP地址;
                - %l: Remote User, 通常为一个减号（“-”）;
                - %u: Remote user (from auth; may be bogus if return status (%s) is 401);非为登录访问时，其为一个减号;
                - %t: 服务器收到请求时的时间;
                - %r: First line of request，即表示请求报文的首行;记录了此次请求的“方法”，“URL”以及协议版本;
                - %>s: 响应状态码;
                - %b: 响应报文的大小，单位是字节;不包括响应报文的http首部;
                - %{Referer}i: 请求报文中首部“referer”的值;即从哪个页面中的超链接跳转至当前页面的;
                - %{User-Agent}i: 请求报文中首部“User-Agent”的值;即发出请求的应用程序;
    - 11、基于用户的访问控制
        - 认证质询: 
            - WWW-Authenticate: 响应码为401，拒绝客户端请求，并说明要求客户端提供账号和密码;
        - 认证: 
            - Authorization: 客户端用户填入账号和密码后再次发送请求报文;认证通过时，则服务器发送响应的资源;
            - 认证方式有两种: 
                - basic: 明文
                - digest: 消息摘要认证
        - 安全域: 需要用户认证后方能访问的路径;应该通过名称对其进行标识，以便于告知用户认证的原因;
        - 用户的账号和密码存放于何处？
            - 虚拟账号: 仅用于访问某服务时用到的认证标识
            - 存储: 
                - 文本文件;
                - SQL数据库;
                - ldap目录存储;
        - basic认证配置示例: 
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
                    - -c: 自动创建此处指定的文件，因此，仅应该在此文件不存在时使用;
                    - -m: md5格式加密
                    - -s: sha格式加密
                    - -D: 删除指定用户
                    - -b: 批模式添加用户
                        ```
                        htpasswd -cb /PATH/TO/HTTPD_PASSWD_FILE  username1 password1
                        htpasswd -cb /PATH/TO/HTTPD_PASSWD_FILE  username2 password2
                        ```
        - 另外: 基于组账号进行认证
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
                - 组文件: 每一行定义一个组
                - GRP_NAME: username1  username2  ...
    - 12、虚拟主机
        - 站点标识: socket
            - IP相同，但端口不同;
            - IP不同，但端口均为默认端口;
            - FQDN不同;
                - 请求报文中首部
                - Host: www.example.com 
        - 有三种实现方案: 
            - 基于ip: 为每个虚拟主机准备至少一个ip地址;
            - 基于port: 为每个虚拟主机使用至少一个独立的port;
            - 基于FQDN: 为每个虚拟主机使用至少一个FQDN;
        - 注意(专用于httpd-2.2): 一般虚拟机不要与中心主机混用;因此，要使用虚拟主机，得先禁用'main'主机;
            - 禁用方法: 注释中心主机的DocumentRoot指令即可;
        - 虚拟主机的配置方法: 
            ```
            <VirtualHost  IP:PORT>
                ServerName FQDN
                DocumentRoot  ""
            </VirtualHost>
            ```
        - 其它可用指令: 
            - ServerAlias: 虚拟主机的别名;可多次使用;
            - ErrorLog: 
            - CustomLog: 
            - `<Directory ""> ... </Directory>`
            - Alias
        - 基于IP的虚拟主机示例: 
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
        - 基于端口的虚拟主机: 
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
        - 基于FQDN的虚拟主机: 
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
        - 注意: 如果是httpd-2.2，则使用基于FQDN的虚拟主机时，需要事先使用如下指令: NameVirtualHost IP:PORT
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
    - 14、curl命令: 是基于URL语法在命令行方式下工作的文件传输工具，它支持FTP, FTPS, HTTP, HTTPS, GOPHER, TELNET, DICT, FILE及LDAP等协议。curl支持HTTPS认证，并且支持HTTP的POST、PUT等方法， FTP上传， kerberos认证，HTTP上传，代理服务器， cookies， 用户名/密码认证， 下载文件断点续传，上载文件断点续传, http代理服务器管道（ proxy tunneling）， 甚至它还支持IPv6， socks5代理服务器,，通过http代理服务器上传文件到FTP服务器等等，功能十分强大。
        - `curl  [options]  [URL...]`
        - curl的常用选项: 
            - `-A/--user-agent <string>` 设置用户代理发送给服务器
            - --basic 使用HTTP基本认证
            - --tcp-nodelay 使用TCP_NODELAY选项
            - -e/--referer <URL> 来源网址
            - `--cacert <file>` CA证书 (SSL)
            - --compressed 要求返回是压缩的格式
            - `-H/--header <line>`自定义首部信息传递给服务器
            - -I/--head 只显示响应报文首部信息
            - `--limit-rate <rate>` 设置传输速度
            - `-u/--user <user[:password]>`设置服务器的用户和密码
            - -0/--http1.0 使用HTTP 1.0
        - 另一个工具elinks: `elinks  [OPTION]... [URL]...`
            - -dump: 不进入交互式模式，而直接将URL的内容输出至标准输出; 
    - 15、user/group: 指定以哪个用户的身份运行httpd服务进程;
        - User apache
        - Group apache
    - 16、使用mod_deflate模块压缩页面优化传输速度
        - 适用场景: 
            - (1) 节约带宽，额外消耗CPU;同时，可能有些较老浏览器不支持;
            - (2) 压缩适于压缩的资源，例如文件文件;
        ```
        vim /etc/httpd/ANY_FILE.conf
        SetOutputFilter DEFLATE

        # mod_deflate configuration

        # Restrict compression to these MIME types
        AddOutputFilterByType DEFLATE text/plain 
        AddOutputFilterByType DEFLATE text/html
        AddOutputFilterByType DEFLATE application/xhtml+xml
        AddOutputFilterByType DEFLATE text/xml
        AddOutputFilterByType DEFLATE application/xml
        AddOutputFilterByType DEFLATE application/x-javascript
        AddOutputFilterByType DEFLATE text/javascript
        AddOutputFilterByType DEFLATE text/css

        # Level of compression (Highest 9 - Lowest 1)
        DeflateCompressionLevel 9

        # Netscape 4.x has some problems.
        BrowserMatch ^Mozilla/4  gzip-only-text/html

        # Netscape 4.06-4.08 have some more problems
        BrowserMatch  ^Mozilla/4\.0[678]  no-gzip

        # MSIE masquerades as Netscape, but it is fine
        BrowserMatch \bMSI[E]  !no-gzip !gzip-only-text/html
        ```
    - 17、https,  http over ssl
        - SSL会话的简化过程
            - (1) 客户端发送可供选择的加密方式，并向服务器请求证书;
            - (2) 服务器端发送证书以及选定的加密方式给客户端;
            - (3) 客户端取得证书并进行证书验正: 如果信任给其发证书的CA: 
                - (a) 验正证书来源的合法性;用CA的公钥解密证书上数字签名;
                - (b) 验正证书的内容的合法性: 完整性验正
                - (c) 检查证书的有效期限;
                - (d) 检查证书是否被吊销;
                - (e) 证书中拥有者的名字，与访问的目标主机要一致;
            - (4) 客户端生成临时会话密钥（对称密钥），并使用服务器端的公钥加密此数据发送给服务器，完成密钥交换;
            - (5) 服务器用此密钥加密用户请求的资源，响应给客户端;
        - 注意: SSL会话是基于IP地址创建;所以单IP的主机上，仅可以使用一个https虚拟主机;
        - 配置httpd支持https: 
            - (1) 为服务器申请数字证书;
                - 测试: 通过私建CA发证书
                    - (a) 创建私有CA
                    - (b) 在服务器创建证书签署请求
                    - (c) CA签证
            - (2) 配置httpd支持使用ssl，及使用的证书;
                - `yum -y install mod_ssl`
                - 配置文件: /etc/httpd/conf.d/ssl.conf
                    - DocumentRoot
                    - ServerName
                    - SSLCertificateFile
                    - SSLCertificateKeyFile
            - (3) 测试基于https访问相应的主机;
                - `# openssl  s_client  [-connect host:port] [-cert filename] [-CApath directory] [-CAfile filename]`
    - 18、httpd自带的工具程序
        - htpasswd: basic认证基于文件实现时，用到的账号密码文件生成工具;
        - apachectl: httpd自带的服务控制脚本，支持start和stop;
        - apxs: 由httpd-devel包提供，扩展httpd使用第三方模块的工具;
        - rotatelogs: 日志滚动工具;
            - access.log --> access.log, access.1.log --> access.log, acccess.1.log, access.2.log
        - suexec: 访问某些有特殊权限配置的资源时，临时切换至指定用户身份运行;
        - ab: apache bench
    - 19、httpd的压力测试工具
        - ab, webbench, http_load, seige
        - jmeter, loadrunner
        - tcpcopy: 网易，复制生产环境中的真实请求，并将之保存下来;
        - ab  [OPTIONS]  URL
            - -n: 总请求数;
            - -c: 模拟的并行数;
            - -k: 以持久连接模式 测试;

---

回顾: http协议基础， httpd-2.2的基础配置

    http协议: 请求<-->响应
        request: 
            <method>  <URL>  <version>
            <HEADERS>
            
            <entity>
            
        response
            <version>  <status code>  <reason phrase>
            <HEADERS>
            
            <entity>
            
        请求方法: GET, HEAD, POST, PUT, DELETE, OPTIONS, TRACE, ...
        
    httpd-2.2基本配置
        mod_deflate
        User/Group
        https (443/tcp)
        
    命令工具: curl, ab
    
    课外作业: 理解ab命令执行结果输出信息的意义;

httpd的基本应用(3)

    httpd-2.4: 
        
        新特性: 
            (1) MPM支持运行为DSO机制;以模块形式按需加载;
            (2) event MPM生产环境可用;
            (3) 异步读写机制;
            (4) 支持每模块及每目录的单独日志级别定义;
            (5) 每请求相关的专用配置;
            (6) 增强版的表达式分析式;
            (7) 毫秒级持久连接时长定义;
            (8) 基于FQDN的虚拟主机也不再需要NameVirutalHost指令;
            (9) 新指令，AllowOverrideList;
            (10) 支持用户自定义变量;
            (11) 更低的内存消耗;
            
        新模块: 
            (1) mod_proxy_fcgi
            (2) mod_proxy_scgi
            (3) mod_remoteip
            
        安装httpd-2.4
        
            依赖于apr-1.4+, apr-util-1.4+, [apr-iconv]
                apr: apache portable runtime
                
            CentOS 6: 
                默认: apr-1.3.9, apr-util-1.3.9
                
                开发环境包组: Development Tools, Server Platform Development
                开发程序包: pcre-devel 
                
                编译安装步骤: 
                    (1) apr-1.4+
                        # ./configure  --prefix=/usr/local/apr
                        # make && make install
                        
                    (2) apr-util-1.4+
                        # ./configure  --prefix=/usr/local/apr-util  --with-apr=/usr/local/apr
                        # make && make install
                        
                    (3) httpd-2.4
                        # ./configure --prefix=/usr/local/apache24 --sysconfdir=/etc/httpd24  --enable-so --enable-ssl --enable-cgi --enable-rewrite --with-zlib --with-pcre --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --enable-modules=most --enable-mpms-shared=all --with-mpm=prefork
                        # make  && make install
                        
                        自带的服务控制脚本: apachectl
                        
            CentOS 7: 
                # yum install  httpd
                
                配置文件: 
                    /etc/httpd/conf/httpd.conf
                    /etc/httpd/conf.modules.d/*.conf
                    /etc/httpd/conf.d/*.conf
                    
                配置应用: 
                    (1) 切换使用的MPM
                        编辑配置文件/etc/httpd/conf.modules.d/00-mpm.conf，启用要启用的MPM相关的LoadModule指令即可。
                        
                    (2) 基于IP的访问控制
                        允许所有主机访问: Require  all  granted
                        拒绝所有主机访问: Require  all  deny
                        
                        控制特定的IP访问: 
                            Require  ip  IPADDR: 授权指定来源的IP访问;
                            Require  not  ip  IPADDR: 拒绝
                            
                        控制特定的主机访问: 
                            Require  host  HOSTNAME: 授权指定来源的主机访问;
                            Require  not  host  HOSTNAME: 拒绝
                            
                            HOSTNAME: 
                                FQDN: 特定主机
                                domin.tld: 指定域名下的所有主机
                                                        
                        <RequireAll>
                            Require all granted
                            Require not ip 172.16.100.2
                        </RequireAll>                       
                        
                    (3) 虚拟主机
                        基于FQDN的虚拟主机也不再需要NameVirutalHost指令;
                        
                        <VirtualHost *:80>
                            ServerName www.b.net
                            DocumentRoot "/apps/b.net/htdocs"
                            <Directory "/apps/b.net/htdocs">
                                Options None
                                AllowOverride None
                                Require all granted
                            </Directory>
                        </VirtualHost>  
                        
                        注意: 任意目录下的页面只有显式授权才能被访问;
                        
                    (4) ssl
                    
                    (5)  KeepAliveTimeout  #ms
                        毫秒级持久连接时长定义;
                        
    练习题: 分别使用httpd-2.2和httpd-2.4实现;
    
        1、建立httpd服务，要求: 
            (1) 提供两个基于名称的虚拟主机: 
                www1.stuX.com，页面文件目录为/web/vhosts/www1;错误日志为/var/log/httpd/www1/error_log，访问日志为/var/log/httpd/www1/access_log;
                www2.stuX.com，页面文件目录为/web/vhosts/www2;错误日志为/var/log/httpd/www2/error_log，访问日志为/var/log/httpd/www2/access_log;
            (2) 通过www1.stuX.com/server-status输出其状态信息，且要求只允许提供账号的用户访问;
            (3) www1不允许192.168.1.0/24网络中的主机访问;
            
        2、为上面的第2个虚拟主机提供https服务，使得用户可以通过https安全的访问此web站点;
            (1) 要求使用证书认证，证书中要求使用国家（CN），州（Beijing），城市（Beijing），组织为(MageEdu);
            (2) 设置部门为Ops, 主机名为www2.stuX.com;
            
    
LAMP: 
        a: apache (httpd)
        m: mysql, mariadb
        p: php, perl, python
        
        WEB资源类型: 
            静态资源: 原始形式与响应内容一致;
            动态资源: 原始形式通常为程序文件，需要在服务器端执行之后，将执行结果返回给客户端;
            
            客户端技术: javascript
            服务器端技术: php, jsp
            
        CGI: Common Gateway Interface
            可以让一个客户端，从网页浏览器向执行在网络服务器上的程序传输数据;CGI描述了客户端和服务器程序之间传输的一种标准;
            
            程序=指令+数据
                数据模型: 
                    层次模型
                    网状模型
                    关系模型: 表（行+列）
                    
                关系模型: IngreSQL, Oracle, Sybase, Infomix, DB2, SQL Server, MySQL, PostgreSQL, MariaDB
                
                指令: 代码文件
                数据: 数据存储系统、文件
                
            请求流程: 
                Client -- (httpd) --> httpd -- (cgi) --> application server (program file) -- (mysql) --> mysql 
                
        php: 脚本编程语言、嵌入到html中的嵌入式web程序开发语言;
            基于zend编译成opcode（二进制格式的字节码，重复运行，可省略编译环境）
    
        关于PHP

            一、PHP简介
                
            PHP是通用服务器端脚本编程语言，其主要用于web开发以实现动态web页面，它也是最早实现将脚本嵌入HTML源码文档中的服务器端脚本语言之一。同时，php还提供了一个命令行接口，因此，其也可以在大多数系统上作为一个独立的shell来使用。

            Rasmus Lerdorf于1994年开始开发PHP，它是初是一组被Rasmus Lerdorf称作“Personal Home Page Tool” 的Perl脚本， 这些脚本可以用于显示作者的简历并记录用户对其网站的访问。后来，Rasmus Lerdorf使用C语言将这些Perl脚本重写为CGI程序，还为其增加了运行Web forms的能力以及与数据库交互的特性，并将其重命名为“Personal Home Page/Forms Interpreter”或“PHP/FI”。此时，PHP/FI已经可以用于开发简单的动态web程序了，这即是PHP 1.0。1995年6月，Rasmus Lerdorf把它的PHP发布于comp.infosystems.www.authoring.cgi Usenet讨论组，从此PHP开始走进人们的视野。1997年，其2.0版本发布。

            1997年，两名以色列程序员Zeev Suraski和Andi Gutmans重写的PHP的分析器(parser)成为PHP发展到3.0的基础，而且从此将PHP重命名为PHP: Hypertext Preprocessor。此后，这两名程序员开始重写整个PHP核心，并于1999年发布了Zend Engine 1.0，这也意味着PHP 4.0的诞生。2004年7月，Zend Engine 2.0发布，由此也将PHP带入了PHP 5时代。PHP5包含了许多重要的新特性，如增强的面向对象编程的支持、支持PDO(PHP Data Objects)扩展机制以及一系列对PHP性能的改进。

            二、PHP Zend Engine

            Zend Engine是开源的、PHP脚本语言的解释器，它最早是由以色列理工学院(Technion)的学生Andi Gutmans和Zeev Suraski所开发，Zend也正是此二人名字的合称。后来两人联合创立了Zend Technologies公司。

            Zend Engine 1.0于1999年随PHP 4发布，由C语言开发且经过高度优化，并能够做为PHP的后端模块使用。Zend Engine为PHP提供了内存和资源管理的功能以及其它的一些标准服务，其高性能、可靠性和可扩展性在促进PHP成为一种流行的语言方面发挥了重要作用。

            Zend Engine的出现将PHP代码的处理过程分成了两个阶段: 首先是分析PHP代码并将其转换为称作Zend opcode的二进制格式(类似Java的字节码)，并将其存储于内存中;第二阶段是使用Zend Engine去执行这些转换后的Opcode。

            三、PHP的Opcode

            Opcode是一种PHP脚本编译后的中间语言，就像Java的ByteCode,或者.NET的MSL。PHP执行PHP脚本代码一般会经过如下4个步骤(确切的来说，应该是PHP的语言引擎Zend): 
            1、Scanning(Lexing) —— 将PHP代码转换为语言片段(Tokens)
            2、Parsing —— 将Tokens转换成简单而有意义的表达式
            3、Compilation —— 将表达式编译成Opocdes
            4、Execution —— 顺次执行Opcodes，每次一条，从而实现PHP脚本的功能

                扫描-->分析-->编译-->执行

            四、php的加速器

            基于PHP的特殊扩展机制如opcode缓存扩展也可以将opcode缓存于php的共享内存中，从而可以让同一段代码的后续重复执行时跳过编译阶段以提高性能。由此也可以看出，这些加速器并非真正提高了opcode的运行速度，而仅是通过分析opcode后并将它们重新排列以达到快速执行的目的。

            常见的php加速器有: 

            1、APC (Alternative PHP Cache)
            遵循PHP License的开源框架，PHP opcode缓存加速器，目前的版本不适用于PHP 5.4。项目地址，http://pecl.php.net/package/APC。

            2、eAccelerator
            源于Turck MMCache，早期的版本包含了一个PHP encoder和PHP loader，目前encoder已经不在支持。项目地址， http://eaccelerator.net/。

            3、XCache
            快速而且稳定的PHP opcode缓存，经过严格测试且被大量用于生产环境。项目地址，http://xcache.lighttpd.net/

            4、Zend Optimizer和Zend Guard Loader
            Zend Optimizer并非一个opcode加速器，它是由Zend Technologies为PHP5.2及以前的版本提供的一个免费、闭源的PHP扩展，其能够运行由Zend Guard生成的加密的PHP代码或模糊代码。 而Zend Guard Loader则是专为PHP5.3提供的类似于Zend Optimizer功能的扩展。项目地址，http://www.zend.com/en/products/guard/runtime-decoders

            5、NuSphere PhpExpress
            NuSphere的一款开源PHP加速器，它支持装载通过NuSphere PHP Encoder编码的PHP程序文件，并能够实现对常规PHP文件的执行加速。项目地址，http://www.nusphere.com/products/phpexpress.htm

            五、PHP源码目录结构

            PHP的源码在结构上非常清晰。其代码根目录中主要包含了一些说明文件以及设计方案，并提供了如下子目录: 

            1、build —— 顾名思义，这里主要放置一些跟源码编译相关的文件，比如开始构建之前的buildconf脚本及一些检查环境的脚本等。
            2、ext —— 官方的扩展目录，包括了绝大多数PHP的函数的定义和实现，如array系列，pdo系列，spl系列等函数的实现。 个人开发的扩展在测试时也可以放到这个目录，以方便测试等。
            3、main —— 这里存放的就是PHP最为核心的文件了，是实现PHP的基础设施，这里和Zend引擎不一样，Zend引擎主要实现语言最核心的语言运行环境。
            4、Zend —— Zend引擎的实现目录，比如脚本的词法语法解析，opcode的执行以及扩展机制的实现等等。
            5、pear —— PHP 扩展与应用仓库，包含PEAR的核心文件。
            6、sapi —— 包含了各种服务器抽象层的代码，例如apache的mod_php，cgi，fastcgi以及fpm等等接口。
            7、TSRM —— PHP的线程安全是构建在TSRM库之上的，PHP实现中常见的*G宏通常是对TSRM的封装，TSRM(Thread Safe Resource Manager)线程安全资源管理器。
            8、tests —— PHP的测试脚本集合，包含PHP各项功能的测试文件。
            9、win32 —— 这个目录主要包括Windows平台相关的一些实现，比如sokcet的实现在Windows下和*Nix平台就不太一样，同时也包括了Windows下编译PHP相关的脚本。

        LAMP: 
            httpd: 接收用户的web请求;静态资源则直接响应;动态资源为php脚本，对此类资源的请求将交由php来运行;
            php: 运行php程序;
            MariaDB: 数据管理系统; 
            
            http与php结合的方式: 
                CGI 
                FastCGI 
                modules (把php编译成为httpd的模块)
                    MPM:
                        prefork: libphp5.so
                        event, worker: libphp5-zts.so
                        
            安装lamp: 
                CentOS 6: httpd, php, mysql-server, php-mysql
                    # service httpd  start
                    # service  mysqld  start
                CentOS 7: httpd, php, php-mysql, mariadb-server
                    # systemctl  start  httpd.service
                    # systemctl  start  mariadb.service
                    
                MySQL的命令行客户端程序: mysql
                    -u 
                    -h
                    -p
                    
                    支持SQL语句对数据管理: 
                        DDL，DML
                            DDL: CREATE， ALTER， DROP， SHOW
                            DML: INSERT， DELETE，SELECT， UPDATE
                            
                    授权能远程的连接用户: 
                        mysql> GRANT  ALL  PRIVILEGES  ON  db_name.tbl_name TO  username@host  IDENTIFIED BY 'password'; 
                        
                php测试代码
                    <php?
                        phpinfo();
                    ?>
                
                php连接mysql的测试代码: 
                    <?php
                        $conn = mysql_connect('172.16.100.67','testuser','testpass');
                        if ($conn) 
                            echo "OK";
                        else
                            echo "Failure";
                    ?>  
                    
        实践作业: 部署lamp，以虚拟主机安装wordpress, phpwind, discuz; 
        
回顾: httpd, lamp
    
    httpd: mod_deflate, https, 
    amp: 
        静态资源: Client -- http --> httpd
        动态资源: Client -- http --> httpd --> libphp5.so ()
        动态资源: Client -- http --> httpd --> libphp5.so () -- mysql --> MySQL server
        
    httpd+php:
        modules: 把php编译成为httpd的模块
        cgi: 
        fastcgi: 
        
    php: zend engine
        编译: Opcode是一种PHP脚本编译后的中间语言
        执行: 
        
        Scanning --> Parsing --> Compilation --> Execution
        
        加速器: APC，eAccelerator, Xcache
        
LAMP(2) 
    
    快速部署amp: 
        CentOS 7:
            Modules: 程序包，httpd, php, php-mysql, mariadb-server
            FastCGI: 程序包，httpd, php-fpm, php-mysql, mariadb-server
        CentOS 6: 
            httpd, php, php-mysql, mysql-server
            
    php: 
        脚本语言解释器
            配置文件: /etc/php.ini,  /etc/php.d/*.ini 
            
            配置文件在php解释器启动时被读取，因此，对配置文件的修改如何生效？
                Modules: 重启httpd服务;
                FastCGI: 重启php-fpm服务;
            
            ini: 
                [foo]: Section Header
                directive = value
                
                注释符: 较新的版本中，已经完全使用;进行注释;
                #: 纯粹的注释信息
                ;: 用于注释可启用的directive
                
                php.ini的核心配置选项文档: http://php.net/manual/zh/ini.core.php
                php.ini配置选项列表: http://php.net/manual/zh/ini.list.php
                
        <?php 
            ...php code...
        ?>
