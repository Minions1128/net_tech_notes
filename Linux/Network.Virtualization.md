# Network Virtualization

## Linux Network NameSpace

- netns 在内核实现, 其功能由 iproute 所提供的 netns 这个 OBJECT 来提供

- 利用 netns 实现一个虚拟网络与外网通信

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

## OvS

- 基于C语言开发, 特性:
    - 802.1q
    - NIC bonding
    - NetFlow, sFlow
    - QoS
    - (IPSec over )GRE, VxLAN
    - OpenFlow

- 组成部分:
    - ovs-vswitched: OvS daemon, 实现数据报文交换功能, 和linux内核兼容模块, 一同实现了基于流的交换技术
    - ovsdb-server: 轻量级的数据库服务器, 主要保存OvS的配置信息, e.g..接口, 交换和vlan; ovs-switched 的交换功能基于此库完成
    - ovs-dpctl
    - ovs-vsctl: 用于获取/更改ovs-switched的配置信息, 其修改操作会保存与ovsdb-server
    - ovs-appctl
    - ovsdbmonitor
    - ovs-controller
    - ovs-ofctl
    - ovs-pki

- `service openvswitch start`启动ovs



- `ovs-vsctl [OPTIONS] COMMAND [ARG...]`
    - show: print overview of database contents
    - add-br/del-br BRIDGE: create/delete a new bridge named BRIDGE, (and delete all of its ports)
    - list-br: print the names of all the bridges
    - add-port/del-port BRIDGE PORT: add/delete network device PORT (when delete, which may be bonded) to BRIDGE
    - list-ports BRIDGE: print the names of all the ports on BRIDGE
    - list TBL [REC]: list RECord (or all records) in TBL, TBL: Intercace, Port

```sh
ip link add s0 type veth peer name s1
ovs-vsctl add-port br0 s0
ovs-vsctl add-port br1 s1
ovs-vsctl set port vif1 tag 10
ovs-vsctl remove port vif1 tag 10
```

```sh
ip link add sif0 type veth peer name rif0
ip link set rif0 netns r0
ovs-vsctl add-port br-in sif0

ip netns exec r0 ip link set rif0 up
ip netns exec r0 ip addr add 10.0.4.0/24 dev rif0
ip netns exec dnsmasq -F 10.0.4.11,10.0.4.20,86400 -i rif0
ip netns exec ss -tuanl | grep 67
# 启动一个vm, vm的地址使用dnsmasq配置
```

```
/etc/udev/rules.d/70-persistent-net.rules
修改之后, `/etc/sysconfig/network-scripts/ifcfg-eth0`相应修改其mac地址
重新装在网卡
```
