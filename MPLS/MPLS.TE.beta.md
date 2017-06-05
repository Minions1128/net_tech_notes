# MPLS TE
## 1. TE
TE（Traffic Engineering，流量工程）由于IGP选择的均为代价最小、距离最近的路由，所以导致链路利用率极不均衡的问题。TE对现有网络流量合理的规划和引导，实现资源的优化配置和提升网络性能。
## 2. IP TE
* 其使用广泛，但是非常粗糙，主要方法：
1. 利用IGP协议，改变metric或者cost值，过滤路由，或者LSA的方法
2. 利用BGP丰富的路由策略。
* 其优点为简单，缺点为相互影响严重。
## 3. MPLS TE概述
* 主要实现方式有：RSVP（Resource Reservation Protocol，资源预留协议）TE，CR LDP（Constraint-based Routing Label Distribution Protocol，基于路由受限标签分发协议）TE。这里只讨论RSVP TE。
* 必要条件
1. 支持P2P的LSP流量tunnel，tunnel中的LSP是固定的，故，报文进入tunnel之后，只能从tunnel另一端出来。
2. LSP tunnel的建立支持自动建立和手动建立；
3. 根据不同的优先级进行隧道抢占；
4. 支持预建立备份路径的功能；
5. 支持隧道随着网络环境的变化而重优化；
5. 支持LSP优先级隧道。
* 四大基本组件：信息发布、路径计算、信令、报文转发组件
* 扩展组件：FRR（Fast reRoute）、隧道的备份、宽带自动调整、路径的重优化

![mpls.te.implement.framework](https://github.com/Minions1128/net_tech_notes/blob/master/img/mpls.te.implementation.frameworks.jpg "mpls.te.implement.framework")

## 4. 简单配置步骤
1. 配置接口IP地址，OSPF或者ISIS协议
2. 全局下配置
```
ip cef
mpls traffic-eng tunnels
```
3. 接口下
```
mpls traffic-eng tunnels
ip rsvp bandwidth
```
3. 在OSPF或者ISIS中
```
mpls traffic-eng router-id Loopback0
mpls traffic-eng area 0
```
4. 在tunnel两端配置tunnel接口
```
interface Tunnel0
 ip unnumbered Loopback0
 tunnel mode mpls traffic-eng
 tunnel destination 5.5.5.5
 tunnel mpls traffic-eng bandwidth 1000
 tunnel mpls traffic-eng path-option 10 dynamic
```
5. 检查mpls te环境
```
show ip rsvp interface
show mpls traffic-eng topology [brief]
show mpls traffic-eng tunnel tun 0
show mpls traffic-eng link-management bandwidth-allocation  !可以查看到通告阈值
show mpls traffic-eng link-management summary               !查看其泛洪周期
```
6. 其他命令
```
R1(config-if)# mpls traffic-eng administrative-weight 5             !修改管理权重
R1(config)# mpls traffic-eng path-selection metric { igp | te }     !选择te metric的方式
R1(config-if)# tunnel mpls traffic-eng priority 1 1                 !修改tunnel优先级
R1(config-if)# mpls traffic-eng attribute-flags 0x5                 !修改物理接口亲和属性
R1(config-if)# tunnel mpls traffic-eng affinity 0x0 mask 0x0        !tunnel配置亲和属性匹配值
R1# mpls traffic-eng reoptimize                                     !软重置tunnel

R1(config-if)# mpls traffic-eng flooding thresholds { up | down } 15 30 45 60 75 80 85 90 95 96 97 98 99 100
    !修改接口泛洪阈值
R1(config)# mpls traffic-eng link-management timers periodic-flooding 888 !修改周期泛洪时间
```
## 5. 信息发布
### 5.1 发布内容
1. 链路状态信息，IGP会自动生成
2. TE Metric：在选择最优路径时，需要从metric值最小的路径进行选择，即路由最优。默认状态下和IGP的值相等。可以使用igp作为其metric。
3. 可用带宽：默认为bandwidth的75%，流量需要带宽超过之后，该流量会被排除在外。在tunnel口上配置。
4. 隧道优先级：有0-7，8个级别，值越小优先级越高。其有2种类型，建立优先级（抢占）和保持优先级（守护）。
5. 亲和属性：在选择路径时，接口匹配其亲和属性才有资格选择。默认为0x0/0xffff，意为完全匹配0x0。
### 5.2 发布时间
1. 周期性泛洪，默认180s
2. 拓扑变更
3. cost变更
4. 链路带宽发生重大变化，
5. LSP建立失败时
### 5.3 如何发布
依靠现有链路状态协议OSPF和ISIS的扩展LSA，满足MPLS TE需求，默认仅支持单区域tunnel。使用区间隧道可以实现多区域运行MPLS TE。
1. OSPF
* 增加了Type 10的LSA，其TLV有2种：
* type=1，路由器地址TLV，包含了MPLS TE的RID；
* type=2，链路TLV，有9种不同的子TLV组成，描述链路的各种参数。
* 9种链路子TLV：链路类型、链路ID、本地接口IP、远端接口地址、TE Metric、最大链路带宽、最大可保留带宽、当前可用带宽（基于每个优先级）、链路属性标志 。
2. ISIS
* 扩展了2中TLV：type=135，wide metric的扩展可达性路由信息；type=22，IS可达性TLV
