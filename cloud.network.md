# 云网新技术

- 收敛比
- networkless, 网络的物理位置不再重要？
- 超融合：
    - 计算、存储融为一体
    - 网络不需太多变动
- ceph
    - 存储为一个池子

- 数据与计算的距离，引出边缘计算

- 小收敛比：leaf ： spine = 1：1 ~ 4：1

-l2mp 二层 fabric
    - trill/spb, fabric path, ...
    - 太过于复杂，mac地址表增大，需要芯片硬件支持
    - 忽略掉了vswitch的功能
    - 云时代需要效率，

- IP CLOS 三层Fabric
    - ECMP基于流量来进行，动态调整负载策略
    - openr, facebook
    - eBGP for MSDC(mega scale DC), rfc 7938, 便于定位问题，消除IGP
        - spine 规划为一个as， 每个leaf为一个as，
        - as使用四字节的as号
        - eGBP for server
        - path hunting的问题，收敛性差，举例矢量协议的弊端。
        - bgp vs. ECMP，
            - EBGP的multipath，需要as长度一样，as号也相同才是lb
            - multi path relex
        - 路由消失，邻居消失的发现时间较长
        - SPF-Based BGP or bgp based spf
            - lsvr： link state virtual routing: 把igp和bgp的特性揉在一起
            - fed tri
            - juniper: leaf 只有默认路由，spine，有明细路由，
            - bgp un-number? 使用IPv6的路，信道，来传递IPv4的路由

- underlay与集中式
    - 控制器负责拓扑发现与校验，自动刷配置
    - 集中式计算路径，下发路径，openflow思路
        - 时序问题，可能造成环路故障
        - 使用SR，使用单点接触，下发源路由
    - 控制器收取拓扑，下放全网拓扑给网络设备，设备自己计算路由
    - telemetry + TEDB
    - 控制器设计思路：base line 分布式；te, 集中式调优
    - 网关Underlay路由重分布

- NVo3（network virtual over layer 3）基础架构
    - https://www.sdnlab.com/15820.html
    - 在vxlan上加BFD功能
    - 开启隧道的点：
        - vswitch - vswitch：物理网络对overlay一无所知
        - leaf - leaf：降低网络中，隧道的数量
        - vswitch - leaf：虚拟机到物理机的方式
        - leaf - spine - leaf: vxlan的网关，spine作为leaf的代理，来进行二层转发
        - vswitch - spine：虚拟机要出访问外方，
        - switch - border leaf：同上
        - vswitch - border router：同上

- 虚拟路由器、交换机模型
    - vs， vr可能是一个软件的交换机，路由器，也可能是相关的组件

- 集中式、分布式的路由：
    - 判断流量模型，东西向和南北向流量，
        - 南北向流量多，集中式
        - 东西向流量多，使用分布式
            - 分布式路由，有可能会导致非对称路由
                - 加入中继路由，来避免非对称路由，有效节约arp表和mac地址表


- evpn
    - mp-ebgp
        - leaf - spine全互联
        - nexthop 不变
    - mp-ibgp
        - ibgp之间为full mesh邻居
        - 引入rr，让spine作为rr，border 作为rr，控制器作为rr
    - 需要multiple instance