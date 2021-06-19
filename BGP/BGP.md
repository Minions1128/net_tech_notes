# BGP

## 1. 概述

* 边界网关协议，一种可以称之为路径矢量协议的，在AS之间传递路由信息路由协议，传递消息为路由条目本身。
* 应用层协议，TCP 179端口，更新报文均为单播报文。
* 管理距离：IBGP为200；EBGP为20
* AS（Autonomous System，自治系统），唯一的标记一个园区网，其范围为0-65535。其中0-64511为公有AS号，64512-65535为私有号。
* 防环机制：IBGP，收到IBGP对等体的路由不会再传给其他IBGP对等体；EBGP，通过AS path属性，不会将路由传给已包含的AS内的路由器。
* 同步概念：如果路由器通过IBGP学到一条路由，该路由器必须再通过IGP学到该路由才可以加表。

## 2. 报文类型

- 详细BGP报文格式：http://www.023wg.com/message/message/cd_feature_bgp_message.html
    - Open报文：用于交互邻居路由器信息，建立邻接关系；
    - Keepalive报文：用于维护邻接关系，每60s发送一次；
    - Update报文：用于交互路由、掩码等属性信息，也有用路由的撤销；
    - Notification报文：用于发送BGP错误信息。
    - Refresh报文：用于动态的请求BGP路由发布者重新发布UPDATE报文，进行路由更新。

## 3. 邻居状态

BGP要发送路由条目，需要先和其他路由器建立邻接关系，BGP有6种邻接关系：

* Idle：路由器通过路由表查找邻居的过程；
* Connect：路由器找到邻居，并且完成了TCP三次握手；
* Open Sent：路由器将本地BGP进程参数以Open报文发送给对端；
```
    参数包括：BGP版本、AS号、Holdtime（默认180s）和RID。
    RID可以手动配置，也可以自动选举，其规则和OSPF一致：
    （1）选择BGP路由器中，在线环回口最大的IP地址作为RID；
    （2）选择物理口最大的IP地址作为RID。
```
* Open Confirm：路由器收到了对端的Open报文，并且参数正确；
* Active：如果路由器没有收到对端发送的Open报文，或者受到的报文参数错误，会进入该状态，此时会重新TCP三次握手；
* Established：邻居建立，开始传递路由
## 4. 属性
BGP在进行路由条目的传递时，路由条目的的属性也一并会传递给邻居，这些属性可以判断路由条目的好坏。属性大致分为以下几类：
* 公认强制属性：origin，AS-path，下一跳
* 公认自选属性：local preference，atomic aggregate
* 可选传递属性：aggregator，community
* 可选非传递属性：MED，originator ID，cluster list
* 其他属性
### 4.1 Weight
* 权重属性，思科私有属性，不可传递
* 取值范围：0 - 65535，越大越优。
* 默认值：若其下一跳为0.0.0.0，则其缺省值为32768（包括本地network进入的非IGP路由以及重分发进入的路由）；若其下一跳不为0.0.0.0（包括本地network进入的IGP路由，以及邻居传递来的路由），则缺省值为0。
* 指定邻居修改：
```
neighbor 3.3.3.3 weight 1
```
* 精确修改，调用route-map
```
ip prefix-list wei_plist seq 5 permit 11.11.11.0/24
route-map wei_map permit 10
 match ip address prefix-list wei_plist
 set weight 1
route-map wei_map permit 20
router bgp 234
 nei 3.3.3.3 route-map wei_map in
```
### 4.2 Local Preference
* 本地优先级属性，公认自选属性，传递范围为一个AS
* 通过该属性，区分AS内的同一条路由哪条最优。
* 默认值：100，越大越优。
* 全局修改：
```
bgp default local-preference 101
```
* 精确修改：
```
ip prefix-list 10 seq 10 permit 111.111.111.0/24
route-map local permit 10
 match ip address prefix-list 10
 set local-preference 101
route-map local permit 20
router bgp 234
 neighbor 12.1.1.1 route-map local in
```
### 4.3 AS-Path
* 公认强制属性，传递范围是整个Internet，越短越优。
* 用一串AS号描述目标路由经过哪些AS。
* 修改方式：
```
access-list 10 permit 11.11.11.0
route-map ap1 permit 10
 match ip address 10
 set as-path prepend 5 6 7 8        #可以添加相同的as
route-map ap1 permit 20
router bgp 234
 neighbor 12.1.1.1 route-map ap1 in
```
* `show ip bgp`中，AS-Path显式的为数据层面的，分析控制层面的as path和数据层面相反。
```
neighbor 4.4.4.4 allowas-in         #允许向已有的AS-Path传递路由
bgp maxas-limit 10                  #允许最大传输的AS-Path数为10
bgp bestpath as-path ignore         #忽略AS-path属性
```
### 4.4 Origin
* 起源属性，公认强制属性，传递范围是整个Internet。
* 描述路由以何种方式进入BGP中的，i为IGP宣告进入BGP的，？为重分发进入BGP的，e为通过EGP进入BGP的，该EGP为BGP的前身，可以通过route-map进行修改。
* i优于e优于？。
* 配置举例：
```
ip prefix-list 10 per 11.11.11.0/24
route-map o per 10
 match ip add prefix-list 10
 set origin incomplete
route-map o per 20
router bgp 234
 neighbor 4.4.4.4 route-map o out
```
### 4.5 MED
* Multi-Exit Discriminators，多出口鉴别器，在邻居的一跳AS传递
* 缺省值：IETF最大值，Cisco定义为0，越小越优。
* MED会影响入站流量，用于同一路由器告诉邻居AS，如何从邻居AS到达本地AS的路由最近。
举例：
```
ip prefix-list 10 seq 5 permit 11.11.11.0/24 #将本地路由通告给邻居AS
route-map m permit 10
 match ip address prefix-list 10
 set metric 100
route-map m permit 20
router bgp 1
 neighbor 13.1.1.3 route-map m out
```
* 将思科路由器缺省值改为最大值：`bgp bestpath med missing-as-worst`
* 允许不同路由器发送来的同一条路由条目来比较其MED值：`bgp always-compare-med`
### 4.6 下一跳
* 若将本地路由（直连路由和静态路由）通告进BGP进程，该路由器的本地BGP表关于它们的下一跳为0.0.0.0；
* 若将IGP获悉的路由通告进BGP进程，该路由器本地BGP表关于它们的下一跳为IGP路由的下一跳地址；
* 若路由器通过BGP对等体收到一条路由，则该路由的下一跳为邻居的更新源地址；
* 若路由器通过EBGP对等体学到一条路由，该路由器在传给其IBGP对等体时，默认情况下一跳不会改变（除非做next-hop-self，或者其IBGP对等体有本地关于EBGP的更新源地址路由）；
* 若路由器通过BGP对等体学到一条路由，该路由器在传递给EBGP对等体时，下一跳会改变为本地对于EBGP对等体的更新源地址。
### 4.7 Atomic aggregate和aggregator
#### 4.7.1 路由聚合
两种方式聚合路由
* 手动写一条精确聚合路由，指向null0，然后将其宣告进入BGP；
* 使用network命令先宣告至少一条精确路由，然后使用`aggregate-address 192.168.4.0 255.255.252.0`宣告聚合路由。此时BGP会将聚合路由和明细路由同时传递，使用明林`aggregate-address 192.168.4.0 255.255.252.0 summary-only`可以抑制明细路由，也可以使用`suppress-map`来精确抑制。
#### 4.7.2 Atomic aggregate
* 原子聚合属性，传递范围是整个Internet。
* 在传递聚合路由时，使用`summary-only`参数会导致AS-PATH属性丢失的情况，所以在传递聚合路由时，可以加入atomic aggregate属性来标识该路由为聚合路由。
* 配置方法：
```
aggregate-address 192.168.4.0 255.255.252.0 as-set summary-only      # 显式原来所在的AS Path
```
#### 4.7.3 Aggregator
* 聚合路由器属性，聚合路由会将该属性一起传递给邻居，标识路由被聚合的路由器ID，传递范围是整个Internet。
### 4.8 Community
* 团体属性为公认自由属性，不可传递属性，只能传递一跳。
#### 4.8.1 标准团体属性
* No-Advertise：收到携带该属性的BGP路由时，路由无法传递给其他BGP对等体；
* No-Export：收到携带该属性的BGP路由时，路由无法传递给其他EBGP对等体，只能在一个AS内传递。但若在联邦中，该属性可以在子AS之间进行传递；
* Local-AS：收到携带该属性的BGP路由时，路由只能在本地AS内传递，包括在联邦的子AS内传递。
#### 4.8.2 扩展团体属性
* XX：YY tag，可以使用该tag来过滤路由。
配置命令：
```
ip community-list standard DENY permit 50:50
route-map COM deny 10
  match community DENY
route-map COM per 20
router bgp 65001
  nei 1.1.1.1 route-map COM in
```
### 4.9 Originator ID和cluster list
* 可选属性，传递范围是一个RR域。在RR传递RRC的路由给其他RRC时，会带有这两种属性。
* Originator ID表示通告者RRC，cluster list由RR组成，表示路由经过了几个RR。
## 5. 路由选路原则
若BGP通过多个渠道获得一条路由条目，按照以下原则判断路由条目的好坏：
* 较高的权重；
* 较高的本地优先级；
* 本地通告的路由优于邻居传递来的路由（可能产生路由环路）；
* 较短的AS-Path；
* 起源属性：i>e>?；
* 较小的MED值；
* EBGP路由优于联邦EBGP路由，优于IBGP路由；
* 下一跳较近的路由，即，IGP度量值较小的路由；
* 若均来自一个AS的路由，并且启用了BGP多路功能（命令为maximum-path），在路由表中安装等价路由；
* 较老的EBGP路由（一般不作为参考对象）；
* 若未开启BGP多路功能，选择邻居RID较小的路由；
* 较短的Cluster List；
* 邻居IP地址较低的路由。
## 6. Route Reflector
* 路由反射器，简称RR；
* Cluster，在同一个AS之内，RR所能涉及到的范围；
* RRC，路由反射器客户端。
* RR和RRC之间有IBGP邻接关系，而RRC之间没有邻接关系。
### 6.1 工作机制
* RR收到一条EBGP路由，会将其传递给其它EBGP对等体、IGBP对等体（包括RRC和non-RRC）；
* RR收到一条RRC传递的IBGP路由，会将其发送给其他EBGP对等体、IGBP对等体（包括RRC和non-RRC）；
* RR收到一条non-RRC传递的IBGP路由，会将其传递给其他EBGP对等体和RRC，不会传递给non-RRC。
* 被RR反射的路由，不会修改任何BGP属性。
### 6.2 配置
在RR上BGP进程中配置：`neighbor 23.1.1.3 route-reflector-client`，宣告23.1.1.3为本地的RRC
## 7. Confederation
### 7.1 定义
* 考虑到在AS内部的防环机制，iBGP之间传递路由只能有一跳。
* 联邦，在一个AS之内，划分出多个子AS域，建立EBGP邻接关系，可以将路由母AS之内进行多跳的传递。
### 7.2 举个例子：
* 拓扑`R1-R2-R3-R4`
* R1在AS1，R2、R3、R4在AS2，R2,、R3在65002子AS，R4在65004子AS。
```
R1:
router bgp 1
 network 1.1.1.1 mask 255.255.255.255
 neighbor 12.1.1.2 remote-as 2
R2:
router bgp 65002                            # 宣告子AS号
 bgp router-id 2.2.2.2
 bgp confederation identifier 2             # 宣告主AS号
 neighbor 12.1.1.1 remote-as 1
 neighbor 23.1.1.3 remote-as 65002          # 使用子AS号指定邻居
R3:
router bgp 65002
 bgp router-id 3.3.3.3
 bgp confederation identifier 2
 bgp confederation peers 65004 
 neighbor 23.1.1.2 remote-as 65002
 neighbor 34.1.1.4 remote-as 65004
R4:
router bgp 65004
 bgp router-id 4.4.4.4
 bgp confederation identifier 2
 bgp confederation peers 65002 
 neighbor 34.1.1.3 remote-as 65002
```
可以将路由反射器和联邦联合使用，解决复杂问题。
## 8. show ip bgp命令
![](https://github.com/Minions1128/net_tech_notes/blob/master/img/show_bgp_cmd.jpg)
BGP表中，从左到右
* *为合法路由，有资格加入路由表；
* r为RIB-failure路由，也有资格加表，但由于管理距离，无法加表；
* s为抑制路由；
* `>`为最优路由，实际加入路由表中的路由；
* i为路由通过ibgp学到的；后面的i标识起源属性，意为通过igp进入BGP的。
## 9. 一些命令
BGP进程下：
* neighbor IP-ADD shutdown，用来将BGP邻居down
* neighbor IP-ADD update-source INTERFACE，修改更新源地址
* neighbor IP-ADD ebgp-multihop TTL-VALUE，修改EBGP建立邻居的TTL值，默认为1.
* neighbor IP-ADD next-hop-self，BGP对于IBGP邻居传递路由时，其下一条地址不变，配置该命令会将下一条指向自己。
* neighbor IP-ADD password PASSWORD
* neighbor IP-ADD soft-reconfiguration inbound允许sh ip bgp neighbors IP-ADD received-routes
* clear ip bgp * soft in/out软清除BGP邻接关系，重新发一次路由更新
* clear ip bgp *硬重置BGP邻接关系，使BGP重新进行三次握手
* show ip bgp summary查看邻居状态等信息
