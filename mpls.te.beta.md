## 5. MPLS TE
### 5.1 TE
* TE（Traffic Engineering，流量工程）由于IGP选择的均为代价最小、距离最近的路由，所以导致链路利用率极不均衡的问题。TE对现有网络流量合理的规划和引导，实现资源的优化配置和提升网络性能。
### 5.2 IP TE
其使用广泛，但是非常粗糙，主要方法：
1. 利用IGP协议，改变metric或者cost值，过滤路由，或者LSA的方法
2. 利用BGP丰富的路由策略。
* 其优点为简单，缺点为相互影响严重。

### 5.3 MPLS TE的必要条件
* 主要实现方式有：RSVP TE，CR LDP TE。这里只讨论RSVP TE
* 支持P2P的LSP流量tunnel，tunnel中的LSP是固定的，故，报文进入tunnel之后，只能从tunnel另一端出来。
* LSP tunnel的建立支持自动建立和手动建立；
* 根据不同的优先级进行隧道抢占；
* 支持预建立备份路径的功能；
* 支持隧道随着网络环境的变化而重优化；
* 支持LSP优先级隧道。

四大组件
信息发布、路径计算、信令组件、报文转发
FRR（Fast reRoute）、备份、宽带自动调整、路径的重优化

检查mpls te环境ok
show mpls traffic-eng topology brief
还可以查看标签




信息发布：

