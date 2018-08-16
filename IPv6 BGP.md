
# IPv6 BGP配置举例

- Key works: IPv6, BGP, Vxlan, ASR9K, Multihop, bgp neighbor not directly connected, BGP邻居非直连

## 需求以及分析

公司欲接入IPv6网络，准备使用BGP与运营商对接。但需要跨越公司的Site Network，其为IPv4网络。运营商和公司分别属于两个AS。
```
 +----------------------+
 |                      |
 |          ISP         |
 |           |          |
 |           |          |
 |     Site Network     |
 |           |          |
 |           |          |
 |      IPv6 Router     |
 |                      |
 +----------------------+
```
- 需求分析
    - 将Site Network部署为IPv4和IPv6的双栈网络，然后使用IPv6 Router和ISP建立Multihop的eBGP邻居关系
    - 在Site Network两端，建立由IPv4作为承载网络的VxLAN，再做ISP和IPv6路由器的eBGP

## Multihop eBGP

### 实验拓扑

```
 +---------------------------------------------------------------+
 |                                                               |
 |                R1(0/0)---(0/0)R2(0/1)---(0/1)R3               |
 |                                                               |
 +---------------------------------------------------------------+
```
- 网络设备说明
    - R1，R3为IPv6 BGP的两端，R2模拟Site Network
    - 环回口地址
        - IPv4: X.X.X.X/32
        - IPv6: X::X/128
    - 互联地址
        - IPv4: AB.1.1.A/24
        - IPv6: AB::A/64

### 配置举例

#### 基本配置

```
conf t
hostname R1
!
ip cef
ipv6 unicast-routing
ipv6 cef
!
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
 ipv6 address 1::1/128
 no shutdown
!
interface FastEthernet0/0
 ip address 12.1.1.1 255.255.255.0
 ipv6 address 12::1/64
 no shutdown
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
hostname R2
!
ip cef
ipv6 unicast-routing
ipv6 cef
!
interface Loopback0
 ip address 2.2.2.2 255.255.255.255
 ipv6 address 2::2/128
 no shutdown
!
interface FastEthernet0/0
 ip address 12.1.1.2 255.255.255.0
 ipv6 address 12::2/64
 no shutdown
!
interface FastEthernet0/1
 ip address 23.1.1.2 255.255.255.0
 ipv6 address 23::2/64
 no shutdown
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
hostname R3
!
ip cef
ipv6 unicast-routing
ipv6 cef
!
interface Loopback0
 ip address 3.3.3.3 255.255.255.255
 ipv6 address 3::3/128
 no shutdown
!
interface FastEthernet0/1
 ip address 23.1.1.3 255.255.255.0
 ipv6 address 23::3/64
 no shutdown
!
end
```

#### IPv4 Site Network配置

```
conf t
hostname R1
!
router eigrp 90
 no auto-summary
 network 0.0.0.0 0.0.0.0
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
hostname R2
!
router eigrp 90
 no auto-summary
 network 0.0.0.0 0.0.0.0
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
hostname R3
!
router eigrp 90
 no auto-summary
 network 0.0.0.0 0.0.0.0
!
end
```

#### IPv6 IGP配置

```
conf t
hostname R1
!
router ospfv3 110
 router-id 1.1.1.1
!
interface Loopback0
 ipv6 ospf 110 area 0
!
interface FastEthernet0/0
 ipv6 ospf 110 area 0
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
hostname R2
!
router ospfv3 110
 router-id 2.2.2.2
!
interface Loopback0
 ipv6 ospf 110 area 0
!
interface FastEthernet0/0
 ipv6 ospf 110 area 0
!
interface FastEthernet0/1
 ipv6 ospf 110 area 0
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
hostname R3
!
router ospfv3 110
 router-id 3.3.3.3
!
interface Loopback0
 ipv6 ospf 110 area 0
!
interface FastEthernet0/1
 ipv6 ospf 110 area 0
!
end
```

#### IPv6 Multihop BGP配置

```
conf t
hostname R1
!
router bgp 100
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 neighbor 23::3 remote-as 200
 neighbor 23::3 ebgp-multihop 5
 !
 address-family ipv6
  network 1::1/128
  neighbor 23::3 activate
 exit-address-family
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
hostname R3
!
router bgp 200
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 neighbor 12::1 remote-as 100
 neighbor 12::1 ebgp-multihop 5
 !
 address-family ipv6
  network 3::3/128
  neighbor 12::1 activate
 exit-address-family
!
end
```

### 相关状态

#### BGP 邻居关系

```
R1#show bgp ipv6 unicast summary 
BGP router identifier 1.1.1.1, local AS number 100
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
23::3           4          200       8       8        3    0    0 00:04:18        1

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

R3#sh bgp ipv6 unicast summary 
BGP router identifier 3.3.3.3, local AS number 200
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
12::1           4          100       9       9        3    0    0 00:04:37        1
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
 *>  1::1/128         ::                       0         32768 i
 *>  3::3/128         23::3                    0             0 200 i

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

R3#sh bgp ipv6 unicast         
BGP table version is 3, local router ID is 3.3.3.3
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal, 
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter, 
              x best-external, a additional-path, c RIB-compressed, 
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1::1/128         12::1                    0             0 100 i
 *>  3::3/128         ::                       0         32768 i
```

#### 路由表

```
R1#sh ipv6 route
IPv6 Routing Table - default - 7 entries
Codes: C - Connected, L - Local, B - BGP, O - OSPF Intra
LC  1::1/128 [0/0]
     via Loopback0, receive
O   2::2/128 [110/1]
     via FE80::C802:46FF:FEF0:8, FastEthernet0/0
B   3::3/128 [20/0]
     via 23::3
C   12::/64 [0/0]
     via FastEthernet0/0, directly connected
L   12::1/128 [0/0]
     via FastEthernet0/0, receive
O   23::/64 [110/2]
     via FE80::C802:46FF:FEF0:8, FastEthernet0/0
L   FF00::/8 [0/0]
     via Null0, receive

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

R2#sh ipv6 route
IPv6 Routing Table - default - 8 entries
Codes: C - Connected, L - Local, B - BGP, O - OSPF Intra
O   1::1/128 [110/1]
     via FE80::C801:47FF:FE8C:8, FastEthernet0/0
LC  2::2/128 [0/0]
     via Loopback0, receive
O   3::3/128 [110/1]
     via FE80::C803:22FF:FE30:6, FastEthernet0/1
C   12::/64 [0/0]
     via FastEthernet0/0, directly connected
L   12::2/128 [0/0]
     via FastEthernet0/0, receive
C   23::/64 [0/0]
     via FastEthernet0/1, directly connected
L   23::2/128 [0/0]
     via FastEthernet0/1, receive
L   FF00::/8 [0/0]
     via Null0, receive

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

R3#sh ipv6 route
IPv6 Routing Table - default - 7 entries
Codes: C - Connected, L - Local, B - BGP, O - OSPF Intra
B   1::1/128 [20/0]
     via 12::1
O   2::2/128 [110/1]
     via FE80::C802:46FF:FEF0:6, FastEthernet0/1
LC  3::3/128 [0/0]
     via Loopback0, receive
O   12::/64 [110/2]
     via FE80::C802:46FF:FEF0:6, FastEthernet0/1
C   23::/64 [0/0]
     via FastEthernet0/1, directly connected
L   23::3/128 [0/0]
     via FastEthernet0/1, receive
L   FF00::/8 [0/0]
     via Null0, receive
```

## IPv6 BGP over VxLAN

### 拓扑环境
```
 +------------------------------------+
 |                                    |
 |             Cisco-2901-1           |
 |                (g0/0)              |
 |                  |                 |
 |                  |                 |
 |               (g1/0/2)             |
 |              H3C-6800-1            |
 |               (g1/0/1)             |
 |                  |                 |
 |                  |                 |
 |             Site Network           |
 |                  |                 |
 |                  |                 |
 |               (g1/0/1)             |
 |              H3C-6800-2            |
 |                  |                 |
 |                  |                 |
 |              (g1/0/1)              |
 |                  |                 |
 |                  |                 |
 |                (g0/0)              |
 |             Cisco-2901-2           |
 |                                    |
 +------------------------------------+
```
