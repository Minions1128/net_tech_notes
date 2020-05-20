# Nginx

- NGINX is a free, open-source, high-performance HTTP server and reverse proxy, as well as an IMAP/POP3 proxy server. NGINX is known for its high performance, stability, rich feature set, simple configuration, and low resource consumption.

## Nginx概述

![nginx.arch](https://github.com/Minions1128/net_tech_notes/blob/master/img/nginx.png "nginx.arch")

- master/worker
    - 一个master进程: 负载加载和分析配置文件, 管理worker进程, 平滑升级
    - 一个或多个worker进程: 处理并响应用户请求
    - 缓存相关的进程:
        - cache loader: 载入缓存对象
        - cache manager: 管理缓存对象

- 特性: 异步, 事件驱动和非阻塞
    - 并发请求处理: 通过epoll/select
    - 文件IO: 高级IO sendfile, 异步, mmap

- nginx模块: 高度模块化, 但其模块早期不支持DSO机制; 近期版本支持动态装载和卸载; 模块分类:
    - 核心模块: core module
    - 标准模块:
        - HTTP modules:
            - Standard HTTP modules
            - Optional HTTP modules
        - Mail modules
        - Stream modules: 传输层代理
    - 3rd party modules

- nginx的功用:
    - 静态的web资源服务器; (图片服务器, 或js/css/html/txt等静态资源服务器)
    - 结合FastCGI/uwSGI/SCGI等协议反代动态资源请求;
    - http/https协议的反向代理;
    - imap4/pop3协议的反向代理;
    - tcp/udp协议的请求转发;

## 安装

- 官方的预制包: http://nginx.org/packages/centos/7/x86_64/RPMS/

- 编译安装

```sh
yum groupinstall "Development Tools" "Server Platform Development"
yum install pcre-devel openssl-devel zlib-devel
useradd -r nginx
./configure --prefix=/usr/local/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --user=nginx --group=nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_dav_module \
    --with-http_stub_status_module \
    --with-threads \
    --with-file-aio
make && make install
```

- 程序环境
    - 配置文件的组成部分:
        - 主配置文件: `nginx.conf`, `include conf.d/*.conf`
        - fastcgi, uwsgi, scgi等协议相关的配置文件
        - mime.types: 支持的mime类型
    - 主程序文件: /usr/sbin/nginx
    - Unit File: nginx.service

## 配置

- 主配置文件的配置指令: `directive value [value2 ...];`

- 注意:
    - (1) 指令必须以分号结尾;
    - (2) 支持使用配置变量;
        - 内建变量: 由Nginx模块引入, 可直接引用;
        - 自定义变量: 由用户使用set命令定义;
            ```
            set variable_name value;
            引用变量: $variable_name
            ```

- 主配置文件结构:

```sh
main block # 主配置段, 也即全局配置段;
event {
        ...
}   # 事件驱动相关的配置;
http {
    ...
    ...     # 各server的公共配置
    server {
        ...
    }       # 每个server用于定义一个虚拟主机;
    server {
        ...
        listen
        server_name
        root
        alias
        location [OPERATOR] URL {
            ...
            if CONDITION {
                ...
            }
        }
    }
}   # http/https 协议相关的配置段;
mail {
    ...
}
stream {
    ...
}
```

### main配置段常见的配置指令

- 正常运行必备的配置
    - 1, `user user [group]`: Defines user and group credentials used by worker processes. If group is omitted, a group whose name equals that of user is used.
    - 2, `pid /PATH/TO/PID_FILE;` 指定存储nginx主进程进程号码的文件路径;
    - 3, `include file | mask;` 指明包含进来的其它配置文件片断;

    - 4, `load_module file;` 指明要装载的动态模块;

- 优化性能相关的配置
    - 1, worker_processes number | auto;
        - worker_processes进程的数量; 通常应该等于小于当前主机的cpu的物理核心数;
        - auto: 当前主机物理CPU核心数;
    - 2, worker_cpu_affinity cpumask ...;
        - worker_cpu_affinity auto [cpumask];
        - CPU MASK:
            - 00000000:
            - 00000001: 0号CPU
            - 00000010: 1号CPU
    - 3, worker_priority number; 指定worker进程的nice值, 设定worker进程优先级; [-20,20]
    - 4, worker_rlimit_nofile number; worker进程所能够打开的文件数量上限;

- 用于调试及定位问题相关的配置
    - 1, daemon on|off; 是否以守护进程方式运行Nignx;
    - 2, master_process on|off; 是否以master/worker模型运行nginx; 默认为on; off, master也会处理worker进程的事务.
    - 3, error_log file [level];

- 事件驱动相关的配置 `events { ...; }`
    - 1, worker_connections number; 每个worker进程所能够打开的最大并发连接数数量; worker_processes * worker_connections
    - 2, use method; 指明并发连接请求的处理方法; use {epoll|select};
    - 3, accept_mutex on | off; 处理新的连接请求的方法;
        - on意味着由各worker轮流处理新请求
        - off意味着每个新请求的到达都会通知所有的worker进程;

### http配置段

- 与套接字相关的配置:
    - 1, `server { ... }`: 配置一个虚拟主机;
        ```
        server {
            listen address[:PORT]|PORT;
            server_name SERVER_NAME;
            root /PATH/TO/DOCUMENT_ROOT;
        }
        ```
    - 2, listen: `listen {PORT | address [:port] | listen unix:/var/run/nginx.sock} [default_server] [ssl] [http2 | spdy] [backlog=number] [rcvbuf=size] [sndbuf=size]`
        - default_server: 设定为默认虚拟主机;
        - ssl: 限制仅能够通过ssl连接提供服务;
        - backlog=number: 后援队列长度;
        - rcvbuf=size: 接收缓冲区大小;
        - sndbuf=size: 发送缓冲区大小;
    - 3, server_name name ...; 指明虚拟主机的主机名称; 后可跟多个由空白字符分隔的字符串;
        - 支持`*`通配任意长度的任意字符; `server_name *.example.com  www.example.*`
        - 支持`~`起始的字符做正则表达式模式匹配; `server_name ~^www\d+\.example\.com$;`
        - 匹配机制:
            - (1) 首先是字符串精确匹配;
            - (2) 左侧`*`通配符;
            - (3) 右侧`*`通配符;
            - (4) 正则表达式;
        - example: 定义四个虚拟主机, 混合使用三种类型的虚拟主机; 仅开放给来自于本地网络中的主机访问;
    - 4, tcp_nodelay on | off; 在keepalived模式下的连接是否启用TCP_NODELAY选项;
    - 5, sendfile on | off; 是否启用sendfile功能;
    - 5.1, tcp_nopush on|off; 在sendfile模式下, 是否启用TCP_CORK选项;

- 定义路径相关的配置:
    - 6, root path; 设置web资源路径映射; 用于指明用户请求的url所对应的本地文件系统上的文档所在目录路径; 可用的位置: http, server, location, if in location;
    - 7, `location [ = | ~ | ~* | ^~ ] uri { ... }` Sets configuration depending on a request URI. 在一个server中location配置段可存在多个, 用于实现从uri到文件系统的路径映射; ngnix会根据用户请求的URI来检查定义的所有location, 并找出一个最佳匹配, 而后应用其配置;
        - `=`: 对URI做精确匹配; 例如, http://www.example.com/, http://www.example.com/index.html
            ```
            location  =  / {
               ...
            }
            ```
        - `~`: 对URI做正则表达式模式匹配, 区分字符大小写;
        - `~*`: 对URI做正则表达式模式匹配, 不区分字符大小写;
        - `^~`: 对URI的左半部分做匹配检查, 不区分字符大小写;
        - 不带符号: 匹配起始于此uri的所有的url;
        - 匹配优先级: `=, ^~, ～/～*, 不带符号;`
            ```
            root /vhosts/www/htdocs/
                http://www.example.com/index.html --> /vhosts/www/htdocs/index.html
            server {
                root  /vhosts/www/htdocs/

                location /admin/ {
                   root /webapps/app1/data/
                }
            }
            ```
    - 8, alias path; 定义路径别名, 文档映射的另一种机制; 仅能用于location上下文;
        - 注意: location中使用root指令和alias指令的意义不同;
            - (a) root, 给定的路径对应于location中的/uri/左侧的/;
            - (b) alias, 给定的路径对应于location中的/uri/右侧的/;
    - 9, index file ...; 默认资源; http, server, location;
    - 10, error_page code ... [=[response]] uri; Defines the URI that will be shown for the specified errors.
    - 11, try_files file ... uri;

- 定义客户端请求的相关配置
    - 12, keepalive_timeout timeout [header_timeout]; 设定保持连接的超时时长, 0表示禁止长连接; 默认为75s;
    - 13, keepalive_requests number; 在一次长连接上所允许请求的资源的最大数量, 默认为100;
    - 14, keepalive_disable none | browser ...; 对哪种浏览器禁用长连接;
    - 15, send_timeout time; 向客户端发送响应报文的超时时长, 此处, 是指两次写操作之间的间隔时长;
    - 16, client_body_buffer_size size; 用于接收客户端请求报文的body部分的缓冲区大小; 默认为16k; 超出此大小时, 其将被暂存到磁盘上的由client_body_temp_path指令所定义的位置;
    - 17, client_body_temp_path path [level1 [level2 [level3]]]; 设定用于存储客户端请求报文的body部分的临时存储路径及子目录结构和数量; 16进制的数字;
        - `client_body_temp_path /var/tmp/client_body 2 1 1`
            - 1: 表示用一位16进制数字表示一级子目录; 0-f
            - 2: 表示用2位16进程数字表示二级子目录: 00-ff
            - 2: 表示用2位16进程数字表示三级子目录: 00-ff

- 对客户端进行限制的相关配置:
    - 18, limit_rate rate; 限制响应给客户端的传输速率, 单位是bytes/second, 0表示无限制;
    - 19, limit_except method ... { ... } 限制对指定的请求方法之外的其它方法的使用客户端;
        ```
        limit_except GET {
            allow 192.168.1.0/24;
            deny  all;
        }
        ```

- 文件操作优化的配置
    - 20, aio on | off | threads[=pool]; 是否启用aio功能;
    - 21, directio size | off; 在Linux主机启用O_DIRECT标记, 此处意味文件大于等于给定的大小时使用, 例如directio 4m;
    - 22, open_file_cache off;
        - `open_file_cache max=N [inactive=time];` nginx可以缓存以下三种信息:
            - (1) 文件的描述符, 文件大小和最近一次的修改时间;
            - (2) 打开的目录结构;
            - (3) 没有找到的或者没有权限访问的文件的相关信息;
            - max=N: 可缓存的缓存项上限; 达到上限后会使用LRU算法实现缓存管理;
            - inactive=time: 缓存项的非活动时长, 在此处指定的时长内未被命中的或命中的次数少于open_file_cache_min_uses指令所指定的次数的缓存项即为非活动项;
    - 23, open_file_cache_valid time; 缓存项有效性的检查频率; 默认为60s;
    - 24, open_file_cache_min_uses number; 在open_file_cache指令的inactive参数指定的时长内, 至少应该被命中多少次方可被归类为活动项;
    - 25, open_file_cache_errors on | off; 是否缓存查找时发生错误的文件一类的信息;

- ngx_http_access_module模块: 实现基于ip的访问控制功能
    - 26, allow address | CIDR | unix: | all;
    - 27, deny address | CIDR | unix: | all;
    - http, server, location, limit_except

- ngx_http_auth_basic_module模块: 实现基于用户的访问控制, 使用basic机制进行用户认证;
    - 28, auth_basic string | off;
    - 29, auth_basic_user_file file;
        ```
        location /admin/ {
            alias /webapps/app1/data/;
            auth_basic "Admin Area";
            auth_basic_user_file /etc/nginx/.ngxpasswd;
        }
        ```
    - 注意: htpasswd 命令由httpd-tools所提供;

- ngx_http_stub_status_module模块 用于输出nginx的基本状态信息;
    - examples:
        ```
        Active connections: 291
        server accepts handled requests
            16630948 16630948 31070465
        Reading: 6 Writing: 179 Waiting: 106
        ```
        - Active connections: 活动状态的连接数;
        - accepts: 已经接受的客户端请求的总数;
        - handled: 已经处理完成的客户端请求的总数;
        - requests: 客户端发来的总的请求数;
        - Reading: 处于读取客户端请求报文首部的连接的连接数;
        - Writing: 处于向客户端发送响应报文过程中的连接数;
        - Waiting: 处于等待客户端发出请求的空闲连接数;
    - 30, stub_status; 配置示例:
        ```
        location  /basic_status {
            stub_status;
        }
        ```

- ngx_http_log_module模块: writes request logs in the specified format.
    - 31, log_format name string ...;
        - string可以使用nginx核心模块及其它模块内嵌的变量;
        - whats more: 为nginx定义使用类似于httpd的combined格式的访问日志;
    - 32, access_log { path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]] | off }; 访问日志文件路径, 格式及相关的缓冲的配置;
        - buffer=size
        - flush=time
    - 33, open_log_file_cache { max=N [inactive=time] [min_uses=N] [valid=time] | off }; 缓存各日志文件相关的元数据信息;
        - max: 缓存的最大文件描述符数量;
        - min_uses: 在inactive指定的时长内访问大于等于此值方可被当作活动项;
        - inactive: 非活动时长;
        - valid: 验正缓存中各缓存项是否为活动项的时间间隔;

- ngx_http_gzip_module: a filter that compresses responses using the “gzip” method. This often helps to reduce the size of transmitted data by half or even more.
    - 1, gzip on | off; Enables or disables gzipping of responses.
    - 2, gzip_comp_level level; Sets a gzip compression level of a response. Acceptable values are in the range from 1 to 9.
    - 3, gzip_disable regex ...; Disables gzipping of responses for requests with “User-Agent” header fields matching any of the specified regular expressions.
    - 4, gzip_min_length length; 启用压缩功能的响应报文大小阈值;
    - 5, gzip_buffers number size; 支持实现压缩功能时为其配置的缓冲区数量及每个缓存区的大小;
    - 6, gzip_proxied { off | expired | no-cache | no-store | private | no_last_modified | no_etag | auth | any ... }; nginx作为代理服务器接收到从被代理服务器发送的响应报文后, 在何种条件下启用压缩功能的;
        - off: 对代理的请求不启用
        - no-cache, no-store, private: 表示从被代理服务器收到的响应报文首部的Cache-Control的值为此三者中任何一个, 则启用压缩功能;
    - 7, gzip_types mime-type ...; 压缩过滤器, 仅对此处设定的MIME类型的内容启用压缩功能;

- ngx_http_gzip_module 配置示例:

```
gzip  on;
gzip_comp_level 6;
gzip_min_length 64;
gzip_proxied any;
gzip_types text/xml text/css  application/javascript;
```

- ngx_http_ssl_module 模块:
    - 1, ssl on | off; Enables the HTTPS protocol for the given virtual server.
    - 2, ssl_certificate file; 当前虚拟主机使用PEM格式的证书文件;
    - 3, ssl_certificate_key file; 当前虚拟主机上与其证书匹配的私钥文件;
    - 4, ssl_protocols [SSLv2] [SSLv3] [TLSv1] [TLSv1.1] [TLSv1.2]; 支持ssl协议版本, 默认为后三个;
    - 5, ssl_session_cache off | none | [builtin[:size]] [shared:name:size];
        - builtin[:size]: 使用OpenSSL内建的缓存, 此缓存为每worker进程私有;
        - [shared:name:size]: 在各worker之间使用一个共享的缓存;
    - 6, ssl_session_timeout time; 客户端一侧的连接可以复用ssl session cache中缓存 的ssl参数的有效时长;

- ngx_http_ssl_module 配置示例:

```
server {
    listen 443 ssl;
    server_name www.example.com;
    root /vhosts/ssl/htdocs;
    ssl on;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_session_cache shared:sslcache:20m;
}
```

- ngx_http_rewrite_module模块: used to change request URI using PCRE regular expressions, return redirects, and conditionally select configurations. 将用户请求的URI基于regex所描述的模式进行检查, 而后完成替换;
    - 举例:
        - bbs.example.com --> www.example.com/bbs/
        - http://www.example.com/ --> https://www.example.com/
        - http://www.example.com/login.php;username=tom --> http://www.example.com/tom/
    - 1, rewrite regex replacement [flag] 将用户请求的URI基于regex所描述的模式进行检查, 匹配到时将其替换为replacement指定的新的URI;
        - 注意: 如果在同一级配置块中存在多个rewrite规则, 那么会自下而下逐个检查; 被某条件规则替换完成后, 会重新一轮的替换检查, 因此, 隐含有循环机制; [flag]所表示的标志位用于控制此循环机制;
        - 如果replacement是以http://或https://开头, 则替换结果会直接以重向返回给客户端; 301: 永久重定向;
        - [flag]:
            - last: 重写完成后停止对当前URI在当前location中后续的其它重写操作, 而后对新的URI启动新一轮重写检查; 提前重启新一轮循环;
            - break: 重写完成后停止对当前URI在当前location中后续的其它重写操作, 而后直接跳转至重写规则配置块之后的其它配置; 结束循环;
            - redirect: 重写完成后以临时重定向方式直接返回重写后生成的新URI给客户端, 由客户端重新发起请求; 不能以http://或https://开头;
            - permanent:重写完成后以永久重定向方式直接返回重写后生成的新URI给客户端, 由客户端重新发起请求;
    - 2, return: Stops processing and returns the specified code to a client.
        - return code [text];
        - return code URL;
        - return URL;
    - 3, rewrite_log on | off; 是否开启重写日志;
    - 4, if (condition) { ... } 引入一个新的配置上下文 ; 条件满足时, 执行配置块中的配置指令; server, location;
        - condition:
            - ==, !=
            - `~`: 模式匹配, 区分字符大小写;
            - `~*`: 模式匹配, 不区分字符大小写;
            - `!~`: 模式不匹配, 区分字符大小写;
            - `!~*`: 模式不匹配, 不区分字符大小写;
        - 文件及目录存在性判断:
            - -e, !-e
            - -f, !-f
            - -d, !-d
            - -x, !-x
    - 5, set $variable value; 用户自定义变量;

- ngx_http_referer_module 模块: used to block access to a site for requests with invalid values in the “Referer” header field.
    - 1, valid_referers none | blocked | server_names | string ...; 定义referer首部的合法可用值;
        - none: 请求报文首部没有referer首部;
        - blocked: 请求报文的referer首部没有值;
        - server_names: 参数, 其可以有值作为主机名或主机名模式;
            - arbitrary_string: 直接字符串, 但可使用`*`作通配符;
            - regular expression: 被指定的正则表达式模式匹配到的字符串; 要使用`~`开头, 例如 `~.*\.example\.com;`

- ngx_http_referer_module 配置示例:

```
valid_referers none block server_names *.example.com *.mageedu.com example.* mageedu.* ~\.example\.;

if($invalid_referer) {
   return http://www.example.com/invalid.jpg;
}
```
