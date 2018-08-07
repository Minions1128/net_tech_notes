# IPv6 BGP配置举例
IPv6, bgp neighbor not directly connected
## 拓扑环境
```
 +---------------------------------------------------------------+
 |                                                               |
 |                R1(0/0)---(0/0)R2(0/1)---(0/1)R3               |
 |                                                               |
 +---------------------------------------------------------------+
```
- 每台路由器的地址规划
    - 环回口地址
        - IPv4: X.X.X.X/32
        - IPv6: FEC0:X::X/128
    - 互联地址
        - IPv4: AB.1.1.A/24
        - IPv6: FEC0:AB::A/64
## 配置举例
### R1
```
hostname R1
!
ip cef
ipv6 unicast-routing
ipv6 cef
!
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
 ipv6 address FEC0:1::1/128
!
interface FastEthernet0/0
 ip address 12.1.1.1 255.255.255.0
 ipv6 address FEC0:12::1/64
 ipv6 ospf 1 area 0
!
!
router eigrp 90
 network 12.1.1.1 0.0.0.0
!
router ospfv3 1
 router-id 1.1.1.1
 address-family ipv6 unicast
 exit-address-family
!
router bgp 1
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 neighbor FEC0:23::3 remote-as 3
 neighbor FEC0:23::3 ebgp-multihop 5
 !
 address-family ipv6
  network FEC0:1::1/128
  neighbor FEC0:23::3 activate
 exit-address-family
!
end
```
### R2
```
hostname R2
!
ip cef
ipv6 unicast-routing
ipv6 cef
!
interface Loopback0
 ip address 2.2.2.2 255.255.255.255
 ipv6 address FEC0:2::2/128
 ipv6 ospf 1 area 0
!
interface FastEthernet0/0
 ip address 12.1.1.2 255.255.255.0
 ipv6 address FEC0:12::2/64
 ipv6 ospf 1 area 0
!
interface FastEthernet0/1
 ip address 23.1.1.2 255.255.255.0
 ipv6 address FEC0:23::2/64
 ipv6 ospf 1 area 0
!
router eigrp 90
 network 0.0.0.0
!
router ospfv3 1
 router-id 2.2.2.2
 address-family ipv6 unicast
 exit-address-family
!
end
```
### R3
```
hostname R3
!
ip cef
ipv6 unicast-routing
ipv6 cef
!
interface Loopback0
 ip address 3.3.3.3 255.255.255.255
 ipv6 address FEC0:3::3/128
!
interface FastEthernet0/1
 ip address 23.1.1.3 255.255.255.0
 duplex auto
 speed auto
 ipv6 address FEC0:23::3/64
 ipv6 ospf 1 area 0
!
router eigrp 90
 network 23.1.1.3 0.0.0.0
!
router ospfv3 1
 router-id 3.3.3.3
 address-family ipv6 unicast
 exit-address-family
!
router bgp 3
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 neighbor FEC0:12::1 remote-as 1
 neighbor FEC0:12::1 ebgp-multihop 5
 !
 address-family ipv4
 exit-address-family
 !
 address-family ipv6
  network FEC0:3::3/128
  neighbor FEC0:12::1 activate
 exit-address-family
!
end
```
## 相关状态
### R1
#### BGP 邻居关系
```
R1#show bgp ipv6 unicast summary 
BGP router identifier 1.1.1.1, local AS number 1
BGP table version is 3, main routing table version 3
2 network entries using 344 bytes of memory
2 path entries using 176 bytes of memory
2/2 BGP path/bestpath attribute entries using 272 bytes of memory
1 BGP AS-PATH entries using 24 bytes of memory
0 BGP route-map cache entries using 0 bytes of memory
0 BGP filter-list cache entries using 0 bytes of memory
BGP using 816 total bytes of memory
BGP activity 2/0 prefixes, 2/0 paths, scan interval 60 secs

Neighbor        V           AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
FEC0:23::3      4            3      51      52        3    0    0 00:43:50        1
```
#### BGP路由条目
```
R1#show bgp ipv6 unicast         
BGP table version is 3, local router ID is 1.1.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  FEC0:1::1/128    ::                       0         32768 i
 *>  FEC0:3::3/128    FEC0:23::3               0             0 3 i
```
#### 路由表
```
R1#show ip route 
      1.0.0.0/32 is subnetted, 1 subnets
C        1.1.1.1 is directly connected, Loopback0
      2.0.0.0/32 is subnetted, 1 subnets
D        2.2.2.2 [90/156160] via 12.1.1.2, 00:47:17, FastEthernet0/0
      12.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        12.1.1.0/24 is directly connected, FastEthernet0/0
L        12.1.1.1/32 is directly connected, FastEthernet0/0
      23.0.0.0/24 is subnetted, 1 subnets
D        23.1.1.0 [90/30720] via 12.1.1.2, 00:47:17, FastEthernet0/0
R1#
R1#show ipv6 route
IPv6 Routing Table - default - 7 entries
LC  FEC0:1::1/128 [0/0]
     via Loopback0, receive
O   FEC0:2::2/128 [110/1]
     via FE80::C802:3FFF:FEA0:8, FastEthernet0/0
B   FEC0:3::3/128 [20/0]
     via FEC0:23::3
C   FEC0:12::/64 [0/0]
     via FastEthernet0/0, directly connected
L   FEC0:12::1/128 [0/0]
     via FastEthernet0/0, receive
O   FEC0:23::/64 [110/2]
     via FE80::C802:3FFF:FEA0:8, FastEthernet0/0
L   FF00::/8 [0/0]
     via Null0, receive
```
### R2
#### 路由表
```
R2#show ip route 
      2.0.0.0/32 is subnetted, 1 subnets
C        2.2.2.2 is directly connected, Loopback0
      12.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        12.1.1.0/24 is directly connected, FastEthernet0/0
L        12.1.1.2/32 is directly connected, FastEthernet0/0
      23.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        23.1.1.0/24 is directly connected, FastEthernet0/1
L        23.1.1.2/32 is directly connected, FastEthernet0/1
R2#
R2#show ipv6 route
IPv6 Routing Table - default - 6 entries
LC  FEC0:2::2/128 [0/0]
     via Loopback0, receive
C   FEC0:12::/64 [0/0]
     via FastEthernet0/0, directly connected
L   FEC0:12::2/128 [0/0]
     via FastEthernet0/0, receive
C   FEC0:23::/64 [0/0]
     via FastEthernet0/1, directly connected
L   FEC0:23::2/128 [0/0]
     via FastEthernet0/1, receive
L   FF00::/8 [0/0]
     via Null0, receive
```
### R3
#### BGP 邻居关系
```
R3#show bgp ipv6 unicast summary 
BGP router identifier 3.3.3.3, local AS number 3
BGP table version is 3, main routing table version 3
2 network entries using 344 bytes of memory
2 path entries using 176 bytes of memory
2/2 BGP path/bestpath attribute entries using 272 bytes of memory
1 BGP AS-PATH entries using 24 bytes of memory
0 BGP route-map cache entries using 0 bytes of memory
0 BGP filter-list cache entries using 0 bytes of memory
BGP using 816 total bytes of memory
BGP activity 2/0 prefixes, 2/0 paths, scan interval 60 secs

Neighbor        V           AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
FEC0:12::1      4            1      52      52        3    0    0 00:44:18        1
```
#### BGP路由条目
```
R3#show bgp ipv6 unicast         
BGP table version is 3, local router ID is 3.3.3.3
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  FEC0:1::1/128    FEC0:12::1               0             0 1 i
 *>  FEC0:3::3/128    ::                       0         32768 i
```
#### 路由表
```
R3#show ip route 
      2.0.0.0/32 is subnetted, 1 subnets
D        2.2.2.2 [90/156160] via 23.1.1.2, 00:48:39, FastEthernet0/1
      3.0.0.0/32 is subnetted, 1 subnets
C        3.3.3.3 is directly connected, Loopback0
      12.0.0.0/24 is subnetted, 1 subnets
D        12.1.1.0 [90/30720] via 23.1.1.2, 00:48:39, FastEthernet0/1
      23.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        23.1.1.0/24 is directly connected, FastEthernet0/1
L        23.1.1.3/32 is directly connected, FastEthernet0/1
R3#
R3#show ipv6 route
IPv6 Routing Table - default - 7 entries
B   FEC0:1::1/128 [20/0]
     via FEC0:12::1
O   FEC0:2::2/128 [110/1]
     via FE80::C802:3FFF:FEA0:6, FastEthernet0/1
LC  FEC0:3::3/128 [0/0]
     via Loopback0, receive
O   FEC0:12::/64 [110/2]
     via FE80::C802:3FFF:FEA0:6, FastEthernet0/1
C   FEC0:23::/64 [0/0]
     via FastEthernet0/1, directly connected
L   FEC0:23::3/128 [0/0]
     via FastEthernet0/1, receive
L   FF00::/8 [0/0]
     via Null0, receive
```
