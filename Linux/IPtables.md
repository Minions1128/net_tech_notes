# IPtables
IPtables为Linux防火墙，作用域为主机，其用途有：过滤报文、NAT、数据包分割。
## 1. 架构
IPtables由一些表组成，每个表由表链组成，表链包含了多个规则。默认有四个内建表：Filter、NAT、Mangle，Raw。
### 1.1 Filter表
该表有包过滤的作用，由INPUT（inbound流量），OUTPUT（outbound流量），FORWARD（转发流量）表链组成。
### 1.2 NAT表
该表有NAT的作用，包括PREROUTING（刚到达本机，在路由转发前的数据包，处理DNAT）、POSTROUTING（即将离开本机的数据包，处理SNAT）、OUTPUT（处理本机产生的数据包）。
### 1.3 Mangle表
该表可以基于数据包的分割与修改，如：ToS、CoS等QoS、TTL。包含：PREROUTING、INPUT、FORWARD、OUTPUT、POSTROUTING五个表链。
### 1.4 Raw表
该表有较高优先级，其作用是为了不再让iptables做数据包的链接跟踪处理，提高性能。包含PREROUTING链和OUTPUT链上
### 1.5 表执行过程
[![](https://github.com/Minions1128/net_tech_notes/blob/master/img/iptables.proc.png)](https://github.com/Minions1128/net_tech_notes/blob/master/img/iptables.proc.png)
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


```

## 6. 补充
* [iptables配置实践](https://wsgzao.github.io/post/iptables/ "iptables配置实践")
* [鸟哥私房菜-防火墙与 NAT 服务器](http://cn.linux.vbird.org/linux_server/0250simple_firewall.php "鸟哥私房菜-防火墙与 NAT 服务器")