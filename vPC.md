# vPC
## 1. 概述
* A virtual port channel (vPC) allows links that are physically connected to two different Cisco Nexus Series devices to appear as a single port channel to a third device. The third device can be a switch, server, or any other networking device that supports link aggregation technology.
* 其优点有：屏蔽了STP，最大限度使用上联带宽，提供了快速聚合上联链路，为服务器提供双active的默认网关。
* 名词解释

![vpc.component](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.components.jpg "vpc.component")
* 防环机制：在数据层面
1. vPC peer-link通常不转发数据，通常认为是在稳定网络中，控制平面的扩展，用来传输mac地址，vPC member port状态以及IGMP；
2. 来自vPC member port的流量，然后穿过vPC peer-link之后，不会被允许再从其他member port出去，但可以从其他类型端口转发，如L3口，orphan port等。
## 2. 部署场景
+ DC内部部署vPC
    * Single-sided vPC，在接入层和汇聚层
    * Double-sided vPC，也叫多层vPC，接入层和汇聚层同时使用vPC，并且相互连接
+ DCI部署vPC
    * 多层vPC，汇聚层的DCI
    * 双2层/3层Pod连接
### 2.1 Single-sided vPC
![vpc.single_side_topo](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc_single_side_topo.jpg "vpc.single_side_topo")

接入设备直接双上联到思科Spine设备，形成vPC域，支持LACP active，passive以及static bundling(ON mode)
* 强烈建议：接入设备连接vPC时，用LACP协议
### 2.2 Double-sided vPC
![vpc.double_sided_topo](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.double_sided_topo.jpg "vpc.double_sided_topo")

这种拓扑叠加了两层vPC的区域，并且使用自己的vPC的链路连接起来。底层的vPC使用active/active连接终端设备和接入交换机；顶层vPC使用active/active FHRP在L2/L3边界的汇聚层。
### 2.3 多层vPC，汇聚层的DCI
![vpc.dci.agg.topo](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.dci.agg.topo.jpg "vpc.vpc.dci.agg.topo")

这种场景中，一个vPC区域的专门通信层（连接汇聚层的也运行了vPC）用来连接两个DC
### 2.4 双2层/3层Pod连接
![vpc.dci.dual.l2.l3.pod](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.dci.dual.l2.l3.pod.jpg "vpc.dci.dual.l2.l3.pod")

这种方式没有专门的vPC通信层来提供DCI。
## 3. 构建vPC
### 3.1 基本步骤
1. 配置vPC域ID，两端设备必须一致，由于使用LACP的一些信息，配置double-sited vPC时，两层的ID不可以一致；
2. 配置vPC peer-keepalive link；
3. 配置vPC peer-link；
4. 配置vPC member port.
### 3.2 vPC system-mac和local system-mac
* 我们配置完vPC域ID之后，会自动分配一个system mac，两端的system mac都一样，其固定格式为：vPC system-mac = 00:23:04:ee:be:<vpc domian-id的16进制>
* 每台peer device都有自己的vPC local system-mac，该地址从系统或者VDC系统mac中获取
```
show vpc role   # 查看vPC system-mac和local system-mac
show vdc    # 查看vdc的系统mac
```
* vPC system-mac和local system-mac均被用作LACP的LACP system ID，具体用法：
1. N5K-1和N7K-1形成local port-channel，N7K-1会用其vPC local system-mac和N5K-1交换LACP信息；
2. N5K-2和N7K-1和N7K-2形成了vPC，N7K-1和N7K-2会用其system-mac与N5K-2交换LACP信息。
### 3.3 vPC role
vPC定义了两种角色：primary和secondary，primary会传递BPDU以及应答ARP，可以通过`role priority <value>`修改，较小的为primary
### 3.4 CFS
* CFS，Cisco Fabric Services协议，在两台运行vPC的设备，提供稳定的同步和一致性检测机制。
* 其可以提供vPC member port状态通告、生成树管理、同步HSRP和IGMP信息。
* 当vPC部署成功后，CFS自动开启。
* 其封装在以太网帧中，在vPC peer-link中传输，并且使用其CoS=4
### 3.5 一致性检测
vPC每台设备有着不同的控制平面（control planes），CFS会将两台设备的状态进行同步，包括mac地址表，IGMP协议状态以及vPC状态等。系统配置必须一致，然后其会自动进行一致性检测来确保网络的正确性。有两类一致性检测：
#### 3.5.1 Type 1
会将peer switch或者接口暂停状态，当为graceful一致性检测时，仅暂停secondary设备，
* 全局检测的内容有
    * STP模式
    * 每个VLAN的STP状态
    * MST
    * STP的全局配置，如Bridge Assurance、端口类型、Loop Guard、BPDU过滤等
* 接口下检测的内容
    * LACP模式
    * 速度、双工模式、switchport模式、MTU
    * STP接口设置：端口类型、Loop Guard、根防护等
#### 3.5.2 Type 2
peer switch或者接口依然转发流量，但其会收到非正常报文转发的影响，所有vPC member port保持挂起状态，vPC系统会触发保护动作，如：MAC超时时间、静态mac表项、SVI、ACL、QoS等
### 3.6 配置建议
```
vlan 1-4096     # 建议提前规划好vlan
feature vpc
interface Ethernet1/1  # 配置vPC keepalive link
  vrf member keepalive
  ip address 1.1.1.1/30
  no sh
interface port-channel 100  # vPC peer-link通常
  spanning-tree port type network
  vpc peer-link
vpc domain 10
  # vPC域ID必须和对端相同，double-sided两个ID不同
  role priority 1
  peer-keepalive destination 1.1.1.2 source 1.1.1.1 vrf keepalive
  ip arp synchronize
interface Ethernet4/1
  channel-group 11 mode active      # 配置LACP建议使用active模式
interface port-channel11    # vPC member port
  switchport
  switchport mode trunk     # member port只能为2层端口
  vpc 11
```
## 4. vPC的组成部分的配置
### 4.1 vPC peer-keepalive link
* 该链路承载了vPC设备周期性的心跳，消息类型封装在UDP 3200端口中。该两路有两个作用：
1. 在系统启动后，vPC域形成之前，来保证两端设备都是up的；
2. 当vPC peer-link down后，用来检测是否有脑裂现象，即active/active状态。
#### 4.1.1 计时器

| 计时器 | 默认值 |
| :------------ | :------------ |
| Keepalive interval | 1s |
| Keepalive hold timeout | 3s |
| Keepalive timeout | 5s |
1. Keepalive hold timeout：peer-link down失效之后，会触发keepalive hold计时器，在此期间，secondary设备会忽略peer-keepalive的hello消息。为了避免网络聚合时，对其产生的影响；
2. Keepalive timeout：若peer-link还是没有up，会触发该计时器。在此期间，secondary会寻找vPC peer-keepalive的hello消息：如果secondary收到了hello消息，则可以推断出有脑裂发生，secondary会关闭其所有vPC member port
#### 4.1.2 部署建议
1. 使用专用1G的链路来进行部署；
2. 使用Mgmt0口；
3. 最后可以使用三层链路使其达到路有通常。
4. 双引擎交换机并且使用它们的mgmt0口来充当peer-keepalive link时，不能直接将mgmt0口直接插到相同的引擎中（如，一台交换机的sup1的管理口直接插到另一台交换机的sup1的管理口），应该使用一台中间设备，如下图所示。
5. 建议使用不同的vrf来配置peer-keepalive link

![vpc.pkl.2sup.mgmt](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.pkl.2sup.mgmt.jpg "vpc.pkl.2sup.mgmt")
### 4.2 peer link
peer link为标准的802.1q trunk链路，可以承载vPC和非vPC vlan；承载CFS消息，消息中CoS为4；可以泛洪流量到其他vPC设备；可以传递BPDU，HSRP的hello，以及IGMP的更新等。其防环机制由硬件完成。
#### 4.2.1 配置建议
1. 成员端口为10G的以太网端口；
2. 使用至少2根10G的以太网端口，其线卡类型必须相同；
3. 建议使用2种不同的线卡来部署port-channel；
4. peer-link之间不要添加任何设备。
#### 4.2.2 转发
1. 单播：一般单播流量会本地转发，除非vPC member port fail；
2. 组播：一般peer-link会将组播流量复制给peer-link，除非在其组播环境中，不支持DR
3. peer-link也支持vlan裁剪，前提是这些vlan在member port是允许的
4. 遇到孤立端口连接到secondary switch上时，如果peer-link down之后，其会变为孤立端口，解决方法是配置命令`dual-active exclude interface-vlan <vlan-list>`
#### 4.2.3 vPC Object Tracking
* 使用场景：当设备只有一块线卡时，或设备的上联链路和vPC peer-link在一个线卡上时，如果线卡损坏，peer-link和上联链路同时down，并且这台设备是2层和3层的边界，如果这台设备为primary，secondary会将所有member port关闭，这会造成流量黑洞。

![vpc.track](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.track.jpg "vpc.track")
* 解决办法：vPC object tracking，可以暂停损坏的设备，以保证业务的正常。
* 配置举例：
```
! Track the vpc peer link
track 1 interface port-channel11 line-protocol
! Track the uplinks to the core
track 2 interface Ethernet1/1 line-protocol
track 3 interface Ethernet1/2 line-protocol
track 10 list boolean OR
    ! 将所有track归入track 10，并且使用or规则
    ! ==> or为，所有track只要有一个为真，所有为真
    ! ==> 即，所有track失效后，该track才会失效。
    object 1
    object 2
    object 3
! 如果object 10在primary失效后，primary会切换到其他设备
! ==> 切原来的primary会关闭所有的member port
vpc domain 1
    track 10
```
### 4.3 vPC member port
vPC member port是port-channel的一个端口，并且仅支持2层网络。定义时，需要指定关键字`vpc <id>`。

```
! 两台交换机配置必须相同，如果配置不同，会导致一致性检测
! 7K1:
interface port-channel201
  switchport mode trunk
  switchport trunk native vlan 100
  switchport trunk allowed vlan 100-105
  vpc 201
  ! 为了方便管理，vpc id和port-channel应该相同
! 7K2:
interface port-channel201
  switchport mode trunk
  switchport trunk native vlan 100
  switchport trunk allowed vlan 100-105
  vpc 201
! 配置物理口到port-channel时，
! ==> 根据线卡的不同，并且注意，
! ==> 划入一个port-channel的口应该属于同类线卡。
```
### 4.4 混合chassis模式
* F1系列线卡提供2层以太网交换服务，M1于F1之间相互操作时。
* 需要L3代理路由：F1的流量可以传递（单播流量）或复制（组播流量）到任意M1端口。
* 可以使用命令来`hardware proxy layer-3 forwarding`修改M1的端口或者端口组为3层代理路由，使用命令`show hardware proxy layer-3 detail`来查看详细情况
* 使用F1线卡为peer-link时，需要开启命令`peer-gateway exclude-vlan <VLAN list>`来排除那些备份路由的vlan
* 使用M1线卡为peer-link时，不需要开启`peer-gateway exclude-vlan <VLAN list>`
* 建议使用混合chassis时，建议使用2块以上的M1线卡来保证3层 uplinks, SVI以及HSRP/VRRP特性。
* 在混合chassis中，如果使用1块M1线卡和F1线卡混合使用时，当M1失效后：由于vPC放环机制，VLAN间的流量会有黑洞
，up的M1模块会处理所有的目的mac或者hsrp/vrrp的vmac；3层流量（南北向流量）没有问题。
## 5. 将设备加入到vPC域
* 加入的设备类型有多种：交换机、服务器、防火墙、负载均衡器、NAS（Network Attached Service）等，这些设备必须：支持802.1ad标准，或者支持配置为on模式
* N7K不支持PAgP
* N7K的port-channel支持不同类哈希算法，在默认VDC中配置`port-channel load-balance`
* 强烈建议使用LACP协议来配置vPC，由于active-active模式比active-passive模式初始化速度快，所以建议使用active/active模式
* 若不支持LACP，可以手动绑定机制，采用on模式；
* 如果下联设备为思科Nexus交换机，建议开启LACP的graceful-convergence选项（默认开启的）；若不为思科设备，建议将该功能关闭
### 5.1 Single-sided vPC
* 最大支持16根链路，每台vPC交换机8根
* 从北向南的流量，vPC设备会在本地执行负载均衡，然后将其转发出vPC member port，除非去往南向的唯一路径要穿越vPC peer-link
### 5.2 Double-sided vPC
* 这种vPC配置在2个接入交换机形成的vPC域中，在链接汇聚层交换机时形成另一个vPC域，成为一个big fat vPC，其成员端口也上升到32个。
* 上层vPC域通常作为汇聚层，2、3层的边界
* 下层vPC域作为接入层，仅仅有2层网络
* 配置举例

![vpc.double.sided.cfg.eg](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.double.sided.cfg.eg.jpg "vpc.double.sided.cfg.eg")

7K1 configuration:
```
interface port-channel1
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  vpc 1
interface Ethernet1/1-4
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  channel-group 1 mode active
  no shutdown
interface Ethernet1/5-8
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  channel-group 1 mode active
  no shutdown
! vPC peer-link
interface port-channel10
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  spanning-tree port type network
  vpc peer-link
```
7K2 configuration:
```
interface port-channel1
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  vpc 1
interface Ethernet1/1-4
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  channel-group 1 mode active
  no shutdown
interface Ethernet1/5-8
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  channel-group 1 mode active
  no shutdown
! vPC peer-link
interface port-channel10
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  spanning-tree port type network
  vpc peer-link
```
5K1 configuration:
```
interface port-channel1
  ! 在接入层，也要配置上联的port-channel
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  vpc 1 ! 上联vPC id必须与N7K一致
interface Ethernet1/1-4
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  channel-group 1 mode active
  no shutdown
interface Ethernet1/5-8
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  channel-group 1 mode active
  no shutdown
! vPC peer-link
interface port-channel10
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  spanning-tree port type network
  vpc peer-link
```
5K2 configuration:
```
interface port-channel1
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  vpc 1
interface Ethernet1/1-4
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  channel-group 1 mode active
  no shutdown
interface Ethernet1/5-8
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  channel-group 1 mode active
  no shutdown
! vPC peer-link
interface port-channel10
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1000-1100
  spanning-tree port type network
  vpc peer-link
```
### 5.3 单上联到vPC
如果无法实现双上联到vPC，可以用以下三种方法单挂到vPC中
* 1. 连接到可以双上联到vPC的交换机上。当peer-link失效后，这种方式可以保持双活下vPC的处理机制
![vpc.1up.1](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.1up.1.jpg "vpc.1up.1")
* 2. 连接到vPC peer设备的非vPC vlan中。非vPC vlan是没有划入vPC member port和peer-link的vlan，并且再添加另一条链路使两台peer switch互连，即使用传统STP协议。
![vpc.1up.2](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.1up.2.jpg "vpc.1up.2")
* 3. 使用orphan port。即交换机单挂在peer switch上，但使用vPC的vlan，如果不适用vPC的vlan，就不用定义orphan port。建议在primary挂orphan port。
![vpc.1up.3](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.1up.3.jpg "vpc.1up.3")
## 6. 将STP连接到vPC
### 6.1 连接方法
与5.3的方法类似：
1. 使用非vPC的vlan连接STP设备到vPC中，在两台peer switch之间添加额外的链路
2. 使用vPC的vlan连接到vPC中，建议连接到primary交换机上
### 6.2 配置建议
1. 配置建议全局或者接口开启开启：STP端口类型（edge, normal还是network），Loop guard，BPDU guard，BPDU filter，并且peer switch配置要相同以免进行一致性检测
2. 默认vPC peer-link是开启Bridge Assurance，不要将其关闭。
3. 与普通端口类似，如果遇到接入端口，建议配置port fast（port type edge）以及BPDU guard策略
4. vPC与STP设计蓝图

![vpc.stp.blutprint](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.stp.blutprint.jpg "vpc.stp.blutprint")

### 6.3 vPC与STP的BPDU
* vPC的STP只由primary控制，即只有这台交换机产生和发送BPDU，即使STP的根不为vPC的primary。
* Secondary也要启用STP功能，其会充当代理的身份，将受到的BPDU转发给primary
* vPC的member port会共享器STP的端口状态
* 强烈配置建议：
1. 建议将vPC作为STP所有vlan的根
2. 在orphan port出开启根防护
3. 在STP端口处开启edge或者trunk edge
2. 建议全局开启根防护、BPDU guard，不要关闭Loop guard、BA等，尤其是peer-link上的BA，但在member port上不要开启BA
### 6.4 Peer-switch
#### 6.4.1 用法
vPC的peer-switch特性要求两台vPC设备作为STP的一个整体，以根的形式存在，配置命令为`peer-switch`。需要在两台设备上同时配置。由于之前由primary充当根，当primary失效以后，需要一段时间的收敛，这一特性避免了收敛时间。配置举例：
```
! 两台设备的必须配置相同的配置
spanning-tree vlan 10-101 priority 8192

vpc domain 1
  peer-switch
```
部署该特性之后，vPC逻辑的根会将BPDU发送给其他设备，vPC双连设备就会收到两份相同的BPDU。当vPC peer-switch激活之后，BPDU代理就不会再通过peer-link来转发BPDU了。
#### 6.4.2 Hybird拓扑
在一些vPC域中，可能会同时存在vPC连接的设备以及STP连接的设备共同存在，需要对STP网络进行根桥的设置，需要用到spanning-tree pseudo-information特性，这条命令有2条子命令：
1. Designated priority：定义了vlan在交换机（peer switch）上的STP优先级，用于在不同vlan有效的负载均衡；
2. Root priority：用于当其中一台vPC交换机失效又恢复后的场景：在hybrid拓扑中，由于STP的网络比vPC恢复的速度要快，这时正好这台设备的本地MAC地址比vPC系统的MAC地址更好，这时会触发STP拓扑变更。为了避免这种情况，STP中，vPC系统的优先级要比每台交换机的本地优先级要低

配置举例

![vpc.pseudo.info](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.pseudo.info.jpg "vpc.pseudo.info")
```
S1 configuration:
S1(config)# spanning-tree pseudo-information
S1(config-pseudo)# vlan 1 designated priority 4096
S1(config-pseudo)# vlan 2 designated priority 8192
S1(config-pseudo)# vlan 1 root priority 4096
S1(config-pseudo)# vlan 2 root priority 4096
S1(config)# vpc domain 1
S1(config-vpc-domain)# peer-switch

S2 configuration:
S2(config)# spanning-tree pseudo-information
S2(config-pseudo)# vlan 1 designated priority 8192
S2(config-pseudo)# vlan 2 designated priority 4096
S2(config-pseudo)# vlan 1 root priority 4096
S2(config-pseudo)# vlan 2 root priority 4096
S2(config)# vpc domain 1
S2(config-vpc-domain)# peer-switch
```
### 6.5 BA with vPC
开启Bridge Assurance之后，不管端口什么状态，所有端口都会发送和接受BPDU，即，使用BPDU建立了双向确认机制，当一台交换机没有收到BPDU时，该端口会被置为inconsistent状态，这种机制可以防止环路的产生。当STP端口类型为network时，自动开启。在vPC的配置建议：
* 在vPC member port不要开启
* 在vPC peer-link上已经自动开启
* 即使在vPC上应用了peer-switch，还是建议在vPC上关闭BA
## 7. vPC的L3
不同网络的层次看待vPC的拓扑：

![vpc.l3.views](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.views.jpg "vpc.l3.views")

### 7.1 设计建议
1. 在三层与vPC之间，加入一台支持port-channel的2层设备；
2. 不要使用2层vPC连接3层设备，除非3层设备可以静态的路由到vPC peer switch的HSRP地址；
3. 如果同时需要2层流量和3层流量时，使用单独的3层链路来跑3层流量，将2层port-channel和3层路由流量区分开；
4. 通过配置SVI或者特定的链路来使得两台peer switch3层可达，以达到路由备份的目的
### 7.2 设计举例
一些推荐的设计拓扑
* 这种设计在3层设备与vPC之间，添加了一台2层设备，使vPC仅有2层流量

![vpc.l3.topo.ok.1](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.ok.1.jpg "vpc.l3.topo.ok.1")

* 这种设计使用额外的3层链路

![vpc.l3.topo.ok.2](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.ok.2.jpg "vpc.l3.topo.ok.2")

* 这种设计使2台peer switch建立起动态路由协议邻接关系，提供备用链路

![vpc.l3.topo.ok.3](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.ok.3.jpg "vpc.l3.topo.ok.3")

* 在peer switch之间使用额外的3层链路，形成非vPC的STP

![vpc.l3.topo.ok.5](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.ok.4.jpg "vpc.l3.topo.ok.5")

一些正确和错误的设计对比

| ![vpc.l3.topo.ok.4](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.ok.4.jpg "vpc.l3.topo.ok.4") | ![vpc.l3.topo.no.4](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.no.4.jpg "vpc.l3.topo.no.4") |
| :------------: | :------------: |
| ![vpc.l3.topo.ok.6](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.ok.6.jpg "vpc.l3.topo.ok.6") | ![vpc.l3.topo.no.6](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.no.6.jpg "vpc.l3.topo.no.6") |
| ![vpc.l3.topo.ok.7](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.ok.7.jpg "vpc.l3.topo.ok.7") | ![vpc.l3.topo.no.7](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.no.7.jpg "vpc.l3.topo.no.7") |
| ![vpc.l3.topo.ok.8](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.ok.8.jpg "vpc.l3.topo.ok.8") | ![vpc.l3.topo.no.8](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.l3.topo.no.8.jpg "vpc.l3.topo.no.8") |
### 7.3 备用路径
建立备份路径有以下3种方法，推荐度由高到低以此为：
1. 使用单独的3层点到点链路建立vPC peer switch时间的备份路径；
2. 使用已存在的vPC peer-link上，使用非vPC的vlan来建立SVI来建立邻居；
3. 使用vPC peer-link，并且使用vPC的vlan来建立3层邻居（最不推荐）。
## 8. vPC与HSRP/VRRP
1. 为了避免在vPC peer-link上形成路由邻接关系，定义的SVI关联HSRP/VRRP时，要作为被动路由接口。
2. 为了便于管理，将vPC的primary定义为HSRP的active，secondary定义为standy
3. 将所有SVI上的重定向关闭，以便管理，命令为`no ip redirect`
4. 不建议使用HSRP/VRRP的Object Tracking功能。如果配置了object tracking，假设N7K-2的上联链路失效，N7K-2收到的目的为vMAC的帧会通过peer-link发送给N7K-1，如果该IP报文目的网段在member port中，根据vPC放环规则，该报文会被丢弃。
5. 在DCI部署HSRP时，需要注意过滤DCI之间的HSRP的hello报文，以免出现在某个DC中，无active的现象。
## 9. vPC与网络服务
### 9.1 基本设计建议
![vpc.net.srv.desgin](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.net.srv.desgin.jpg "vpc.net.srv.desgin")

1. 在两台N7K的VDC之间插入网络服务设备（包括防火墙、服务器以及负载均衡器），网络服务设备使用穿透模式；
2. 设计3层vPC时，如果对端在3层，需要穿过2个vPC，不建议使用vPC，而使用STP
### 9.2 网络服务使用穿透模式
这种方式不需要再进行额外的配置，只需要设备支持port-channel以及vlan透传即可。

ASA与vPC使用穿透模式连接配置举例

![vpc.asa.trans](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.asa.trans.jpg "vpc.asa.trans")

ASA-1和ASA-2运行了HA，vlan 100用于inside，vlan 200用于outside，他们共同使用IP为100.100.100.0/24

![vpc.asa.trans.log](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.asa.trans.log.jpg "vpc.asa.trans.log")












## --------------------------------
## DCI以及加密
## 故障场景
* vPC member port fails：下联设备会通过PortChannel感知到故障，会将流量切换到另一个接口上。这种情况下，vPC peer-link可能会承数据流量。
* vPC peer-link failure：当keepalive link还可用时，secondary switch会将其所有的member port关闭，也包括SVI。orphan port如果连接在secondary switch上，会变为孤立端口
* vPC primary switch failure：Secondary switch会变为可操作的primary switch，当原来的primary switch恢复之后，其又会变为secondary switch
* vPC keepalive link failure：其转发流量不会造成影响，但建议尽早修复
* vPC keepalive link and peer-link both failure：如果vPC keepalive link先down，然后peer-link跟着down，primary和secondary switch同时成为primary switch，即脑裂。现有流量不会造成影响，但新的流量就不可用。同时单播mac地址和IGMP组，因此其无法维持单播和组播的转发，还可能导致duplicate包。
