# VxLAN
## 1. 特性
其全称为Virtual eXtensible Local Area Network，提供扩展的2层。VLAN提供12 bit的标识，而VXLAN提供24 bit的标识VNID（VXLAN Network ID）VLAN使用STP防止环路，VXLAN使用3层的方式，链路聚合、负载均衡
## 2. 报文格式
使用MAC in UDP的封装方式
![](https://github.com/Minions1128/Tools/blob/master/img/vxlan_packet_format.jpg)
## 3. VTEP
VXLAN使用VTEP (VXLAN Tunnel Endpoint)设备来映射，进行VLXAN的封装和解封装。每个VTEP有2个接口：一个是在本地LAN上支持本地终端通信的交换机接口，另一个是传输IP网络的IP接口。
IP接口有一个唯一的IP地址来标识VTEP设备，VTEP设备使用这个IP地址在传输网络上进行封装以太网帧并将其发送。VTPE设备也会通过此端口发现远端的VTEPs，学习到远端的MAC与VTEP的映射。
## 4. VxLAN报文转发方式
### 4.1 点对点单播方式
![](https://github.com/Minions1128/Tools/blob/master/img/vxlan_unicast_forwarding_flow.jpg)
### 4.2 多点组播方式
![](https://github.com/Minions1128/Tools/blob/master/img/vxlan_mul_forwarding_flow.jpg)
来源：http://www.cisco.com/c/en/us/products/collateral/switches/nexus-9000-series-switches/white-paper-c11-729383.html
## 5. 利用Open vSwitch部署VxLAN


This program will implement vxlan using Open vSwitch in Mininet.

We need to input the remote outbound ip address and the Data Center Number [1/2]

Then we can do some testing on it.

Here is a method that config ovs on 2 MVs.
The topology is as follows:
    +-------+     +-------+
    |       |     |       |
    |  VM1  |-----|  VM2  |
    |       |     |       |
    +-------+     +-------+
IP addresses:
    VM1-eth0：172.31.0.1/24
    VM2-eth0：172.31.0.2/24

We use the 2 Open vSwitch in each VM, br1 is as control plane, br0 is as data plane.

We will create br0 and br1 on VM1
    ovs-vsctl del-br br0
    ovs-vsctl add-br br0
    ovs-vsctl del-br br1
    ovs-vsctl add-br br1
Clear the eth0, assign the IP of eth0 to br1, and add the default gateway.[**]
    ifconfig eth0 0 up
    ifconfig br1 172.31.0.1/24 up
    route add default gw 172.31.0.254
Assign port eth0 to br1.[**]
    ovs-vsctl add-port br1 eth0
Config the IP address, that the tunnel will use, to br0
    ifconfig br0 100.64.1.1/30 up
Create interface vx1, add the interface to br0
    ovs-vsctl add-port br0 vx1 -- set interface vx1 type=vxlan options:remote_ip=172.31.0.2

Do the same configure on VM2
    ovs-vsctl del-br br0
    ovs-vsctl add-br br0
    ovs-vsctl del-br br1
    ovs-vsctl add-br br1
    ifconfig eth0 0 up
    ifconfig br1 172.31.0.2/24 up
    route add default gw 172.31.0.254
    ovs-vsctl add-port br1 eth0
    ifconfig br0 100.64.1.2/30 up
    ovs-vsctl add-port br0 vx1 -- set interface vx1 type=vxlan options:remote_ip=172.31.0.1

Then, you can ping VM1 and VM2 each other using 100.64.1.0/30.

*If there is other futher applications need to use, change the MTU of each interface to 1450. The default value may be 1500.
    echo "1450" > /sys/class/net/br0/mtu
**In order to distinguish between control plane and data plane, we create two planes. Actually, only one ovs-bridge is needed.

Using iperf or other testing tool to verify its connectivity.
