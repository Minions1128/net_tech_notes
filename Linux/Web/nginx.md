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

- 配置:
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
