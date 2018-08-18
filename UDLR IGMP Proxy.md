# Integrated UDLR Tunnel IGMP UDLR and IGMP Proxy Example

The following example shows how to configure UDLR tunnels, IGMP UDLR, and IGMP proxy on both the upstream and downstream routers sharing a UDL.

## Topology

![udlr_igmp_proxy](https://github.com/Minions1128/net_tech_notes/blob/master/img/udlr_igmp_proxy.jpg)

## Configuration Example

### Upstream Router

```
ip multicast-routing
!
! user network
!
interface GigabitEthernet2/1/0
 ip address 12.0.0.1 255.255.255.0
 no ip directed-broadcast
 ip pim dense-mode
 ip cgmp
 fair-queue 64 256 128
 no cdp enable
 ip rsvp bandwidth 1000 100
!
! Backchannel
!
interface GigabitEthernet2/2/0
 ip address 11.0.0.1 255.255.255.0
 no ip directed-broadcast
 no cdp enable
 ! this interface can ping 13.0.0.2
!
! physical send-only interface
!
interface GigabitEthernet2/3/0
 ip address 10.0.0.1 255.255.255.240
 no ip directed-broadcast
 ip pim dense-mode
 ip nhrp network-id 5
 ip nhrp server-only
 ip igmp unidirectional-link
 fair-queue 64 256 31
 ip rsvp bandwidth 1000 100
!
! tunnel interface
!
interface Tunnel0
 ip address 1.1.1.11 255.255.255.255
 no ip directed-broadcast
 tunnel source 1.1.1.11
 tunnel mode gre multipoint
 tunnel key 5
 tunnel udlr receive-only GigabitEthernet2/3/0
!
! to downstream loopback interface
!
ip route 2.2.2.2 255.255.255.255 10.0.0.2
!
! to downstream tunnel interface
!
ip route 2.2.2.22 255.255.255.255 10.0.0.2
!
! to downstream user network
!
ip route 14.0.0.0 255.255.255.0 10.0.0.2
!
end
```

### Downstream Router

```
ip multicast-routing
!
! user network
!
interface GigabitEthernet2/1/0
 ip address 14.0.0.2 255.255.255.0
 no ip directed-broadcast
 ip pim sparse-mode
 ip igmp mroute-proxy Loopback0
 no cdp enable
!
! Backchannel
!
interface GigabitEthernet2/2/0
 ip address 13.0.0.2 255.255.255.0
 no ip directed-broadcast
 no cdp enable
 ! this interface can ping 11.0.0.1
!
! physical receive-only interface
!
interface GigabitEthernet2/3/0
 ip address 10.0.0.2 255.255.255.0
 no ip directed-broadcast
 ip pim sparse-mode
 ip igmp unidirectional-link
 no keepalive
 no cdp enable
!
! tunnel interface
!
interface Tunnel0
 ip address 2.2.2.22 255.255.255.252
 ip access-group 120 out
 no ip directed-broadcast
 no ip mroute-cache
 tunnel source 2.2.2.22
 tunnel destination 1.1.1.11
 tunnel key 5
 tunnel udlr send-only GigabitEthernet2/3/0
 tunnel udlr address-resolution
!
! loopback interface
!
interface Loopback0
 ip address 2.2.2.2 255.255.255.255
 ip pim sparse-mode
 ip igmp helper-address udl GigabitEthernet2/3/0
 ip igmp proxy-service
!
ip route 0.0.0.0 0.0.0.0 11.0.0.1
!
! set rpf to be the physical receive-only interface
! bad next-hop address
!
ip mroute 0.0.0.0 0.0.0.0 10.0.0.0
ip pim rp-address 14.0.0.2
!
! permit ospf, ping and rsvp, deny others
!
access-list 120 permit icmp any any
access-list 120 permit 46 any any
access-list 120 permit ospf any any
!
end
```














