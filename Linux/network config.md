* 路由配置

```
route -n    # 查看路由表
arp -n      # 查看ARP表

route add -net 10.0.0.0/8 gw 10.0.0.1 dev eth0
route add -net 172.16.0.0/12 gw 10.0.0.1 dev eth0
route add -net 192.168.0.0/16 gw 10.0.0.1 dev eth0
route add -net 0.0.0.0/0 gw 123.123.123.123 dev eth1

route del -net 0.0.0.0/0 gw 123.123.123.123 dev eth1
```
