# IPv6 BGP配置举例
```
 +---------------------------------------------------------------+
 |                                                               |
 |                R1(0/0)---(0/0)R2(0/1)---(0/1)R3               |
 |                                                               |
 +---------------------------------------------------------------+
```
## R1
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
## R2
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
## R3
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