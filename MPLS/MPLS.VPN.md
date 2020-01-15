# MPLS VPN

## 1. 概念

- VRF（Virtual Routing Forwarding）, 一个VRF就是虚拟的路由器, 可以逻辑的隔离路由. 该例中, 一个VRF就是一个MPLS VPN中的实例（进程）, PE创建了VRF之后, 要与相应的端口进行关联. VRF只是本地有意义.
- RD, Route Distinguisher, 区分公司的的路由条目, RD只具有本地意义. 不同VRF的路由条目通过该属性区分, RT:IPv4(96 bit)路由为VPNv4路由, 可以使用MP BGP传递这种路由.
- RT, Route Target, BGP community属性中的一种扩展属性, PE路由器收到VPNv4路由之后, 会加上相应的RT之后, 通告给BGP邻居, 然后进行私网路由传递. 根据target的不同, 传递给不同的RD. 一条IPv4路由可以被添加多个RT.

## 2. 通信过程

- 拓扑如图所示, 其中R4, R5为A公司, R6, R7位B公司, 分别连接到R2和R3模拟的PE路由器的VRF A和VRF B. 两个PE路由器（R2和R3）建立VPNv4的MP-BGP邻接关系

```
 +-----------------------------------------------------------+
 | R4(0/0)----\                                 /----(0/0)R5 |
 |            (1/0)                          (1/0)           |
 |              R2(0/0)---(0/0)R1(0/1)---(0/1)R3             |
 |            (1/1)                          (1/1)           |
 | R6(0/0)----/                                 \----(0/0)R7 |
 +-----------------------------------------------------------+
```

### 2.1 控制层面

- 标签传递
    1. 运营商内部已经建立了MPLS域, 并且R2和R3已经建立了VPNv4的MP-BGP邻接关系;
    2. LDP为每条为默认VRF的可达路由分发标签;
    3. MP-BGP为每个VRF中的可达路由分发标签;

- 路由传递
    - 1. 公司A的R4通告了一条路由, R2通过IGB学习到该路由条目, 并且加入到R2的VRF A路由表中;
    - 2. R2会将该路由条目, 并且加入A的RD信息, 发送给其VPNv4的MP-BGP邻居R3, 转发过程中, 更新会打上由LDP分发的, 关于R3更新源地址的标签发给R1;
    - 3. R1收到报文后, 由于其为倒数第二条路由器, 会弹出标签, 将报文转发给R3;
    - 4. R3收到该路由之后, 根据其RT信息, 加入VRF A的路由表中, 下一跳为R2的更新源地址. 由于其和R5运行了IGP, 将路由通告给R5.

### 2.2 数据层面

- R5的环回口想要访问R4的环回口
    - 1. R5先查询其路由表, 将数据发送给R3;
    - 2. R3收到该报文之后, 打上到关于VRF A所对应的标签, 由于其要将报文发送给R2的更新源地址, 所以会将报文再打上R1发送给R3的, 关于到达R2更新源地址的标签, 发送给R1;
    - 3. R1由于是倒数第二条路由器, 会将外层标签弹出后转发给R2;
    - 4. R2收到该报文之后, 由于其带有关于VRF A的标签, 将标签弹出之后, 会查询VRF A的路由表, 将报文发送给R4.

## 3. MPLS VPN配置实例

### topology

```
 +-----------------------------------------------------------+
 | R4(0/0)----\                                 /----(0/0)R5 |
 |            (1/0)                          (1/0)           |
 |              R2(0/0)---(0/0)R1(0/1)---(0/1)R3             |
 |            (1/1)                          (1/1)           |
 | R6(0/0)----/                                 \----(0/0)R7 |
 +-----------------------------------------------------------+
```

### ip routing

```
R1:
interface Loopback0
 ip address 1.1.1.1 255.255.255.0
 no shutdown
interface FastEthernet0/0
 ip address 12.1.1.1 255.255.255.0
 no shutdown
interface FastEthernet0/1
 ip address 13.1.1.1 255.255.255.0
 no shutdown
router rip
 version 2
 network 0.0.0.0
 no auto-summary

R2:
interface Loopback0
 ip address 2.2.2.2 255.255.255.0
 no shutdown
interface FastEthernet0/0
 ip address 12.1.1.2 255.255.255.0
 no shutdown
router rip
 version 2
 network 2.0.0.0
 network 12.0.0.0
 no auto-summary

R3:
interface Loopback0
 ip address 3.3.3.3 255.255.255.0
 no shutdown
interface FastEthernet0/1
 ip address 13.1.1.3 255.255.255.0
 no shutdown
router rip
 version 2
 network 3.0.0.0
 network 13.0.0.0
 no auto-summary

R4:
interface Loopback0
 ip address 4.4.4.4 255.255.255.0
 no shutdown
interface FastEthernet0/0
 ip address 24.1.1.4 255.255.255.0
 no shutdown

R5:
interface Loopback0
 ip address 5.5.5.5 255.255.255.0
 no shutdown
interface FastEthernet0/0
 ip address 35.1.1.5 255.255.255.0
 no shutdown

R6:
interface Loopback0
 ip address 6.6.6.6 255.255.255.0
 no shutdown
interface FastEthernet0/0
 ip address 26.1.1.6 255.255.255.0
 no shutdown

R7:
interface Loopback0
 ip address 7.7.7.7 255.255.255.0
 no shutdown
interface FastEthernet0/0
 ip address 37.1.1.7 255.255.255.0
 no shutdown
```

### mpls

```
R1:
interface range FastEthernet 0/0-1
 mpls ip

R2:
interface FastEthernet 0/0
 mpls ip

R3:
interface FastEthernet 0/1
 mpls ip

sh mpls ldp nei
sh mpls ldp binding
sh mpls forwarding-table
```

### vrf

```
R2:
ip vrf A
 rd 10:10
 route-target export 10:10
 route-target import 10:10
ip vrf B
 rd 20:20
 route-target export 20:20
 route-target import 20:20
interface FastEthernet1/0
 ip vrf forwarding A
 ip address 24.1.1.2 255.255.255.0
 no shutdown
int fa1/1
 ip vrf forwarding B
 ip add 26.1.1.2 255.255.255.0
 no shutdown

R3:
ip vrf A
 rd 10:10
 route-target export 10:10
 route-target import 10:10
ip vrf B
 rd 20:20
 route-target export 20:20
 route-target import 20:20
interface FastEthernet1/0
 ip vrf forwarding A
 ip address 35.1.1.3 255.255.255.0
 no shutdown
interface FastEthernet1/1
 ip vrf forwarding B
 ip address 37.1.1.3 255.255.255.0
 no shutdown
```

### bgp

```
R2:
router bgp 1
 bgp router-id 2.2.2.2
 no bgp default ipv4-unicast
 neighbor 3.3.3.3 remote-as 1
 neighbor 3.3.3.3 update-source Loopback0
 address-family vpnv4
  neighbor 3.3.3.3 activate
  neighbor 3.3.3.3 send-community both

R3:
router bgp 1
 bgp router-id 3.3.3.3
 no bgp default ipv4-unicast
 neighbor 2.2.2.2 remote-as 1
 neighbor 2.2.2.2 update-source Loopback0
 address-family vpnv4
  neighbor 2.2.2.2 activate
  neighbor 2.2.2.2 send-community both

sh ip bgp all summary
```

### inner igp

```
R2:
router ospf 110 vrf A
 router-id 2.2.2.2
 redistribute bgp 1 subnets
 network 24.1.1.2 0.0.0.0 area 0
router eigrp 3000
 address-family ipv4 vrf B autonomous-system 90
  redistribute bgp 1 metric 10000 100 255 1 1500
  network 26.1.1.2 0.0.0.0
router bgp 1
 address-family ipv4 vrf A
  redistribute ospf 110 match internal external 1 external 2
 address-family ipv4 vrf B
  redistribute eigrp 90 metric 10

R3:
router rip
 address-family ipv4 vrf A
  redistribute bgp 1 metric transparent
  network 35.0.0.0
  no auto-summary
router ospf 110 vrf B
 router-id 3.3.3.3
 redistribute bgp 1 subnets
 network 37.1.1.3 0.0.0.0 area 0
router bgp 1
 address-family ipv4 vrf A
  redistribute rip metric 10
 address-family ipv4 vrf B
  redistribute ospf 110 match internal external 1 external 2

R4:
router ospf 110
 router-id 4.4.4.4
 network 0.0.0.0 255.255.255.255 area 0

R5:
router rip
 version 2
 network 0.0.0.0
 no auto-summary

R6:
router eigrp 90
 network 0.0.0.0

R7:
router ospf 110
 router-id 7.7.7.7
 network 0.0.0.0 255.255.255.255 area 0
```
