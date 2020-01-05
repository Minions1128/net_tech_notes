# MPLS

- Multi-Protocol Label Switching, 多协议标签交换。其应用最广的为MPLS VPN以及MPLS TE。

## 1. 概述

### 1.1 IOS平台交换机制

- 思科IOS交换分为：进程交换、快速交换和CEF(Cisco Express Forwarding, 思科快速转发)
    - 1. 进程交换：路由器对每个报文进行route表和arp表的查询。缺点消耗CPU资源以及增加延迟, 优点支持各种负载均衡。
    - 2. 快速交换：路由器会对报文进行分类, 将去往相同目的地的报文分到一类。对每一类的第一个报文进行route表和arp表的查询, 将结果存到cache中。后续报文会查看cache进行转发。缺点：第一个报文还是需要进程查表, 无法实现基于报文的负载均衡。优点：比进程交换速度快。
    - 3. CEF：开启cef之后, 路由器会生成两张表被ASIC调用
        - 邻接表: 优化后的二层表(ARP表)。
        - FIB(Forwarding Information Base, 转发信息库): 优化后的路由表, 标签是基于FIB分发的。

### 1.2 名词解释

- FEC, Forwarding Equivalent Class, 转发等价类, 具有相同属性的一类(报文), 这种相同的属性可以是：L3 VPN地址, 相同的目的地址。可以理解为一条路由条目, 对应一个标签。
- LDP, Label Distribution Protocol, 标签分发协议, 基于TCP/UDP 646端口, 与TDP相比, 该协议支持认证。该协议用于标签的分发。
- LIB, Label Information Base, 标签信息库, 是一种拓扑表, 存放路由条目与标签的映射关系。
- LFIB, Label Forwarding Information Base, 标签转发信息库, 发送带标签的报文时查询入标签与出标签映射的表。
- LSR, Label Switch Router, 也称为P路由器。
- LSP, Label Switch Path, 标签交换路径, 使用MPLS建立起来的, 由LSR分组转发路径。

## 2. MPLS

- 转发标签的协议有：LDP/TDP, BGP(MPLS VPN), RSVP(MPLS TE)

### 2.1 标签

![mpls label](/img/mpls_label.jpg "mpls label")

- Label：20 bit, 取值范围是16 ~ 1048575(2^20-1)
- EXP：3 bit, 实验位, 作QoS
- S：1 bit, 栈底标签标志位
- TTL：8 bit, 防止出现环路

![mpls multi label](/img/mpls_multi_label.jpg "mpls multi label")

该报文在二层到三层报文之间。以太网的类型值为0x8847(单播), 0x8848(组播和广播)

### 2.2 分发标签的过程

1. 通过路由协议建立IP路由表；
2. 为路由表中的每个条目分发标签, 除了BGP路由条目；
3. 传递给其他LSR, 标签只具有本地意义；
4. 建立LIB, LFIB以及FIB供数据传递；
5. 由于MPLS分发标签给目的地的上游和上游的LSR。所以LDP建立传递邻居信息时, 会将路由器所有物理接口的IP地址告诉邻居路由器, 将这些信息存入到邻居表中；
6. 当收到邻居的标签时, 会结合自己的FIB, 并且将适合的标签加入到LFIB中。

### 2.3 数据转发

![mpls lsr](/img/mpls_lsr_forwarding.jpg "mpls lsr")

![mpls edge lsr](/img/mpls_e_lsr_forwarding.jpg "mpls edge lsr")
### 2.4 PHP
- PHP(Penultimate Hop Popping, 倒数第二跳弹出), 一个目的网段的最后一跳路由器对目的网段不会发送常规标签, 而会发送3号标签, 意为弹出标签。倒数第二条路由器收到该标签后, 并将其加入LFIB。当收到去往目的网段的数据包时, 会执行弹出标签的操作, 以常规报文发送给最后一跳路由器, 最后一跳路由器只需查询FIB表就可以将报文进行转发。
- 最后一条路由器的定义：对去往目的网段接口没有启用MPLS, 或者去往该接口的下一跳没有LDP邻居的路由器。
### 2.5 配置
0. 启用IGP
1. 启用cef, `ip cef`
2. 开启mpls, 接口上使用`mpls ip`
3. 修改router-id(可选), 全局模式下`mpls ldp router-id loopback 0 force`
4. 修改接口MTU：`mpls mtu 1504`(VPN修改为1508, TE修改为1512)
5. 相关show命令：
```
查看邻居show mpls ldp neighbor
查看fib：show ip cef [details]
查看lib：sh mpls ldp bindings
查看lfib：sh mpls forwarding-table
```
6. 高级命令：
```
修改Label范围：mpls label range 101 150
不通告标签：no mpls ldp advertise-labels
通告标签给某些ACL
mpls ldp advertise-labels for 10 to 20
acl 10为路由条目
acl 20为通告给邻居的接口范围
```
