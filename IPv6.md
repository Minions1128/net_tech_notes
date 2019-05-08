# IPv6
## 局限性
- 地址短缺
- 复杂的包头
    - 降低转发效率

- 辅助地址可以支持建立路由协议，不同的地址有不同的用途

- 地址配置
    - 手动
    - dhcpv6
    - 无状态，即插即用
- 报头简单
    - 没有校验和
    - 扩展报头字段

- IPv6没有分片

- ICMPv6组播大概率事件，只会发送给固定的一个终端

## CentOS配置IPv6地址
```
[root@localhost ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=static
IPADDR=10.0.203.2
NETMASK=255.255.255.0
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
IPV6INIT=yes
IPV6ADDR=fc00:203::2/64

[root@localhost ~]# cat /etc/sysconfig/network
NETWORKING=yes
GATEWAY=10.0.203.1
NOZEROCONF=yes
NETWORKING_IPV6=yes
IPV6INIT=yes
PEERNTP=no
IPV6_DEFAULTGW=fc00:203::1%eth0
```