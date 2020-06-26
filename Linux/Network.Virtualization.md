# Network Virtualization

## Linux Network NameSpace

- netns 在内核实现, 其功能由 iproute 所提供的 netns 这个 OBJECT 来提供

```
+-------------+  +-------------+
|             |  |             |
|     vm1     |  |     vm2     |
|    eth0     |  |    eth0     |
| 10.0.0.1/24 |  |    dhcp     |
|             |  |             |
+-------------+  +-------------+
       \               /
        -------+-------
               |
      +-----------------+
      |                 |
      |      br-in      |
      | eth(link-in-br) |
      |                 |
      +-----------------+
               |
     +-------------------+
     |                   |
     |   10.0.0.254/24   |
     |  eth0(link-in-rt) |
     |        rt         |
     |  eth1(link-ex-rt) |
     | 192.168.100.11/24 |
     |                   |
     +-------------------+
               |
  +--------------------------+
  |                          |
  |     eth(link-ex-br)      |
  | br-ex(192.168.100.21/24) |
  |     eth(eno16777736)     |
  |                          |
  +--------------------------+
```

```sh
yum install bridge-utils -y

# 创建 br-in
brctl addbr br-in
ip link set br-in up
sysctl -w net.ipv4.ip_forward=1

# 创建虚拟机, $1 为虚拟机网卡
ip link set $1 up
brctl addif br-in $1
## vm1(no ip addr)--
##                   \
##                    >-- br-in
##                   /
## vm2(no ip addr)--

# 创建一对link, link-in-rt(在路由器上), link-in-br(在br-in上)
ip link add link-in-rt type veth peer name link-in-br
ip link set link-in-rt up
ip link set link-in-br up

# link-in-br 加入到 br-in
brctl addif br-in link-in-br

# 创建 rt 命名空间, 虚拟路由器

# link-in-rt 加入到 rt 上, 并且配置网关地址
ip link set link-in-rt netns rt
ip netns exec rt ifconfig -a
ip netns exec rt ip link set link-in-rt name eth0
ip netns exec rt ip link set up
ip netns exec rt ip link show
ip netns exec rt ifconfig eth0 10.0.0.254/24 up
## vm1(no ip addr)--
##                   \
##                    >-- br-in -- (10.0.0.254)vrouter
##                   /
## vm2(no ip addr)--


# 创建 br-ex, 将物理机网卡加入到物理机网卡中
brctl addbr br-ex
ip link set br-ex up
ip addr del 192.168.100.21/24 dev eno16777736; \
    ip addr add 192.168.100.21/24 dev br-ex; \
    brctl addif br-ex eno16777736
## br-ex(192.168.100.21/24) -- eno16777736

# 创建一对link, link-ex-rt(在路由器上), link-ex-br(在br-ex上)
ip link add link-ex-rt type veth peer name link-ex-br
ip link set link-ex-rt up
ip link set link-ex-br up

# link-ex-br 加入到 br-ex
brctl addif br-ex link-ex-br

# # link-ex-rt 加入到路由器上, 并且配置网关地址, 配置 snat 到物理机的 ens16777736
ip link set link-ex-rt netns rt
ip netns exec rt ip link set link-ex-rt name eth1
ip netns exec rt ifconfig eth1 192.168.100.11/24 up
ip netns exec rt ping 192.168.100.1
ip netns exec rt iptables -t nat \
                    -A POSTROUTING \
                    -s 10.0.0.0/24 ! \
                    -d 10.0.0.0/24 \
                    -j SNAT \
                    --to-source 192.168.100.11
# 利用 dnsmasq 给 vm dhcp 分配地址
ip netns exec rt dnsmasq -F 10.0.0.151,10.0.0.160 \
                    --dhcp-option=option:router,10.0.0.254

# 进入 vm1, 手动配置地址
    ifconfig eth0 10.0.0.1/24 up
    ping 10.0.0.254
    route add default gw 10.0.0.254

# 进入 vm2, 利用 dhcp 获取地址
    udhcpc -h
    udhcpc -R
```
