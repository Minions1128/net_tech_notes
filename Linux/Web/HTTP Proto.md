# HTTP

## TCP协议概述

- IANA 端口
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

## HTTP工作模式

- http请求报文: http request

```html
<method> <request-URL> <version>
<headers>
<entity-body>
```

- http响应报文: http response

```html
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
