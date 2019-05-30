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
        - <method> <URL> <VERSION>
        - HEADERS: (name: value)
        - <request body>

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
