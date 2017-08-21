# vPC
## 概述
* A virtual port channel (vPC) allows links that are physically connected to two different Cisco Nexus Series devices to appear as a single port channel to a third device. The third device can be a switch, server, or any other networking device that supports link aggregation technology.
* 其优点有：屏蔽了STP，最大限度使用上联带宽，提供了快速聚合上联链路，为服务器提供双active的默认网关。
* 名词解释

![vpc.component](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.components.jpg "vpc.component")
* 防环机制：在数据层面
1. vPC peer-link通常不转发数据，通常认为是在稳定网络中，控制平面的扩展，用来传输mac地址，vPC member port状态以及IGMP；
2. 来自vPC member port的流量，然后穿过vPC peer-link之后，不会被允许再从其他member port出去，但可以从其他类型端口转发，如L3口，orphan port等。
## 部署场景
+ DC内部部署vPC
    * Single-sided vPC，在接入层和汇聚层
    * Double-sided vPC，也叫多层vPC，接入层和汇聚层同时使用vPC，并且相互连接
+ DCI部署vPC
    * 多层vPC，汇聚层的DCI
    * 双2层/3层Pod连接
### Single-sided vPC
![vpc.single_side_topo](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc_single_side_topo.jpg "vpc.single_side_topo")

接入设备直接双上联到思科Spine设备，形成vPC域，支持LACP active，passive以及static bundling(ON mode)
* 强烈建议：接入设备连接vPC时，用LACP协议
### Double-sided vPC
![vpc.double_sided_topo](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.double_sided_topo.jpg "vpc.double_sided_topo")

这种拓扑叠加了两层vPC的区域，并且使用自己的vPC的链路连接起来。底层的vPC使用active/active连接终端设备和接入交换机；顶层vPC使用active/active FHRP在L2/L3边界的汇聚层。
### 多层vPC，汇聚层的DCI
![vpc.dci.agg.topo](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.dci.agg.topo.jpg "vpc.vpc.dci.agg.topo")

这种场景中，一个vPC区域的专门通信层（连接汇聚层的也运行了vPC）用来连接两个DC
### 双2层/3层Pod连接
![vpc.dci.dual.l2.l3.pod](https://github.com/Minions1128/net_tech_notes/blob/master/img/vpc.dci.dual.l2.l3.pod.jpg "vpc.dci.dual.l2.l3.pod")

这种方式没有专门的vPC通信层来提供DCI。
## 配置vPC
### 基本步骤：
1. 配置vPC域ID，两端设备必须一致，由于使用LACP的一些信息，配置double-sited vPC时，两层的ID不可以一致；
2. 配置vPC peer-keepalive link；
3. 配置vPC peer-link；
4. 配置vPC member port.


```
vpc domain 10   # 必须与对端设备的ID一致
  role priority 1000
  peer-keepalive destination 1.1.1.2 source 1.1.1.1 vrf keepalive
  peer-gateway
  ip arp synchronize
interface Ethernet1/1  # 配置vPC keepalive link
  vrf member keepalive
  ip address 1.1.1.1/30
  no sh
interface port-channel 100  # vPC peer-link通常
  spanning-tree port type network
  vpc peer-link
interface Ethernet4/1
  channel-group 11 mode active
  no sh
interface port-channel11    # vPC member port
  switchport
  switchport mode trunk
  switchport trunk allowed vlan 1-1000,1002-4094
  vpc 11
```

## 故障场景
* vPC member port fails：下联设备会通过PortChannel感知到故障，会将流量切换到另一个接口上。这种情况下，vPC peer-link可能会承数据流量。
* vPC peer-link failure：当keepalive link还可用时，secondary switch会将其所有的member port关闭。
* vPC primary switch failure：Secondary switch会变为可操作的primary switch，当原来的primary switch恢复之后，其又会变为secondary switch
* vPC keepalive link failure：其流量不会造成影响，但建议尽早修复
* vPC keepalive link and peer-link both failure：如果vPC keepalive link先down，然后peer-link跟着down，primary和secondary switch同时成为primary switch，即脑裂。现有流量不会造成影响，但新的流量就不可用。同时单播mac地址和IGMP组，因此其无法维持单播和组播的转发，还可能导致duplicate包。
