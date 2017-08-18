[TOCM]

[TOC]
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



* 其支持LACP active，passive以及ON mode
## Failure Scenarios
* vPC member port fails：下联设备会通过PortChannel感知到故障，会将流量切换到另一个接口上。这种情况下，vPC peer-link可能会承数据流量。
* vPC peer-link failure：当keepalive link还可用时，secondary switch会将其所有的member port关闭。
* vPC primary switch failure：Secondary switch会变为可操作的primary switch，当原来的primary switch恢复之后，其又会变为secondary switch
* vPC keepalive link failure：其流量不会造成影响，但建议尽早修复
* vPC keepalive link and peer-link both failure：如果vPC keepalive link先down，然后peer-link跟着down，primary和secondary switch同时成为primary switch，即脑裂。现有流量不会造成影响，但新的流量就不可用。同时单播mac地址和IGMP组，因此其无法维持单播和组播的转发，还可能导致duplicate包。
