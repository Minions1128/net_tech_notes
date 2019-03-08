# IPtables

## 2. IPtables规则
IPtables规则包含：一个条件和一个策略操作，从上到下一一查找规则，如果都为匹配到，则执行默认规则。
* 配置规则的一些参数
```
-i, --in-interface name，输入网卡；
-o, --out-interface name，输出网卡；
-p, --protocol protocol，协议，如：TCP、UDP、ICMP等；
-s, --source address[/mask][,...]，源地址，可以是hostname，IP地址段以及单个的IP地址；
-d, --destination address[/mask][,...]，目的地址；
-A，添加一条规则；
-D，删除一条规则；
-I value，将规则插入相应的行；
--sport，源端口；
--dport，目的端口；
-j, --jump target，策略操作，即报文匹配之后做执行的操作；
[!]，表示非运算
```
* 策略操作
```
ACCEPT，DROP（请求端没有任何回应），REJECT，REDIRECT，DNAT，SNAT
```
## 3. IPtables状态
在IPtables上一共有四种状态，分别被称为NEW、ESTABLISHED、INVALID、RELATED，这四种状态对于TCP、UDP、ICMP三种协议均有效。
### 3.1 NEW
匹配的报文是某个连接的第一个报文。如TCP中的SYN包。
### 3.2 ESTABLISHED
已经匹配到两个方向上的数据传输，而且会继续匹配这个连接的包。
### 3.3 RELATED
当一个连接和某个已处于ESTABLISHED状态的连接有关系时，就被认为是RELATED的了。换句话说，一个连接要想是RELATED的，首先要有一个ESTABLISHED的连接。这个ESTABLISHED连接再产生一个主连接之外的连接，这个新的连接就是RELATED的了。如，FTP，FTP-data 连接就是和FTP-control有关联的。
* ICMP应答、FTP传输
### 3.4 INVALID
数据包不能被识别属于哪个连接或没有任何状态。有几个原因可以产生这种情况，比如，内存溢出，收到不知属于哪个连接的ICMP错误信息。一般地，我们DROP这个状态的任何东西。
## 4. 管理
* -t, --table table，指定具体表，filter，nat，mangle表等
* -L, --list [chain]，查看IPtables
* -S, --list-rules [chain]，查看规则
* -F, --flush [chain]，清空配置
* -Z, --zero [chain [rulenum]]，清除某些规则
* -N, --new-chain chain，新建表链
* -X, --delete-chain [chain]，删除表链
* -P, --policy [chain] {ACCEPT | DROP}，默认策略
* service iptables {restart | start | stop | status | save}
* iptables-save > ip_tab.rules，保存策略
* iptables-restore < ip_tab. rules，恢复策略
* service iptables status查看其状态
## 5. 一些例子
```
# 拒绝192.168.1.22访问本地ssh服务：
iptables -A INPUT -i eth0 -p tcp -s 192.168.1.22 --dport 22 -j REJECT
iptables -A OUTPUT -o eth0 -p tcp -d 192.168.1.22 --sport 22 -j REJECT

# 只允许本机ping其他主机，不允许其他主机ping本机
iptables -A INPUT -p icmp --icmp-type 8 -j DROP
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -j DROP

# 多端口应用
iptables -A INPUT -p tcp -m multiport --sport 22,53,80,110

# 速率的限制
iptables -A INPUT -m limit --limit 300/s    # 限制速率为300个包每秒
iptables -I FORWARD 1 -p tcp -i eth0 -o eth1 -s 192.168.2.3 -d 192.168.3.3 \
    --dport 80 -m limit --limit=500/s --limit-burst=1000  -j ACCEPT \
    # 允许转发从eth0进来的源IP为192.168.2.3， \
    # 去访问从eth1出去的目的IP为192.168.3.3的80端口（即http服务）的数据包, \
    # 其中会对包的速率做匹配，是每秒转发500个包，burst值是1000， \
    # --limit-burst 表示允许触发 limit 限制的最大次数 (预设5)，超出后将对其进行限制

# NAT表
iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j SNAT \
    --to-source 123.123.123.123 \
    # 内网源192.168.122.0/24地址映射到公网123.123.123.123出口
iptables -t nat -A PREROUTING -d 123.123.123.123 -p tcp \
    --dport 442 -j DNAT --to-destination 192.168.10.18:22 \
    # 外部要访问内网服务器

# 负载均衡
iptables -t nat -A PREROUTING -d 10.192.0.65/32 -p tcp -m tcp \
    --dport 8080 -m statistic --mode nth --every 2 --packet 0 \
    -j DNAT --to-destination 10.1.160.14:8080
iptables -t nat -A POSTROUTING -d 10.1.160.14/32 -p tcp -m tcp \
    --dport 8080 -j SNAT --to-source 10.192.0.65
iptables -t nat -A PREROUTING -d 10.192.0.65/32 -p tcp -m tcp \
    --dport 8080 -m statistic --mode nth --every 1 --packet 0 \
    -j DNAT --to-destination 10.1.160.15:8080
iptables -t nat -A POSTROUTING -d 10.1.160.15/32 -p tcp -m tcp \
    --dport 8080 -j SNAT --to-source 10.192.0.65
```

## 6. 补充
* [鸟哥私房菜-防火墙与NAT服务器](http://cn.linux.vbird.org/linux_server/0250simple_firewall.php "鸟哥私房菜-防火墙与NAT服务器")
* [iptables的限速测试总结](http://ptallrights.blog.51cto.com/11151122/1841911 "iptables的限速测试总结")
