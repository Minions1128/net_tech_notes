# HTTPD

- httpd的安装和使用: ASF: apache software foundation, httpd: apache (a patchy server)

- httpd的特性:
    - 高度模块化: core + modules
    - DSO: dynamic shared object
    - MPM: Multipath processing Modules (多路处理模块)
        - prefork: 多进程模型, 每个进程响应一个请求;
            - 一个主进程: 负责生成子进程及回收子进程;负责创建套接字;负责接收请求, 并将其派发给某子进程进行处理;
            - n个子进程: 每个子进程处理一个请求;
            - 工作模型: 会预先生成几个空闲进程, 随时等待用于响应用户请求;最大空闲和最小空闲;
        - worker: 多进程多线程模型, 每线程处理一个用户请求;
            - 一个主进程: 负责生成子进程;负责创建套接字;负责接收请求, 并将其派发给某子进程进行处理;
            - 多个子进程: 每个子进程负责生成多个线程;
            - 每个线程: 负责响应用户请求;
            - 并发响应数量: `m*n`
                - m: 子进程数量
                - n: 每个子进程所能创建的最大线程数量;
        - event: 事件驱动模型, 多进程模型, 每个进程响应多个请求;
            - 一个主进程 : 负责生成子进程;负责创建套接字;负责接收请求, 并将其派发给某子进程进行处理;
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
    - 编译安装: 定制新功能, 或其它原因;

- CentOS 6: httpd-2.2
    - 程序环境:
        - 配置文件:
            - `/etc/httpd/conf/httpd.conf`
            - `/etc/httpd/conf.d/*.conf`
        - 服务脚本:
            - `/etc/rc.d/init.d/httpd`
            - 脚本配置文件: `/etc/sysconfig/httpd`
        - 主程序文件:
            - `/usr/sbin/httpd`
            - `/usr/sbin/httpd.event`
            - `/usr/sbin/httpd.worker`
        - 日志文件:
            - /var/log/httpd:
                - access_log: 访问日志
                - error_log: 错误日志
        - 站点文档: /var/www/html
        - 模块文件路径: /usr/lib64/httpd/modules
    - 服务控制和启动:
        - chkconfig httpd {on|off}
        - service {start|stop|restart|status|configtest|reload} httpd

- CentOS 7: httpd-2.4
    - 程序环境:
        - 配置文件:
            - /etc/httpd/conf/httpd.conf
            - `/etc/httpd/conf.d/*.conf`
            - 模块相关的配置文件: `/etc/httpd/conf.modules.d/*.conf`
        - systemd unit file: `/usr/lib/systemd/system/httpd.service`
        - 主程序文件: /usr/sbin/httpd(httpd-2.4支持MPM的动态切换)
        - 日志文件:
            - /var/log/httpd:
                - access_log: 访问日志
                - error_log: 错误日志
        - 站点文档: /var/www/html
        - 模块文件路径: /usr/lib64/httpd/modules
    - 服务控制:
        - systemctl {enable|disable} httpd.service
        - systemctl {start|stop|restart|status} httpd.service

### httpd的常用配置

- 主配置文件: /etc/httpd/conf/httpd.conf
    - 1: Global Environment
    - 2: 'Main' server configuration
    - 3: Virtual Hosts

- 配置格式: directive value
    - directive: 不区分字符大小写;
    - value: 为路径时, 是否区分字符大小写, 取决于文件系统;

- 1, 修改监听的IP和PORT: `Listen [IP-address:]portnumber [protocol]`
    - (1) 省略IP表示为0.0.0.0;
    - (2) Listen指令可重复出现多次;
        ```
        Listen  80
        Listen  8080
        ```
    - (3) 修改监听socket, 重启服务进程方可生效;
    - (4) 限制其必须通过ssl通信时, protocol需要定义为https;

- 2, 持久连接(保持连接, 长连接)
    - Persistent Connection: tcp连续建立后, 每个资源获取完成后不全断开连接, 而是继续等待其它资源请求的进行;如何断开?
        - 数量限制
        - 时间限制
    - 副作用: 对并发访问量较大的服务器, 长连接机制会使得后续某些请求无法得到正常响应;
    - 折衷: 使用较短的持久连接时长, 以及较少的请求数量;
        ```
        KeepAlive On|Off
        KeepAliveTimeout 15
        MaxKeepAliveRequests 100
        ```
    - 测试:
        ```
        telnet WEB_SERVER_IP PORT
        GET /URL HTTP/1.1
        Host: WEB_SERVER_IP
        ```
    - 注意: httpd-2.4的KeepAliveTimeout可是毫秒级;`KeepAliveTimeout num[ms]`

- 3, MPM
    - httpd-2.2不支持同时编译多个MPM模块, 所以只能编译选定要使用的那个;CentOS 6的rpm包为此专门提供了三个应用程序文件, httpd(prefork), httpd.worker, httpd.event, 分别用于实现对不同的MPM机制的支持;确认现在使用的是哪下程序文件的方法: `ps aux | grep httpd`
    - 默认使用的为/usr/sbin/httpd, 其为prefork的MPM模块;
    - 查看httpd程序的模块列表:
        - 查看静态编译的模块: `httpd -l`
        - 查看静态编译及动态编译的模块: `httpd -M`
    - 更换使用httpd程序, 以支持其它MPM机制;
        ```
        /etc/sysconfig/httpd
        HTTPD=/usr/sbin/httpd.{worker,event}
        ```
    - 注意: 重启服务进程方可生效
    - MPM配置:
        - prefork的配置
            ```html
            <IfModule prefork.c>
                StartServers               8
                MinSpareServers            5
                MaxSpareServers           20
                ServerLimit              256
                MaxClients               256
                MaxRequestsPerChild     4000
            </IfModule>
            ```
        - worker的配置:
            ```html
            <IfModule worker.c>
                StartServers         4
                MaxClients         300
                MinSpareThreads     25
                MaxSpareThreads     75
                ThreadsPerChild     25
                MaxRequestsPerChild  0
            </IfModule>
            ```
    - PV, UV
        - PV: Page View
        - UV: Unit/User View
        - IP:

- 4, DSO, 动态共享对象
    - `/etc/httpd/conf.modules.d/00-proxy.conf`
    - 配置指定实现模块加载: `LoadModule <mod_name> <mod_path>`
    - 模块文件路径可使用相对路径: 相对于ServerRoot(默认/etc/httpd)

- 5, 定义'Main' server的文档页面路径
    - ServerName
        - 语法格式: `ServerName [scheme://]fully-qualified-domain-name[:port]`
    - DocumentRoot: 文档路径映射, 指向的路径为URL路径的起始位置, 其相当于站点URL的根路径;
        - URL PATH与FileSystem PATH不是等同的, 而是存在一种映射关系:
            ```
            URL /               -->     FileSystem /var/www/html/
            /images/logo.jpg    -->     /var/www/html/images/logo.jpg
            ```

- 6, 站点访问控制常见机制
    - 可基于两种机制指明对哪些资源进行何种访问控制
        - 文件系统路径:
            ```html
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
            ```html
            <Location  "">
            ...
            </Location>
            <LocationMatch "PATTERN">
            ...
            </LocationMatch>
            ```
    - `<Directory>`中“基于源地址”实现访问控制:
        - httpd-2.2: order和allow, deny
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
        - 控制页面资源允许, 拒绝所有来源的主机可访问:
            - httpd-2.2
                ```html
                <Directory "">
                    ...
                    Order allow,deny
                    Allow from all          # 允许
                    Allow from 172.30.50    # 允许172.30.50端访问
                    Deny from all           # 拒绝
                </Directory>
                ```
            - httpd-2.4
                ```html
                <Directory "">
                    ...
                    Require all granted     # 允许
                    Require all denied      # 拒绝
                </Directory>
                ```
    - Options: Configures what features are available in a particular directory, 后跟1个或多个以空白字符分隔的“选项”列表;
        - Indexes: 指明的URL路径下不存在与定义的主页面资源相符的资源文件时, 返回索引列表给用户;
        - FollowSymLinks: 允许跟踪符号链接文件所指向的源文件;
        - None:
        - All: All options except for MultiViews.

- 7, 定义站点主页面: DirectoryIndex index.html index.html.var

- 8, 定义路径别名
    - 格式: `Alias /URL/ "/PATH/TO/SOMEDIR/"`
    - `Alias /download/ "/rpms/pub/"`

- 9, 设定默认字符集
    - AddDefaultCharset UTF-8
    - 中文字符集: GBK, GB2312, GB18030

- 10, 日志设定
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
            - %l: Remote User, 通常为一个减号(“-”);
            - %u: Remote user (from auth; may be bogus if return status (%s) is 401);非为登录访问时, 其为一个减号;
            - %t: 服务器收到请求时的时间;
            - %r: First line of request, 即表示请求报文的首行;记录了此次请求的“方法”, “URL”以及协议版本;
            - %>s: 响应状态码;
            - %b: 响应报文的大小, 单位是字节;不包括响应报文的http首部;
            - %{Referer}i: 请求报文中首部“referer”的值;即从哪个页面中的超链接跳转至当前页面的;
            - %{User-Agent}i: 请求报文中首部“User-Agent”的值;即发出请求的应用程序;

- 11, 基于用户的访问控制
    - 认证质询:
        - WWW-Authenticate: 响应码为401, 拒绝客户端请求, 并说明要求客户端提供账号和密码;
    - 认证:
        - Authorization: 客户端用户填入账号和密码后再次发送请求报文;认证通过时, 则服务器发送响应的资源;
        - 认证方式有两种:
            - basic: 明文
            - digest: 消息摘要认证
    - 安全域: 需要用户认证后方能访问的路径;应该通过名称对其进行标识, 以便于告知用户认证的原因;
    - 用户的账号和密码存放于何处?
        - 虚拟账号: 仅用于访问某服务时用到的认证标识
        - 存储:
            - 文本文件;
            - SQL数据库;
            - ldap目录存储;
    - basic认证配置示例:
        - (1) 定义安全域
            ```html
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
        - (2) 提供账号和密码存储(文本文件), 使用专用命令完成此类文件的创建及用户管理
            - `htpasswd  [options]   /PATH/TO/HTTPD_PASSWD_FILE  username `
                - -c: 自动创建此处指定的文件, 因此, 仅应该在此文件不存在时使用;
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
            ```html
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

- 12, 虚拟主机
    - 站点标识: socket
        - IP相同, 但端口不同;
        - IP不同, 但端口均为默认端口;
        - FQDN不同;
            - 请求报文中首部
            - Host: www.example.com
    - 有三种实现方案:
        - 基于ip: 为每个虚拟主机准备至少一个ip地址;
        - 基于port: 为每个虚拟主机使用至少一个独立的port;
        - 基于FQDN: 为每个虚拟主机使用至少一个FQDN;
    - 注意(专用于httpd-2.2): 一般虚拟机不要与中心主机混用;因此, 要使用虚拟主机, 得先禁用'main'主机;
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
        ```html
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
        ```html
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
        ```html
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
    - 注意: 如果是httpd-2.2, 则使用基于FQDN的虚拟主机时, 需要事先使用如下指令: NameVirtualHost IP:PORT

- 13, status页面
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

- 14, curl命令: 是基于URL语法在命令行方式下工作的文件传输工具, 它支持FTP, FTPS, HTTP, HTTPS, GOPHER, TELNET, DICT, FILE及LDAP等协议. curl支持HTTPS认证, 并且支持HTTP的POST, PUT等方法,  FTP上传,  kerberos认证, HTTP上传, 代理服务器, cookies, 用户名/密码认证, 下载文件断点续传, 上载文件断点续传, http代理服务器管道(proxy tunneling), 甚至它还支持IPv6, socks5代理服务器, 通过http代理服务器上传文件到FTP服务器等等, 功能十分强大.
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
        - -dump: 不进入交互式模式, 而直接将URL的内容输出至标准输出;

- 15, user/group: 指定以哪个用户的身份运行httpd服务进程;
    - User apache
    - Group apache

- 16, 使用mod_deflate模块压缩页面优化传输速度
    - 适用场景:
        - (1) 节约带宽, 额外消耗CPU;同时, 可能有些较老浏览器不支持;
        - (2) 压缩适于压缩的资源, 例如文件;
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

- 17, https, http over ssl
    - SSL会话的简化过程
        - (1) 客户端发送可供选择的加密方式, 并向服务器请求证书;
        - (2) 服务器端发送证书以及选定的加密方式给客户端;
        - (3) 客户端取得证书并进行证书验正: 如果信任给其发证书的CA:
            - (a) 验正证书来源的合法性;用CA的公钥解密证书上数字签名;
            - (b) 验正证书的内容的合法性: 完整性验正
            - (c) 检查证书的有效期限;
            - (d) 检查证书是否被吊销;
            - (e) 证书中拥有者的名字, 与访问的目标主机要一致;
        - (4) 客户端生成临时会话密钥(对称密钥), 并使用服务器端的公钥加密此数据发送给服务器, 完成密钥交换;
        - (5) 服务器用此密钥加密用户请求的资源, 响应给客户端;
    - 注意: SSL会话是基于IP地址创建; 所以单IP的主机上, 仅可以使用一个https虚拟主机;
    - 配置httpd支持https:
        - (1) 为服务器申请数字证书;
            - 测试: 通过私建CA发证书
                - (a) 创建私有CA
                - (b) 在服务器创建证书签署请求
                - (c) CA签证
        - (2) 配置httpd支持使用ssl, 及使用的证书;
            - `yum -y install mod_ssl`
            - 配置文件: /etc/httpd/conf.d/ssl.conf
                - DocumentRoot
                - ServerName
                - SSLCertificateFile
                - SSLCertificateKeyFile
        - (3) 测试基于https访问相应的主机;
            - `# openssl  s_client  [-connect host:port] [-cert filename] [-CApath directory] [-CAfile filename]`

- 18, httpd自带的工具程序
    - htpasswd: basic认证基于文件实现时, 用到的账号密码文件生成工具;
    - apachectl: httpd自带的服务控制脚本, 支持start和stop;
    - apxs: 由httpd-devel包提供, 扩展httpd使用第三方模块的工具;
    - rotatelogs: 日志滚动工具;
        - access.log --> access.log, access.1.log --> access.log, acccess.1.log, access.2.log
    - suexec: 访问某些有特殊权限配置的资源时, 临时切换至指定用户身份运行;
    - ab: apache bench

- 19, httpd的压力测试工具
    - ab, webbench, http_load, seige
    - jmeter, loadrunner
    - tcpcopy: 网易, 复制生产环境中的真实请求, 并将之保存下来;
    - ab  [OPTIONS]  URL
        - -n: 总请求数;
        - -c: 模拟的并行数;
        - -k: 以持久连接模式 测试;
