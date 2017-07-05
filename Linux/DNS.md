# DNS
## 概述
* FQDN：(Fully Qualified Domain Name)完全合格域名/全称域名，是指主机名加上全路径，全路径中列出了序列中所有域成员。如：主机名为jesse，在域example.com中，则其FQDN为jesse.example.com。全域名可以从逻辑上准确地表示出主机在什么地方，也可以说全域名是主机名的一种完全表示形式。从全域名中包含的信息可以看出主机在域名树中的位置。其解析过程同DNS解析流程。
* DNS解析过程
1. 本机HOSTS解析；
2. DNS缓存；
3. DNS 服务器由他来解析。
* 递归查询和迭代查询
1. 递归查询：如果主机所询问的本地域名服务器不知道被查询域名的 IP 地址，那么本地域名服务器就以 DNS 客户的身份，向其他根域名服务器继续发出查询请求报文。
2. 迭代查询：当根域名服务器收到本地域名服务器的迭代查询请求报文时，要么给出所要查询的 IP 地址，要么告诉本地域名服务器：“你下一步应当向哪一个域名服务器进行查询”。然后让本地域名服务器进行后续的查询。
## Linux DNS配置
```
# 解析IPv4地址
vim /etc/default/bind9
OPTIONS="-u bind -4"

# 配置文件
vim /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";    # DNS解析文件位置 
    listen-on port 53 {
        0.0.0.0/0;
        any;
    };    # 监听端口以及IP
    allow-query {
        0.0.0.0/0;
        any;
    };    # 允许谁访问
    forward only | first;   # 指定转发方式：递归 | 迭代
    recursion yes | no;     # yes递归，no迭代
    forwarders {
        223.5.5.5;
        180.76.76.76;
    };    # 上游服务器
}

# 创建域名
vim named.conf.local 
zone "jesse.com"  {
    type master;
    file "/etc/bind/db.jesse.com";
};

# 解析地址
cp db.local db.jesse.com
vim db.jesse.com
$TTL    604800 
; 记录在缓存中的生存时间
;@       IN      SOA     localhost. root.localhost. (
@       IN      SOA     jesse.com. root.jesse.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
; SOA记录
@       IN      NS      localhost.  ;DNS服务器
@       IN      A       127.0.0.1   ;地址
@       IN      AAAA    ::1
pc      IN      A       10.207.28.85
; 即pc.jesse.com对应的地址为10.207.28.85
iphone  IN      A       10.207.88.88
www     IN      CNAME   pc.jesse.com
; 别名记录
```