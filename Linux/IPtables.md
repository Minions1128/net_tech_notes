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
* 举个例子，拒绝192.168.1.22访问本地ssh服务：
```
iptables -A INPUT -i eth0 -p tcp -s 192.168.1.22 --dport 22 -j REJECT
iptables -A OUTPUT -o eth0 -p tcp -d 192.168.1.22 --sport 22 -j REJECT
```
2.6 IPtables状态
IPtables为网络连接是时，通信两端的连接状态，有4中类型：
NEW，用户发出一个全新的请求，
ESTABLISHED，已经建立的连接，
RELATED，和其他ESTABLISHED连接有关联的
INVALID，非法连接
2.7 管理
-t, --table table，指定具体表，filter，nat，mangle表等
Chain INPUT (policy ACCEPT)默认规则
-L, --list [chain]，查看IPtables
-S, --list-rules [chain]，查看规则
-F, --flush [chain]，清空配置
-Z, --zero [chain [rulenum]]，清除某些规则
-N, --new-chain chain，新建表链
-X, --delete-chain [chain]，删除表链
-P, --policy [chain] {ACCEPT | DROP}，默认策略
service iptables {restart | start | stop | status | save}
iptables-save > ip_tab.rules，保存策略
iptables-restore < ip_tab. rules，恢复策略

service iptables status查看其状态

