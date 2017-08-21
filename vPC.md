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

![vpc.sys_mac](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.sys_mac.jpg "vpc.sys_mac")

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
会将对端设备或者接口暂停状态，当为graceful一致性检测时，仅暂停secondary设备，
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
对端设备或者接口依然转发流量，但其会收到非正常报文转发的影响，所有vPC member port保持挂起状态，vPC系统会触发保护动作
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
## 4. 配置vPC
### 4.1 vPC peer-keepalive link
* 该链路承载了vPC设备周期性的心跳，消息类型封装在UDP 3200端口中。该两路有两个作用：
1. 在系统启动后，vPC域形成之前，来保证两端设备都是up的；
2. 当vPC peer-link down后，用来检测是否有脑裂现象，即active/active状态。
* 计时器
| 计时器 | 默认值 |
| :------------ | :------------ |
| Keepalive interval | 1s |
| Keepalive hold timeout | 3s |
| Keepalive timeout | 5s |
1. Keepalive hold timeout：peer-link down失效之后，会触发keepalive hold计时器，在此期间，secondary设备会忽略peer-keepalive的hello消息。为了避免网络聚合时，对其产生的影响；
2. Keepalive timeout：若peer-link还是没有up，会触发该计时器。在此期间，secondary会寻找vPC peer-keepalive的hello消息：如果secondary收到了hello消息，则可以推断出有脑裂发生，secondary会关闭其所有vPC member port





## 故障场景
* vPC member port fails：下联设备会通过PortChannel感知到故障，会将流量切换到另一个接口上。这种情况下，vPC peer-link可能会承数据流量。
* vPC peer-link failure：当keepalive link还可用时，secondary switch会将其所有的member port关闭。
* vPC primary switch failure：Secondary switch会变为可操作的primary switch，当原来的primary switch恢复之后，其又会变为secondary switch
* vPC keepalive link failure：其转发流量不会造成影响，但建议尽早修复
* vPC keepalive link and peer-link both failure：如果vPC keepalive link先down，然后peer-link跟着down，primary和secondary switch同时成为primary switch，即脑裂。现有流量不会造成影响，但新的流量就不可用。同时单播mac地址和IGMP组，因此其无法维持单播和组播的转发，还可能导致duplicate包。
