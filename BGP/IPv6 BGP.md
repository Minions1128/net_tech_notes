
# IPv6 BGP配置举例

- Key works: IPv6, BGP, Vxlan, ASR9K, Multihop, bgp neighbor not directly connected, BGP邻居非直连

## 需求以及分析

公司欲接入IPv6网络，准备使用BGP与运营商对接。但需要跨越公司的Site Network，其为IPv4网络。运营商和公司分别属于两个AS。
```
 +------------------------------------------+
 |                                          |
 |     ISP---Site Network---IPv6 Router     |
 |                                          |
 +------------------------------------------+
```
- 需求分析
    - 在Site Network两端，建立由IPv4作为承载网络的VxLAN，再做ISP和IPv6路由器的eBGP
    - 将Site Network部署为IPv4和IPv6的双栈网络，然后使用IPv6 Router和ISP建立Multihop的eBGP邻居关系

## IPv6 BGP over VxLAN

### 实验拓扑

```
 +--------------------------------------+
 |                                      |
 |             Cisco-2901-1             |
 |                (g0/0)                |
 |                   |                  |
 |                   |                  |
 |               (g1/0/2)               |
 |              H3C-6800-2              |
 |               (g1/0/1)               |
 |                   |                  |
 |                   |                  |
 |               (g1/0/1)               |
 |             Site Network             |
 |               (g1/0/2)               |
 |                   |                  |
 |                   |                  |
 |               (g1/0/1)               |
 |              H3C-6800-4              |
 |                   |                  |
 |           +---------------+          |
 |       (g1/0/2)        (g1/0/3)       |
 |           |               |          |
 |           |               |          |
 |        (g0/0)        (Te0/0/0/0)     |
 |     Cisco-2901-5       ASR 9K        |
 |                                      |
 +--------------------------------------+
```
- 拓扑说明
    - 为了测试VxLAN透传多个VLAN的能力，同时满足测试ASR 9K的需求，实验使用Cisco-2901-1分别和Cisco-2901-5和ASR 9K建立eBGP邻居
    - Cisco-2901-1为AS 100，Cisco-2901-5为AS 500，ASR 9K为AS 600
- 两台H3C-6800建立VxLAN的Tunnel
- Site Network为内网设备

### 配置举例

#### IPv4基本配置

```
system-view
#
 sysname H3C-6800-2
#
interface LoopBack0
 ip address 2.2.2.2 255.255.255.255
#
interface Ten-GigabitEthernet1/0/1
 port link-mode route
 ip address 23.1.1.2 255.255.255.0
#
router id 2.2.2.2
#
ospf 1
 area 0.0.0.0
  network 2.2.2.2 0.0.0.0
  network 23.1.1.2 0.0.0.0
#
return

##################################################

system-view
#
 sysname Site_Network
#
interface LoopBack0
 ip address 3.3.3.3 255.255.255.255
#
interface Ten-GigabitEthernet1/0/1
 port link-mode route
 ip address 23.1.1.3 255.255.255.0
#
interface Ten-GigabitEthernet1/0/2
 port link-mode route
 ip address 34.1.1.3 255.255.255.0
#
router id 3.3.3.3
#
ospf 1
 area 0.0.0.0
  network 3.3.3.3 0.0.0.0
  network 23.1.1.3 0.0.0.0
  network 34.1.1.3 0.0.0.0
#
return

##################################################

system-view
#
 sysname H3C-6800-4
#
interface LoopBack0
 ip address 4.4.4.4 255.255.255.255
#
interface Ten-GigabitEthernet1/0/1
 port link-mode route
 ip address 34.1.1.4 255.255.255.0
#
router id 4.4.4.4
#
ospf 1
 area 0.0.0.0
  network 4.4.4.4 0.0.0.0
  network 34.1.1.4 0.0.0.0
#
return
```

#### VxLAN的建立

- 我们要建立两对BGP的邻居，用来测试IOS路由器之间，IOS和IOS XR路由器之间建立BGP邻居关系的方法。所以这里VxLAN里要透传两个VLAN，VLAN 500为IOS路由器之间的对接，VLAN 600为IOS XR与IOS之间的对接。
```
system-view
#
 sysname H3C-6800-2
#
interface Tunnel1 mode vxlan
 source 2.2.2.2
 destination 4.4.4.4
vlan 500
 description VLAN500
#
vlan 600
 description VLAN600
#
 l2vpn enable
#
vsi vpna
 vxlan 50
  tunnel 1
#
vsi vpnb
 vxlan 60
  tunnel 1
#
interface Ten-GigabitEthernet1/0/2
 port link-mode bridge
 port link-type trunk
 undo port trunk permit vlan 1
 port trunk permit vlan 500 600
 service-instance 1000
  encapsulation s-vid 500
  xconnect vsi vpna
 service-instance 2000
  encapsulation s-vid 600
  xconnect vsi vpnb
#
return

##################################################

system-view
#
 sysname H3C-6800-4
#
interface Tunnel1 mode vxlan
 source 4.4.4.4
 destination 2.2.2.2
vlan 500
 description VLAN500
#
vlan 600
 description VLAN600
#
 l2vpn enable
#
vsi vpna
 vxlan 50
  tunnel 1
#
vsi vpnb
 vxlan 60
  tunnel 1
#
interface Ten-GigabitEthernet1/0/2
 port link-mode bridge
 port access vlan 500
 service-instance 1000
  encapsulation s-vid 500
  xconnect vsi vpna
#
interface Ten-GigabitEthernet1/0/3
 port link-mode bridge
 port access vlan 600
 service-instance 2000
  encapsulation s-vid 600
  xconnect vsi vpnb
#
return
```
- 这样H3C-6800-2的Te1/0/2口可以透传两个VLAN，分别对接H3C-6800-4的Te1/0/2和Te1/0/3口

#### Cisco IOS IPv6 BGP的建立

- 我们先配置VLAN 600的BGP邻居
```
conf t
hostname Cisco-2901-1
！
interface Loopback0
 ipv6 address 1::1/128
!
interface GigabitEthernet0/1
 no shutdown
!
interface GigabitEthernet0/1.500
 encapsulation dot1Q 500
 ipv6 address 15::1/64
!
router bgp 100
 bgp router-id 1.1.1.1
 bgp log-neighbor-changes
 no bgp default ipv4-unicast
 neighbor 15::5 remote-as 500
 !
 address-family ipv6
  network 1::1/128
  neighbor 15::5 activate
 exit-address-family
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
hostname Cisco-2901-5
!
interface Loopback0
 ipv6 address 5::5/128
!
interface GigabitEthernet0/1
 no shutdown
!
interface GigabitEthernet0/1.600
 encapsulation dot1Q 600
 ipv6 address 15::5/64
!
router bgp 500
 bgp router-id 5.5.5.5
 no bgp default ipv4-unicast
 neighbor 15::1 remote-as 100
 !
 address-family ipv6
  network 5::5/128
  neighbor 15::1 activate
 exit-address-family
```

#### Cisco IOS和IOS XR建立IPv6 BGP


```
conf t
hostname Cisco-2901-1
!
interface GigabitEthernet0/1.600
 encapsulation dot1Q 600
 ipv6 address 16::1/64
!
router bgp 100
 neighbor 16::6 remote-as 600
 !
 address-family ipv6
  neighbor 16::6 activate
 exit-address-family
!
end

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

conf t
interface Loopback0
 ipv6 address 6::6/128
!
interface TenGigE0/0/0/0
 no shutdown
!
interface TenGigE0/0/0/0.600
 ipv6 address 16::6/64
 encapsulation dot1q 600
!
route-policy set_1_in_to_1
  set next-hop 16::1
  ! 设置收到的路由，下一跳指向对端
end-policy
!
route-policy set_6_out_to_6
  set next-hop 16::6
  ! 设置发出的路由，下一跳指向本地对端
  ! 言外之意，可以发出下一跳不指向本地的路由？
end-policy
!
router bgp 600
 bgp router-id 6.6.6.6
 address-family ipv6 unicast
  network 6::6/128
 !
 neighbor 16::1
  remote-as 100
  address-family ipv6 unicast
   route-policy set_1_in_to_1 in
   route-policy set_6_out_to_6 out
  !
 !
!
end
```

### 相关状态

#### VxLAN Tunnel状态

```
<H3C-6800-2>display interface Tunnel 1
Tunnel1
Current state: UP
Line protocol state: UP
Description: Tunnel1 Interface
Bandwidth: 64 kbps
Maximum transmission unit: 1464
Internet protocol processing: Disabled
Last clearing of counters: Never
Tunnel source 2.2.2.2 (LoopBack0), destination 4.4.4.4
Tunnel protocol/transport UDP_VXLAN/IP

##################################################

<H3C-6800-4>display interface Tunnel 1
Tunnel1
Current state: UP
Line protocol state: UP
Description: Tunnel1 Interface
Bandwidth: 64 kbps
Maximum transmission unit: 1464
Internet protocol processing: Disabled
Last clearing of counters: Never
Tunnel source 4.4.4.4 (LoopBack0), destination 2.2.2.2
Tunnel protocol/transport UDP_VXLAN/IP
```

#### VxLAN的MAC地址表

```
<H3C-6800-2>display l2vpn mac-address
MAC Address    State    VSI Name                        Link ID/Name    Aging
4c4e-35cf-ae31 Dynamic  vpna                            Tunnel1         Aging
4c4e-35e9-8309 Dynamic  vpna                            XGE1/0/2        Aging
4c4e-35e9-8309 Dynamic  vpnb                            XGE1/0/2        Aging
d46d-500d-d298 Dynamic  vpnb                            Tunnel1         Aging

##################################################

<H3C-6800-4>display l2vpn mac-address
MAC Address    State    VSI Name                        Link ID/Name    Aging
4c4e-35cf-ae31 Dynamic  vpna                            XGE1/0/2        Aging
4c4e-35e9-8309 Dynamic  vpna                            Tunnel1         Aging
4c4e-35e9-8309 Dynamic  vpnb                            Tunnel1         Aging
d46d-500d-d298 Dynamic  vpnb                            XGE1/0/3        Aging
```

#### BGP 邻居关系

```
Cisco-2901-1#show bgp ipv6 unicast summary
BGP router identifier 1.1.1.1, local AS number 100
BGP table version is 6, main routing table version 6
3 network entries using 516 bytes of memory
3 path entries using 264 bytes of memory
3/3 BGP path/bestpath attribute entries using 408 bytes of memory
2 BGP AS-PATH entries using 48 bytes of memory
0 BGP route-map cache entries using 0 bytes of memory
0 BGP filter-list cache entries using 0 bytes of memory
BGP using 1236 total bytes of memory
BGP activity 19/16 prefixes, 27/24 paths, scan interval 60 secs

Neighbor  V           AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
15::5     4          500    4392    4403        6    0    0 2d18h           1
16::6     4          600    3982    4380        6    0    0 2d18h           1

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Cisco-2901-5#sh bgp ipv6 unicast summary
BGP router identifier 5.5.5.5, local AS number 500
BGP table version is 10, main routing table version 10
3 network entries using 516 bytes of memory
3 path entries using 264 bytes of memory
3/3 BGP path/bestpath attribute entries using 408 bytes of memory
2 BGP AS-PATH entries using 48 bytes of memory
0 BGP route-map cache entries using 0 bytes of memory
0 BGP filter-list cache entries using 0 bytes of memory
BGP using 1236 total bytes of memory
BGP activity 31/28 prefixes, 40/37 paths, scan interval 60 secs

Neighbor  V           AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
15::1     4          100    4406    4394       10    0    0 2d18h           2

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

RP/0/RSP0/CPU0:ASR-9K#show bgp ipv6 unicast summary
Thu Aug 16 01:41:38.159 UTC
BGP router identifier 6.6.6.6, local AS number 600
BGP generic scan interval 60 secs
BGP table state: Active
Table ID: 0xe0800000   RD version: 11
BGP main routing table version 11
BGP scan interval 60 secs

BGP is operating in STANDALONE mode.


Process       RcvTblVer   bRIB/RIB   LabelVer  ImportVer  SendTblVer  StandbyVer
Speaker              11         11         11         11          11          11

Neighbor        Spk    AS MsgRcvd MsgSent   TblVer  InQ OutQ  Up/Down  St/PfxRcd
16::1             0   100    4384    3986       11    0    0    2d18h          2
```

#### BGP路由条目

```
Cisco-2901-1#show bgp ipv6 unicast
BGP table version is 6, local router ID is 1.1.1.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter,
              x best-external, a additional-path, c RIB-compressed,
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network     Next Hop            Metric LocPrf Weight Path
 *>  1::1/128    ::                       0         32768 i
 *>  5::5/128    15::5                    0             0 200 i
 *>  6::6/128    16::6                    0             0 300 i

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Cisco-2901-5#sh bgp ipv6 unicast
BGP table version is 10, local router ID is 5.5.5.5
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter,
              x best-external, a additional-path, c RIB-compressed,
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1::1/128         15::1                    0             0 100 i
 *>  5::5/128         ::                       0         32768 i
 *>  6::6/128         15::1                                  0 100 300 i

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

RP/0/RSP0/CPU0:ASR-9K#show bgp ipv6 unicast
Thu Aug 16 01:42:54.887 UTC
BGP router identifier 6.6.6.6, local AS number 600
BGP generic scan interval 60 secs
BGP table state: Active
Table ID: 0xe0800000   RD version: 11
BGP main routing table version 11
BGP scan interval 60 secs

Status codes: s suppressed, d damped, h history, * valid, > best
              i - internal, r RIB-failure, S stale, N Nexthop-discard
Origin codes: i - IGP, e - EGP, ? - incomplete
   Network            Next Hop            Metric LocPrf Weight Path
*> 1::1/128           16::1                    0             0 100 i
*> 5::5/128           16::1                                  0 100 200 i
*> 6::6/128           ::                       0         32768 i
```

#### 路由表

```
Cisco-2901-1#show ipv6 route bgp
B   5::5/128 [20/0]
     via FE80::4E4E:35FF:FECF:AE31, GigabitEthernet0/1.500
B   6::6/128 [20/0]
     via FE80::D66D:50FF:FE0D:D298, GigabitEthernet0/1.600

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Cisco-2901-5#show ipv6 route bgp
IPv6 Routing Table - default - 12 entries
B   1::1/128 [20/0]
     via FE80::4E4E:35FF:FEE9:8309, GigabitEthernet0/1.500
B   6::6/128 [20/0]
     via FE80::4E4E:35FF:FEE9:8309, GigabitEthernet0/1.500

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

RP/0/RSP0/CPU0:ASR-9K#show route ipv6 bgp
Thu Aug 16 01:52:25.134 UTC

B    1::1/128
      [20/0] via 16::1, 2d18h
B    5::5/128
      [20/0] via 16::1, 2d18h
```

## Multihop eBGP

### 实验拓扑

```
 +------------------------------------------+
 |                                          |
 |     R1(0/0)---(0/0)R2(0/1)---(0/1)R3     |
 |                                          |
 +------------------------------------------+
```
- 拓扑说明
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

- 这里将所有接口划入eigrp网络，三台设备的配置为：
```
conf t
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

#### IPv6 Multihop eBGP配置

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
- 在此可以观察到，R1的路由表中，3::3/128的路由是由BGP学习到的，而R2的路由表中，3::3/128是由OSPF学习到的。
