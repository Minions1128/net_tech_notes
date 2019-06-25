# HAProxy

- LB Cluster:
    - 四层：
        - lvs, nginx(stream)，haproxy(mode tcp)
    - 七层：
        - http: nginx(http, ngx_http_upstream_module), haproxy(mode http), httpd, ats, perlbal, pound...

- HAProxy is a TCP/HTTP reverse proxy which is particularly suited for high availability environments. Indeed, it can:
    - route HTTP requests depending on statically assigned cookies
    - spread load among several servers while assuring server persistence through the use of HTTP cookies
    - switch to backup servers in the event a main server fails
    - accept connections to special ports dedicated to service monitoring
    - stop accepting connections without breaking existing ones
    - add, modify, and delete HTTP headers in both directions
    - block requests matching particular patterns
    - report detailed status to authenticated users from a URI intercepted by the application

- 程序环境：
    - 主程序：/usr/sbin/haproxy
    - 主配置文件：/etc/haproxy/haproxy.cfg
    - Unit file：/usr/lib/systemd/system/haproxy.service

- 配置段：
    - global：全局配置段
        - 进程及安全配置相关的参数
        - 性能调整相关参数
        - Debug参数
    - proxies：代理配置段
        - defaults：为frontend, listen, backend提供默认配置；
        - fronted：前端，相当于nginx, server {}
        - backend：后端，相当于nginx, upstream {}
        - listen：同时拥前端和后端

- 简单的配置示例：
    ```
    frontend web
        bind *:80
        default_backend  websrvs
    backend websrvs
        balance roundrobin
        server srv1 172.16.100.6:80 check
        server srv2 172.16.100.7:80 check
    ```

- global配置参数：
    - 进程及安全管理：chroot, deamon，user, group, uid, gid
        - log：定义全局的syslog服务器；最多可以定义两个；
            - `log <address> [len <length>] <facility> [max level [min level]]`
        - `nbproc <number>`：要启动的haproxy的进程数量；
        - `ulimit-n <number>`：每个haproxy进程可打开的最大文件数；
    - 性能调整：
        - `maxconn <number>`：设定每个haproxy进程所能接受的最大并发连接数；Sets the maximum per-process number of concurrent connections to `<number>`.
        - `maxconnrate <number>`：Sets the maximum per-process number of connections per second to `<number>`. 每个进程每秒种所能创建的最大连接数量；
        - `maxsessrate <number>`：
        - `maxsslconn <number>`: Sets the maximum per-process number of concurrent SSL connections to `<number>`.
        - `spread-checks <0..50, in percent>`

- 代理配置段：
                - defaults <name>
                - frontend <name>
                - backend  <name>
                - listen   <name>
                
                A "frontend" section describes a set of listening sockets accepting client connections.
                A "backend" section describes a set of servers to which the proxy will connect to forward incoming connections.
                A "listen" section defines a complete proxy with its frontend and backend parts combined in one section. It is generally useful for TCP-only traffic.
            
                All proxy names must be formed from upper and lower case letters, digits, '-' (dash), '_' (underscore) , '.' (dot) and ':' (colon). 区分字符大小写；
                
                配置参数：
                    
                bind：Define one or several listening addresses and/or ports in a frontend.
                    bind [<address>]:<port_range> [, ...] [param*]
                    
                    listen http_proxy
                        bind :80,:443
                        bind 10.0.0.1:10080,10.0.0.1:10443
                        bind /var/run/ssl-frontend.sock user root mode 600 accept-proxy
            
                balance：后端服务器组内的服务器调度算法
                    balance <algorithm> [ <arguments> ]
                    balance url_param <param> [check_post]              
        
                    算法：
                        roundrobin：Each server is used in turns, according to their weights.
                            server options： weight #
                            动态算法：支持权重的运行时调整，支持慢启动；每个后端中最多支持4095个server；
                        static-rr：
                            静态算法：不支持权重的运行时调整及慢启动；后端主机数量无上限；
                            
                        leastconn：
                            推荐使用在具有较长会话的场景中，例如MySQL、LDAP等；
                            
                        first：
                            根据服务器在列表中的位置，自上而下进行调度；前面服务器的连接数达到上限，新请求才会分配给下一台服务；
                            
                        source：源地址hash；
                            除权取余法：
                            一致性哈希：
                            
                        uri：
                            对URI的左半部分做hash计算，并由服务器总权重相除以后派发至某挑出的服务器；
                            
                                <scheme>://<user>:<password>@<host>:<port>/<path>;<params>?<query>#<frag>
                                    左半部分：/<path>;<params>
                                    整个uri：/<path>;<params>?<query>#<frag>
                                    
                        url_param：对用户请求的uri听<params>部分中的参数的值作hash计算，并由服务器总权重相除以后派发至某挑出的服务器；通常用于追踪用户，以确保来自同一个用户的请求始终发往同一个Backend Server；
                        
                        hdr(<name>)：对于每个http请求，此处由<name>指定的http首部将会被取出做hash计算； 并由服务器总权重相除以后派发至某挑出的服务器；没有有效值的会被轮询调度； 
                            hdr(Cookie)
                            
                        rdp-cookie
                        rdp-cookie(<name>)  
                        
                    hash-type：哈希算法
                        hash-type <method> <function> <modifier>
                            map-based：除权取余法，哈希数据结构是静态的数组；
                            consistent：一致性哈希，哈希数据结构是一个树；
                            
                        <function> is the hash function to be used : 哈希函数
                            sdbm
                            djb2
                            wt6

                    default_backend <backend>
                        设定默认的backend，用于frontend中；
                        
                    default-server [param*]
                        为backend中的各server设定默认选项；




























回顾：
    tcp/http reverse proxy；
    haproxy.cfg
        global, proxies
        proxies：
            defaults
            frontend
            listen
            backend
                    
                    
        proxies：bind、balance、hash-type、default_backend、server
            balance：
                roundrobin、static-rr、leastconn、first、source、uri、hdr(<HEADER>)、url_param、...































HAProxy(2)
                
                    server <name> <address>[:[port]] [param*]
                        定义后端主机的各服务器及其选项；
                        
                         server <name> <address>[:port] [settings ...]
                        default-server [settings ...]
                        
                        <name>：服务器在haproxy上的内部名称；出现在日志及警告信息；
                        <address>：服务器地址，支持使用主机名；
                        [:[port]]：端口映射；省略时，表示同bind中绑定的端口；
                        [param*]：参数
                            maxconn <maxconn>：当前server的最大并发连接数；
                            backlog <backlog>：当前server的连接数达到上限后的后援队列长度；
                            backup：设定当前server为备用服务器；
                            check：对当前server做健康状态检测；
                                addr ：检测时使用的IP地址；
                                port ：针对此端口进行检测；
                                inter <delay>：连续两次检测之间的时间间隔，默认为2000ms; 
                                rise <count>：连续多少次检测结果为“成功”才标记服务器为可用；默认为2；
                                fall <count>：连续多少次检测结果为“失败”才标记服务器为不可用；默认为3；
                                    
                                    注意：httpchk，"smtpchk", "mysql-check", "pgsql-check" and "ssl-hello-chk" 用于定义应用层检测方法；
                                    
                            cookie <value>：为当前server指定其cookie值，用于实现基于cookie的会话黏性；
                            disabled：标记为不可用；
                            redir <prefix>：将发往此server的所有GET和HEAD类的请求重定向至指定的URL；
                            weight <weight>：权重，默认为1;                            
                            
                    统计接口启用相关的参数：
                        stats enable
                            启用统计页；基于默认的参数启用stats page；
                                - stats uri   : /haproxy?stats
                                - stats realm : "HAProxy Statistics"
                                - stats auth  : no authentication
                                - stats scope : no restriction
                        
                        stats auth <user>:<passwd>
                            认证时的账号和密码，可使用多次；
                            
                        stats realm <realm>
                            认证时的realm；
                            
                        stats uri <prefix>
                            自定义stats page uri
                            
                        stats refresh <delay>
                            设定自动刷新时间间隔；
                            
                        stats admin { if | unless } <cond>
                            启用stats page中的管理功能
                            
                        配置示例：
                            listen stats
                                bind :9099
                                stats enable
                                stats realm HAPorxy\ Stats\ Page
                                stats auth admin:admin
                                stats admin if TRUE     
                            
                            
                    maxconn <conns>：为指定的frontend定义其最大并发连接数；默认为2000；
                        Fix the maximum number of concurrent connections on a frontend.  
                    
                    mode { tcp|http|health }
                        定义haproxy的工作模式；
                            tcp：基于layer4实现代理；可代理mysql, pgsql, ssh, ssl等协议；
                            http：仅当代理的协议为http时使用；
                            health：工作为健康状态检查的响应模式，当连接请求到达时回应“OK”后即断开连接；
                        
                        示例：
                            listen ssh
                                bind :22022
                                balance leastconn
                                mode tcp
                                server sshsrv1 172.16.100.6:22 check
                                server sshsrv2 172.16.100.7:22 check        
                            
                    cookie <name> [ rewrite | insert | prefix ] [ indirect ] [ nocache ]  [ postonly ] [ preserve ] [ httponly ] [ secure ]  [ domain <domain> ]* [ maxidle <idle> ] [ maxlife <life> ]
                        <name>：is the name of the cookie which will be monitored, modified or inserted in order to bring persistence.
                            rewirte：重写；
                            insert：插入；
                            prefix：前缀；
                            
                        基于cookie的session sticky的实现：
                            backend websrvs
                                cookie WEBSRV insert nocache indirect
                                server srv1 172.16.100.6:80 weight 2 check rise 1 fall 2 maxconn 3000 cookie srv1
                                server srv2 172.16.100.7:80 weight 1 check rise 1 fall 2 maxconn 3000 cookie srv2               
                            
    
                        
                    option forwardfor [ except <network> ] [ header <name> ] [ if-none ]
                        Enable insertion of the X-Forwarded-For header to requests sent to servers
                        
                        在由haproxy发往后端主机的请求报文中添加“X-Forwarded-For”首部，其值前端客户端的地址；用于向后端主发送真实的客户端IP；
                            [ except <network> ]：请求报请来自此处指定的网络时不予添加此首部；
                            [ header <name> ]：使用自定义的首部名称，而非“X-Forwarded-For”；
                            
                    errorfile <code> <file>
                        Return a file contents instead of errors generated by HAProxy
                        
                        <code>：is the HTTP status code. Currently, HAProxy is capable of  generating codes 200, 400, 403, 408, 500, 502, 503, and 504.
                        <file>：designates a file containing the full HTTP response.
                        
                        示例：
                            errorfile 400 /etc/haproxy/errorfiles/400badreq.http
                            errorfile 408 /dev/null  # workaround Chrome pre-connect bug
                            errorfile 403 /etc/haproxy/errorfiles/403forbid.http
                            errorfile 503 /etc/haproxy/errorfiles/503sorry.http 
                            
                    errorloc <code> <url>
                    errorloc302 <code> <url>
                    
                        errorfile 403 http://www.magedu.com/error_pages/403.html
                        
                    reqadd  <string> [{if | unless} <cond>]
                        Add a header at the end of the HTTP request
                        
                    rspadd <string> [{if | unless} <cond>]
                        Add a header at the end of the HTTP response
                        
                        rspadd X-Via:\ HAPorxy
                        
                    reqdel  <search> [{if | unless} <cond>]
                    reqidel <search> [{if | unless} <cond>]  (ignore case)
                        Delete all headers matching a regular expression in an HTTP request
                        
                    rspdel  <search> [{if | unless} <cond>]
                    rspidel <search> [{if | unless} <cond>]  (ignore case)
                        Delete all headers matching a regular expression in an HTTP response
                        
                        rspidel  Server.*
                                                    
                            
                            
                日志系统：           
                    log：
                        log global
                        log <address> [len <length>] <facility> [<level> [<minlevel>]]
                        no log
                        
                        注意：
                            默认发往本机的日志服务器；
                                (1) local2.*      /var/log/local2.log 
                                (2) $ModLoad imudp
                                    $UDPServerRun 514
                                    
                    log-format <string>：
                        课外实践：参考文档实现combined格式的记录
                        
                    capture cookie <name> len <length>
                        Capture and log a cookie in the request and in the response.
                        
                    capture request header <name> len <length>
                        Capture and log the last occurrence of the specified request header.
                        
                        capture request header X-Forwarded-For len 15
                        
                    capture response header <name> len <length>
                        Capture and log the last occurrence of the specified response header.
                        
                        capture response header Content-length len 9
                        capture response header Location len 15         
                
                为指定的MIME类型启用压缩传输功能
                    compression algo <algorithm> ...：启用http协议的压缩机制，指明压缩算法gzip, deflate；
                    compression type <mime type> ...：指明压缩的MIMI类型；

                    
                对后端服务器做http协议的健康状态检测：
                    option httpchk
                    option httpchk <uri>
                    option httpchk <method> <uri>
                    option httpchk <method> <uri> <version>     
                        定义基于http协议的7层健康状态检测机制；
                        
                    http-check expect [!] <match> <pattern>
                        Make HTTP health checks consider response contents or specific status codes.
                        

                连接超时时长：     
                    timeout client <timeout>
                        Set the maximum inactivity time on the client side. 默认单位是毫秒; 
                        
                    timeout server <timeout>
                        Set the maximum inactivity time on the server side.
                        
                    timeout http-keep-alive <timeout>
                        持久连接的持久时长；
                        
                    timeout http-request <timeout>
                        Set the maximum allowed time to wait for a complete HTTP request
                        
                    timeout connect <timeout>
                        Set the maximum time to wait for a connection attempt to a server to succeed.
                        
                    timeout client-fin <timeout>
                        Set the inactivity timeout on the client side for half-closed connections.
                        
                    timeout server-fin <timeout>
                        Set the inactivity timeout on the server side for half-closed connections.
                    
                    
                    
                    use_backend <backend> [{if | unless} <condition>]
                        Switch to a specific backend if/unless an ACL-based condition is matched.
                        当符合指定的条件时使用特定的backend；
                        
                    block { if | unless } <condition>
                        Block a layer 7 request if/unless a condition is matched
                        
                        acl invalid_src src 172.16.200.2
                        block if invalid_src
                        errorfile 403 /etc/fstab    
                        
                    http-request { allow | deny } [ { if | unless } <condition> ]
                        Access control for Layer 7 requests
                        
                    tcp-request connection {accept|reject}  [{if | unless} <condition>]
                        Perform an action on an incoming connection depending on a layer 4 condition
                        
                        示例：
                            listen ssh
                                bind :22022
                                balance leastconn
                                acl invalid_src src 172.16.200.2
                                tcp-request connection reject if invalid_src
                                mode tcp
                                server sshsrv1 172.16.100.6:22 check
                                server sshsrv2 172.16.100.7:22 check backup         
                
    acl：
        The use of Access Control Lists (ACL) provides a flexible solution to perform content switching and generally to take decisions based on content extracted from the request, the response or any environmental status.
        
        acl <aclname> <criterion> [flags] [operator] [<value>] ...
            <aclname>：ACL names must be formed from upper and lower case letters, digits, '-' (dash), '_' (underscore) , '.' (dot) and ':' (colon).ACL names are case-sensitive.
            
            <value>的类型：
                - boolean
                - integer or integer range
                - IP address / network
                - string (exact, substring, suffix, prefix, subdir, domain)
                - regular expression
                - hex block
                
            <flags>
                -i : ignore case during matching of all subsequent patterns.
                -m : use a specific pattern matching method
                -n : forbid the DNS resolutions
                -u : force the unique id of the ACL
                -- : force end of flags. Useful when a string looks like one of the flags.  
                
             [operator] 
                匹配整数值：eq、ge、gt、le、lt
                
                匹配字符串：
                    - exact match     (-m str) : the extracted string must exactly match the patterns ;
                    - substring match (-m sub) : the patterns are looked up inside the extracted string, and the ACL matches if any of them is found inside ;
                    - prefix match    (-m beg) : the patterns are compared with the beginning of the extracted string, and the ACL matches if any of them matches.
                    - suffix match    (-m end) : the patterns are compared with the end of the extracted string, and the ACL matches if any of them matches.
                    - subdir match    (-m dir) : the patterns are looked up inside the extracted string, delimited with slashes ("/"), and the ACL matches if any of them matches.
                    - domain match    (-m dom) : the patterns are looked up inside the extracted string, delimited with dots ("."), and the ACL matches if any of them matches. 

                    
            acl作为条件时的逻辑关系：
                - AND (implicit)
                - OR  (explicit with the "or" keyword or the "||" operator)
                - Negation with the exclamation mark ("!")
                
                    if invalid_src invalid_port
                    if invalid_src || invalid_port
                    if ! invalid_src invalid_port
                    
            <criterion> ：
                dst : ip
                dst_port : integer
                src : ip
                src_port : integer
                
                    acl invalid_src  src  172.16.200.2
                    
                path : string
                    This extracts the request's URL path, which starts at the first slash and ends before the question mark (without the host part).
                        /path;<params>
                        
                    path     : exact string match
                    path_beg : prefix match
                    path_dir : subdir match
                    path_dom : domain match
                    path_end : suffix match
                    path_len : length match
                    path_reg : regex match
                    path_sub : substring match  
                    
                url : string
                    This extracts the request's URL as presented in the request. A typical use is with prefetch-capable caches, and with portals which need to aggregate multiple information from databases and keep them in caches.
                    
                    url     : exact string match
                    url_beg : prefix match
                    url_dir : subdir match
                    url_dom : domain match
                    url_end : suffix match
                    url_len : length match
                    url_reg : regex match
                    url_sub : substring match
                    
                req.hdr([<name>[,<occ>]]) : string
                    This extracts the last occurrence of header <name> in an HTTP request.
                    
                    hdr([<name>[,<occ>]])     : exact string match
                    hdr_beg([<name>[,<occ>]]) : prefix match
                    hdr_dir([<name>[,<occ>]]) : subdir match
                    hdr_dom([<name>[,<occ>]]) : domain match
                    hdr_end([<name>[,<occ>]]) : suffix match
                    hdr_len([<name>[,<occ>]]) : length match
                    hdr_reg([<name>[,<occ>]]) : regex match
                    hdr_sub([<name>[,<occ>]]) : substring match                 
                    
                    示例：
                        acl bad_curl hdr_sub(User-Agent) -i curl
                        block if bad_curl                   
                
                status : integer
                    Returns an integer containing the HTTP status code in the HTTP response.
                    
            Pre-defined ACLs
                ACL name    Equivalent to   Usage
                FALSE   always_false    never match
                HTTP    req_proto_http  match if protocol is valid HTTP
                HTTP_1.0    req_ver 1.0 match HTTP version 1.0
                HTTP_1.1    req_ver 1.1 match HTTP version 1.1
                HTTP_CONTENT    hdr_val(content-length) gt 0    match an existing content-length
                HTTP_URL_ABS    url_reg ^[^/:]*://  match absolute URL with scheme
                HTTP_URL_SLASH  url_beg /   match URL beginning with "/"
                HTTP_URL_STAR   url *   match URL equal to "*"
                LOCALHOST   src 127.0.0.1/8 match connection from local host
                METH_CONNECT    method CONNECT  match HTTP CONNECT method
                METH_GET    method GET HEAD match HTTP GET or HEAD method
                METH_HEAD   method HEAD match HTTP HEAD method
                METH_OPTIONS    method OPTIONS  match HTTP OPTIONS method
                METH_POST   method POST match HTTP POST method
                METH_TRACE  method TRACE    match HTTP TRACE method
                RDP_COOKIE  req_rdp_cookie_cnt gt 0 match presence of an RDP cookie
                REQ_CONTENT req_len gt 0    match data in the request buffer
                TRUE    always_true always match
                WAIT_END    wait_end    wait for end of content analysis                

                
                
                
    HAProxy：global, proxies（fronted, backend, listen, defaults）
        balance：
            roundrobin, static-rr
            leastconn
            first
            source
            hdr(<name>)
            uri (hash-type)
            url_param
            
        Nginx调度算法：ip_hash, hash, leastconn, 
        lvs调度算法：
            rr/wrr/sh/dh, lc/wlc/sed/nq/lblc/lblcr
                

        基于ACL的动静分离示例：
            frontend  web *:80
                acl url_static       path_beg       -i  /static /images /javascript /stylesheets
                acl url_static       path_end       -i  .jpg .gif .png .css .js .html .txt .htm

                use_backend staticsrvs          if url_static
                default_backend             appsrvs

            backend staticsrvs
                balance     roundrobin
                server      stcsrv1 172.16.100.6:80 check

            backend appsrvs
                balance     roundrobin
                server  app1 172.16.100.7:80 check
                server  app1 172.16.100.7:8080 check

            listen stats
                bind :9091
                stats enable
                stats auth admin:admin
                stats admin if TRUE     
        
    配置HAProxy支持https协议： 
        1 支持ssl会话；
            bind *:443 ssl crt /PATH/TO/SOME_PEM_FILE
            
            crt后的证书文件要求PEM格式，且同时包含证书和与之匹配的所有私钥；
            
                cat  demo.crt demo.key > demo.pem 
                
        2 把80端口的请求重向定443；
            bind *:80
            redirect scheme https if !{ ssl_fc }
            
        3 如何向后端传递用户请求的协议和端口
            http_request set-header X-Forwarded-Port %[dst_port]
            http_request add-header X-Forwared-Proto https if { ssl_fc }
            
        
        
        
        实践（博客）作业：
            http:
                (1) 动静分离部署wordpress，动静都要能实现负载均衡，要注意会话的问题；
                (2) 在haproxy和后端主机之间添加varnish进行缓存；
                (3) 给出设计拓扑，写成博客；
                
                (4) haproxy的设定要求：
                    (a) stats page，要求仅能通过本地访问使用管理接口； 
                    (b) 动静分离；
                    (c) 分别考虑不同的服务器组的调度算法；
                (5) haproxy高可用；
                 
