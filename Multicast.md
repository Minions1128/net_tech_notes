# 组播（Multicast）
## 1. 概述
该协议数据层面是基于UDP协议。
### 1.1 组播概念模型
组播服务体系结构中，有3个部分：源端、组播分发树以及接收端。

![multicast_model](https://github.com/Minions1128/net_tech_notes/blob/master/img/multicast_model.jpg "multicast_model")
* 源端，发送组播流量的组播应用软件服务；
* 组播分发树，路由器使用动态路由协议转发组播报文，例如PIM, DVMRP, MOSPF为IGP组播协议；MBGP、MSDP为EGP组播协议；
* 接收端，最后一条路由器与终端之间，使用IGMP协议来交互是否接受组播流量。
### 1.2 组播地址
#### 1.2.1 组播IP地址
组播地址是保留的D类地址，即224.0.0.0 – 239.255.255.255，并且没有子网掩码的概念。分为以下几大类：
1. 保留链路本地地址（Link Local Address）：范围是224.0.0.0 – 224.0.0.255。

| 组播地址 | 用 途 |
| :------------: | :------------: |
| 224.0.0.1 | 组播组内所有成员监听的地址 |
| 224.0.0.2 | 所有路由器监听的地址 |
| 224.0.0.5 | OSPF监听的地址 |
| 224.0.0.6 | OSPF中DR, BDR监听的地址 |
| 224.0.0.9 | RIPv2监听的地址 |
| 224.0.0.10 | EIGRP监听的地址 |
| 224.0.0.13 | PIM发送Hello的地址 |

2. 全局地址（Globally Scoped Address），即所谓的公网组播地址：范围是224.0.1.0 – 238.255.255.255。其中232.0.0.0 – 232.255.255.255为指定源组播（SSM, Source Specific Multicast）；GLOP地址，233.0.0.0 – 233.255.255.255，AS号与组播地址关联。
3. 限制范围地址（Limited Scoped Address），即私网组播地址：范围是239.0.0.0 – 239.255.255.255。
#### 1.2.2 组播MAC地址
在以太网中，其MAC地址可以与IP地址进行映射：MAC地址的前25位为：00000001.00000000.01011110.0，即01.00.5e.00.00.00 - 01.00.5e.7f.ff.ff，后23位映射组播IP地址。如：

![multicast_l2_addr](https://github.com/Minions1128/net_tech_notes/blob/master/img/multicast_l2_addr.jpg "multicast_l2_addr")
## 2. IGMP
* Internet Group Management Protocol，封装在IP内，协议号为2。
* 该协议定义的过程为最后一条路由器到接受终端的通信过程。
* 有三个版本，这里只讨论IGMPv1和IGMPv2。
### 2.1 IGMPv1
定义在RFC 1112，是一个C/S协议，Client为PC，Server为Leaf Router。
#### 2.1.1 报文格式
该协议有2类报文：成员查询和成员通告报文：

![multicast_igmpv1_pkg](https://github.com/Minions1128/net_tech_notes/blob/master/img/multicast_igmpv1_pkg.jpg "multicast_igmpv1_pkg")
* Ver：IGMP版本信息
* Type：报文类型
1. Query报文，由Server发出，报文源地址为路由器地址，目的地址为224.0.0.1，组地址：0.0.0.0；
2. Report报文，由PC发出，宣告其想加入某个组播组（例如224.1.1.1组），它会发送源地址为PC的IP地址、目的地址为224.1.1.1，组地址为224.1.1.1的报文。`该报文的目的地址为224.1.1.1有两个目的：1)告知最后一跳路由器该网络有PC加入该组播组；2)当PC收到Query报文之后，不会立即就回复Report报文，而会在本地开启1-10s的随机计时器，等待相应的时间回复Report，所以Report报文可以告知其他终端不要再发送其他Report报文。`
* 组地址：区分组播组的地址
#### 2.1.2 通信过程
1. **Query报文的发送**：Leaf Router会以周期为60 – 120s发送Query报文，查询是否有终端想加入某个组，若同网络有多个Leaf Router，则有PIM的DR来发送Query报文；
2. **Report报文的发送**：终端想加入某个组播组，可以发送该报文，该报文可以作为作为Query报文的Ack报文，也可以主动向Leaf Router发送；
3. **流量转发**：Leaf Router收到Report报文之后，会对每个组播组建立的相应表项，同时建立一个180s的Holdtime计时器，在计时器到期之前，没有收到任何Report报文，就会停止转发该类报文。同时也会保持60s一次的查询报文的发送。终端收到查询报文之后，也会回复Report报文；
4. **离组**：终端离开组播组的过程成为静悄悄地离组，不会通知Leaf Router。当Holdtime计时器超时时，才会停止转发流量，这为IGMPv1的硬伤。
### 2.2 IGMPv2
#### 2.2.1 报文格式
![multicast_igmpv2_pkg](https://github.com/Minions1128/net_tech_notes/blob/master/img/multicast_igmpv2_pkg.jpg "multicast_igmpv2_pkg")
* Max.Resp.Time：最大相应时间，将其时间优化为可以为小数秒

相比IGMPv1，新定义了2个报文：指定组查询（Group-Specific Query）和离组消息（Leave Group Message）。
- **指定组查询报文**：源地址为本地地址，目的地址和组地址为224.1.1.1。
- **离组报文**：源地址为本机地址，目的地址为224.0.0.2，组播组地址为想要离开的组，即224.1.1.1。
#### 2.2.2 通信过程
1. **选举查询者**：IGMPv2定义了查询者机制，多个Leaf Router需要选出接口IP地址最小的作为查询者，由他来周期性的发送查询报文。选举报文由第一次的查询报文来决定。如果120s之内没有收到查询报文，会重新根据查询者选举机制来确定新的查询者；
2. **加组**：同IGMPv1；
3. **转发流量**：同IGMPv1；
4. **离组**：当某个终端想要离开组播组时，要发送离组报文。查询者收到离组报文之后，会将超时计时器由180s改为2s，然后发送指定组查询报文，其他PC收到该报文之后，会立即应答。如果Leaf Router在超时时间（2s）内没有收到应答，查询者认为该组中没有其他成员，会停止发送组播组消息。
### 2.3 IGMPv3
* IGMPv3增强了对主机的控制能力，可以基于组播源地址进行过滤，使主机在加入某组播组的同时，能够明确要求接收或拒绝来自某特定组播源的组播信息。
* IGMPv1&2都是基于ASM（Any Source Multicast，任意源组播，路由器转发报文不关心是谁发送的报文，只负责转发报文），IGMPv3可以基于SSM（Source Specific Multicast，指定源组播，路由器只对某个路由器转发组播报文，这样底层客户端可以知道源地址）。
### 2.4 配置命令
```
ip multicast-routing            # 开启组播路由
ip pim sparse-mode              # 端口开启PIM Sparse-mode
ip igmp join-group 224.1.1.1    # 终端端口加入224.1.1.1组播组
sh ip igmp int fa0/0            # 查看IGMP配置情况
sh ip igmp groups               # 查看路由器关联的组播组
ip igmp version 3               # 端口启用IGMPv3
```
### 2.5 交换机对组播流量的优化
Leaf Router对流量进行优化之后，要将流量通过交换机发送给PC，这里讨论2中交换机对组播流量进行优化的机制：CGMP和ICMP snooping
#### 2.5.1 CGMP
该协议运行在交换机与路由器之间，实现组播流量不会在整个广播域内泛洪。其为C/S模型，Client为交换机，Server为路由器。
* 运行机制：
1. 终端要加入某组播组，会发送Report报文，该报文的2层封装的源MAC地址为本地MAC地址，称为USA，目的MAC地址为224.1.1.1对用的MAC地址，成为GDA。
2. 路由器收到该报文之后，将USA和GDA信息生成CGMP通告报文发送给交换机，交换机会将该报文中的信息存入相应的CGMP表项。交换机等收到该数据报文之后，就不会向其他端口转发，复制若干份，只发送给相应端口。
* 缺陷：由于MAC地址与IP地址的映射为模糊映射，所以可能会造成少发。
#### 2.5.2 IGMP snooping
* 运行机制：交换机开启该机制，收到终端发送的Report报文会拆到3层报文，查看其IP地址，然后将组播组地址，然后再与端口相对应，添加到IGMP snooping表中，从而避免了模糊映射。
* 缺点：需要拆包到3层，建议3560以上的交换机使用该机制。
* IGMP snooping配置命令
```
ip igmp snooping    #全局开启IGMP Snooping，默认开启
show igmp snooping  #查看IGMP Snooping信息
```
#### 2.5.3 IGMP proxy
IGMP proxy，即代理。IGMP交换机通过拦截IGMP报文来建立组播表，其功能可以分为两个部分：上联端口执行主机角色，下联端口执行路由器角色。
1. **上联端口执行主机角色**：响应来自路由器的查询，当新增用户组或者某组最后一个用户退出时，主动发送成员报告包或者离开包；
2. **下联端口执行路由器的角色**：完全按照IGMP中规定的机制执行，包括查询者选举机制，定期发送通用查询信息，收到离开包时发送特定查询等。
## 3. RPF校验
当一台路由器收到了一个组播报文，不仅要关心其目的地，也关心其发送者，以免产生重复报文。该过程称之为RPF（Reverse Path Forwarding）校验，目的为了防止重复报文产生，解决环路问题。
### 3.1 校验过程
当路由器收到了一个组播报文，提取其源IP地址，在本地路由条目中查找是否有道该源地址的路由条目：
1. 如果没有，该路由器对于该信源没有RPF接口，并丢弃该报文；
2. 如果有，进而查看路由条目中，到该源IP地址的出站接口是否与该报文的入站接口为同一接口：如果不是：则丢弃该报文；如果是：则转发该报文。
### 3.2 负载均衡
* 当路由负载均衡的条件下，出站接口的IP地址越大，越有可能作为RPF接口。
* RPF接口也可以手动修改。如果信源服务器有多个，我们任然需要做负载均衡，可以通过修改组播静态路由的方式来间接地修改PRF接口。
```
ip mroute 1.1.1.1 255.255.255.255 fa0/0
ip mroute 1.1.1.2 255.255.255.255 fa0/1
show ip mroute static   # 查看组播静态路由
```
通过添加两条组播静态路由，将组播源1.1.1.1的PRF接口改为fa0/0，组播源1.1.1.2的PRF接口改为fa0/1。
## 4. PIM
PIM (Protocols Independent Multicast)，报文封装在IP报文之内，协议号为13，通过224.0.0.13地址发送给邻居，使用树形结构转发流量，组播分发树的类型：
1. Source-rooted，也称为Shortest Path Trees（SPTs），对应Dense模式；
2. Shared Trees，也叫Rendezvous Point（RP，集合点）树，对应Sparse模式。

组播路由协议部署完毕之后，路由器之间会建立邻居，但是不会立即发送彼此的路由条目，而是等有组播流量产生之后，才会传递路由条目。

**邻居**：PIM建立邻居使用的链路有2种类型，P2P和MA。使用MA建立邻居时需要选出DR，DR的选举方式与OSPF一样，其可以抢占。维护邻居关系的Hello报文发送时间为30s，Holdtime为3.5 * 30=105s。

**接口**：当一些接口没有启用PIM的情况：
1. 第一跳路由器的接受端口没有启用PIM，接收到所有组播报文都会拆包丢弃；
2. 最后一跳路由器的发送端口没有启用PIM，其不会发送Query报文；
3. 中间路由器彼此连接的物理接口没有启用PIM，接口不会转发任何组播报文。
### 4.1 PIM-DM
#### 4.1.1 SPT
当路由器启用了PIM-DM，有流量需要转发时，会向邻居泛洪流量，通过RPF校验，确定出最短路径以及转发端口。生成（S, G）表项，S：Source，G，Group，并将流量直接转发到目的网络。
* 优点是路径最短，缺点是表项很多，浪费资源。
#### 4.1.2 协议过程
整网95%的路由器都要接受组播流量，这是需要部署PIM-DM，基于推push模型。

**初始泛洪**：第一跳路由器收到组播报文之后，会将流量泛洪到整个网络；

**裁剪**：如果路由器通过IGMP可以判断出，下游没有接收组播流量，则会通过RPF接口发送一个剪裁消息（prune message），以阻止泛洪流量的发送。路由器收到prune消息后，接口会180s以内不会发送组播流量，180s之后，该接口会重新发送组播流量。
#### 4.1.3 配置命令
1. 部署IGP：组播域内部署单播路由收敛，第一跳路由器连接信源的端口需要加入到组播域；
2. 运行PIM：第一跳路由器连接信源接口、组播域内、最后一跳路由器连接终端的接口都需要部署PIM；
```
ip multicast-routing    # 在全局模式启用组播
ip multicast-routing distributed    # 交换机的命令
ip pim dense-mode       # 接口模式开启pim密集模式
```
3. 检查配置
```
show ip route           # 单播路由表
show ip pim neighbor    # 检查pim邻居
show ip mroute          # 查看组播路由表
# （表项中的路由条目会对应有端口，以及是否有剪裁）
ping                    # 在信源ping组播地址
```
#### 4.1.4 配置举例
拓扑如下所示：R1为组播源，R6为接收端，R2 - R6模拟组播网络
```

                        +---(0/0)R3(0/1)---+
                      (1/0)              (1/0)
    R1(0/0)---(0/0)R2---|                  |---(0/0)R5(0/1)---(0/0)R6
                      (1/1)              (1/1)
                        +---(0/0)R4(0/1)---+

```
先进行基础配置：IP地址、动态路由协议等，使全网路由可达。组播配置有：
```
R2, R5
ip multicast-routing
interface fa0/0
 ip pim dense-mode
interface fa1/0
 ip pim dense-mode
interface fa1/1
 ip pim dense-mode

R3, R4
ip multicast-routing
interface range fastEthernet 0/0-1
 ip pim dense-mode
```
R6加入到组播组239.2.2.2
```
R6
interface range fastEthernet 0/0
 ip igmp join-group 239.2.2.2
```
R6加入到组播组239.2.2.2之后，R5上有了(* , 239.2.2.2)的组播路由
```
(*, 239.2.2.2), 00:00:11/00:02:59, RP 0.0.0.0, flags: DC
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet1/1, Forward/Dense, 00:00:11/stopped
    FastEthernet1/0, Forward/Dense, 00:00:11/stopped
    FastEthernet0/0, Forward/Dense, 00:00:11/stopped
```
使用R1 ping 239.2.2.2，模拟R1向R6发送组播流量：
```
R1#ping 239.2.2.2 repeat 3
Type escape sequence to abort.
Sending 3, 100-byte ICMP Echos to 239.2.2.2, timeout is 2 seconds:

.
Reply to request 1 from 56.1.1.6, 508 ms
Reply to request 2 from 56.1.1.6, 160 ms
```
同时，所有组播路由器里有了(* , 239.2.2.2)和(12.1.1.1, 239.2.2.2)两条组播路由
```
(*, 239.2.2.2), 00:00:45/stopped, RP 0.0.0.0, flags: D
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet1/1, Forward/Dense, 00:00:45/stopped
    FastEthernet1/0, Forward/Dense, 00:00:45/stopped

(12.1.1.1, 239.2.2.2), 00:00:45/00:02:14, flags: T
  Incoming interface: FastEthernet0/0, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet1/0, Prune/Dense, 00:00:45/00:02:14
    FastEthernet1/1, Forward/Dense, 00:00:45/stopped
```
### 4.2 PIM-SM
#### 4.2.1 RPT
RPT中，由管理员定义一个RP，第一跳路由器收到流量之后，不会发往目的地，而是现发送给RP，然后再由RP转发给接受者。RP下游的路由器生成（*，G）表项，信源到RP仍为（S，G）表项。
* 优点是优化部分路由，缺点是路径不一定是最优。
#### 4.2.2 协议过程
整网中有5%设备接受流量使用稀疏模式，他使用了拉（pull）模型，会同时使用到SPT和RPT。
1. 当最后一跳路由器接收到IGMP Report报文后，会生成相应的表项，同时会发送（*，G）Join给RP，告知RP以及沿途路由器，本路由器有接受者；
2. RP收到（*，G）join后，RP到接受者的沿途路由器会形成RPT；
3. 信源发送组播流量，第一跳路由器将（S，G）register的封装成单播的
组播报文发送给RP，目的在于查询在该组播域内是否有接受者；
4. RP收到之后，由于已经有了接受者，会解封成组播包，沿RPT发送给接受者；同时，RP会向第一跳路由器发送（S, G）join，加入到SPT中；
5. 这时，第一跳路由器会同时发送组播封装成的单播流量和组播流量给，为了防止重复报文，RP会向第一跳路由器封装成单播的形式发送（S，G）register-stop报文，目的告知第一跳路由器发送只组播报文到本地。
6. 为了优化组播流量发送的路由，收到组播流量的最后一跳路由器，如果流量超过阈值（默认为0 kbps），会向第一跳路由器发送（S，G）join，以第一跳路由器到本地的SPT。当去往RP与第一跳路由器的“岔路路由器”时，“岔路路由器”会转发最后一跳路由器的（S，G）join给第一跳路由器，同时向RP发送一个（S，G）RP置为的prune报文，告知 RP本地不接受RPT接受流量。
7. 第一跳路由器收到最后一跳路由器的（S，G）join，SPT建立完成，使用SPT转发组播流量。
#### 4.2.3 RP的选举
选举RP有三种方式，静态RP、auto-RP以及BSRa
1. **静态RP**：有网络管理员手动指定。
2. **Auto-RP**：该选举方式为C/S模型，C为CRP（Candidate RP），S为MA（Mapping Agency）。CRP周期性地向224.0.1.39发送announce报文，MA会监听224.0.1.39和224.0.1.40地址，仲裁出RP，然后通过224.0.1.40发送discovery报文，告知所有路由器RP的地址，所有路由器会监听该地址。`由于纯PIM-SM使用auto-RP时需要以组播方式发送announce报文，而发送的组播报文需要发送给RP，这使得纯PIM-SM模式下无法使用auto-RP模式，解决方案有：整网迁移使用sparse-dense-mode；或者所有路由器接口启用ip pim auto-rp listener，该命令可以在224.0.1.39和224.0.1.40组播组使用dense-mode。
默认情况下，静态RP的优先级会比auto-RP的优先级低。`
3. **BSR**：与auto-RP的用法类似，使用优先级来控制RP仲裁者BSRC来仲裁RP。
#### 4.2.4 配置命令
```
ip pim rp-address x.x.x.x acl #在组播域内静态指定RP地址，acl参数表示指定组播组的RP
ip pim rp-address x.x.x.x override #使静态RP的优先级高于auto-rp
ip pim send-rp-announce lookback 1 scope 5 #在定义了PIM的某种模式的lookback 1接口发送announce报文，成为CRP
ip pim send-rp-discovery lookback 1 scope 5 #在定义了PIM的某种模式的lookback 1接口发送discovery报文，成为MA
show ip pim rp-mapping #查看RP
ip pim sparse-mode #端口开启PIM Sparse-mode
ip pim sparse-dense-mode #端口开启PIM Sparse-Dense-mode
ip pim spt-threshold traffic [infinity] #最后一跳路由器上设置切换阈值
```
#### 4.2.5 DR的作用
在密集模式中，DR无用，稀疏模式中DR发送（* ，G）join和（S，G）register报文。
#### 4.2.6 配置举例
拓扑如4.1.4中相同，组播中，将R2配置为RP
```
R2, R5
ip multicast-routing
interface fa0/0
 ip pim sparse-mode
interface fa1/0
 ip pim sparse-mode
interface fa1/1
 ip pim sparse-mode
ip pim rp-address 2.2.2.2
R3, R4
ip multicast-routing
interface range fastEthernet 0/0-1
 ip pim sparse-mode
ip pim rp-address 2.2.2.2
```
将R6加入到组播组239.2.2.2之后，从R5到RP上（R2，R3，R5）都有了(* , 239.2.2.2)的组播路由
```
(*, 239.2.2.2), 00:00:11/00:02:59, RP 0.0.0.0, flags: DC
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet1/1, Forward/Dense, 00:00:11/stopped
    FastEthernet1/0, Forward/Dense, 00:00:11/stopped
    FastEthernet0/0, Forward/Dense, 00:00:11/stopped
```
使用R1 ping 239.2.2.2，模拟R1向R6发送组播流量：
```
R1#ping 239.2.2.2 repeat 3
Type escape sequence to abort.
Sending 3, 100-byte ICMP Echos to 239.2.2.2, timeout is 2 seconds:

.
Reply to request 1 from 56.1.1.6, 508 ms
Reply to request 2 from 56.1.1.6, 160 ms
```
同时，所有组播路由器里有了(* , 239.2.2.2)和(12.1.1.1, 239.2.2.2)两条组播路由
```
(*, 239.2.2.2), 00:00:45/stopped, RP 0.0.0.0, flags: D
  Incoming interface: Null, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet1/1, Forward/Dense, 00:00:45/stopped
    FastEthernet1/0, Forward/Dense, 00:00:45/stopped

(12.1.1.1, 239.2.2.2), 00:00:45/00:02:14, flags: T
  Incoming interface: FastEthernet0/0, RPF nbr 0.0.0.0
  Outgoing interface list:
    FastEthernet1/0, Prune/Dense, 00:00:45/00:02:14
    FastEthernet1/1, Forward/Dense, 00:00:45/stopped
```
