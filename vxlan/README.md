# VxLAN
## 1. 概述
VxLAN全称为Virtual eXtensible Local Area Network，提供扩展的2层。VLAN提供12 bit的标识，而VXLAN提供24 bit的标识VNID（VXLAN Network ID）。
### 1.1 报文格式
使用MAC in UDP的封装方式

![vxlan_packet_format](https://github.com/Minions1128/net_tech_notes/blob/master/img/vxlan_packet_format.jpg "vxlan_packet_format")
### 1.2 VTEP
VXLAN使用VTEP (VXLAN Tunnel Endpoint)设备来映射，进行VLXAN的封装和解封装。每个VTEP有2个接口：一个是在本地LAN上支持本地终端通信的交换机接口，另一个是传输IP网络的IP接口。

IP接口有一个唯一的IP地址来标识VTEP设备，VTEP设备使用这个IP地址在传输网络上进行封装以太网帧并将其发送。VTPE设备也会通过此端口发现远端的VTEPs，学习到远端的MAC与VTEP的映射。
## 2. VxLAN报文转发方式
### 2.1 点对点单播方式
![vxlan_unicast_forwarding_flow](https://github.com/Minions1128/net_tech_notes/blob/master/img/vxlan_unicast_forwarding_flow.jpg "vxlan_unicast_forwarding_flow")
### 2.2 多点组播方式
![vxlan_mul_forwarding_flow](https://github.com/Minions1128/net_tech_notes/blob/master/img/vxlan_mul_forwarding_flow.jpg "vxlan_mul_forwarding_flow")

参考：http://www.cisco.com/c/en/us/products/collateral/switches/nexus-9000-series-switches/white-paper-c11-729383.html
## 3. Implement VxLAN using Open vSwitch
### 3.1 In Traditional Server
The topology is as follows. The eth0 IP addresses of VM 1 and 2 are 172.31.0.1/24 and 172.31.0.2/24 respectively. And their default gateway is 172.31.0.254
```
    +------+          +------+
    |      |          |      |
    | VM 1 |          | VM 2 |
    |      |----------|      |
    +------+          +------+
```
Create 2 OvS in VM 1, br1 is as control plane, br0 is as data plane.
```
ovs-vsctl add-br br0
ovs-vsctl add-br br1
```
Clear the eth0, assign the IP of eth0 to br1, and add the default gateway. [*]
```
ifconfig eth0 0 up
ifconfig br1 172.31.0.1/24 up
route add default gw 172.31.0.254
```
Assign port eth0 to br1.[*]
```
ovs-vsctl add-port br1 eth0
```
Config the IP address, that the tunnel will use, to br0
```
ifconfig br0 100.64.1.1/30 up
```
Create interface vx1, add the interface to br0
```
ovs-vsctl add-port br0 vx1 -- set interface vx1 \
    type=vxlan options:remote_ip=172.31.0.2
```
Do the same configure on VM 2
```
ovs-vsctl del-br br0
ovs-vsctl add-br br0
ovs-vsctl del-br br1
ovs-vsctl add-br br1
ifconfig eth0 0 up
ifconfig br1 172.31.0.2/24 up
route add default gw 172.31.0.254
ovs-vsctl add-port br1 eth0
ifconfig br0 100.64.1.2/30 up
ovs-vsctl add-port br0 vx1 -- set interface vx1 \
    type=vxlan options:remote_ip=172.31.0.1
```
Then, you can ping VM1 and VM2 each other using 100.64.1.0/30. Using iperf or other testing tool to verify its connectivity.
* [*] In order to distinguish between control plane and data plane, we create two planes. Actually, only one ovs-bridge is needed.
* If there is other futher applications need to use, change the MTU of each interface to 1450. The default value may be 1500. Using command `echo "1450" > /sys/class/net/br0/mtu` to change it.
### 3.2 In Docker
The topology is as follows. The eth0 IP addresses of Docker 1 and 2 are 172.31.0.1/24 and 172.31.0.2/24 respectively. And their default gateway is 172.31.0.254
```
    +-----------------+          +-----------------+
    |                 |          |                 |
    | +-------------+ |          | +-------------+ |
    | | Container 1 | |          | | Container 2 | |
    | +-------------+ |          | +-------------+ |
    |                 |          |                 |
    |     Docker1     |----------|     Docker2     |
    |                 |          |                 |
    +-----------------+          +-----------------+
```




We will create vxbr on Docker1
    ovs-vsctl add-br vxbr
    ifconfig vxbr 10.0.1.1/16
Create interface vx1, add the interface to vxbr
    ovs-vsctl add-port vxbr vx1 -- set interface vxlan type=vx1 options:remote_ip=172.31.0.2
Run a Container
    docker run -it --rm  \
        --name host1  \
        --net=none  \
        --privileged=true \
        minions1128/ubuntu /bin/bash
Add the veth-pair of Docker into vxbr
    /usr/bin/ovs-docker add-port vxbr eth0 b062406bc6b6(CONTAINER ID)
Config the ip address of container
    ifconfig eth0 10.0.1.2/16

Do the same configure on Docker2
    ovs-vsctl add-br vxbr
    ifconfig vxbr 10.0.2.1/16
    ovs-vsctl add-port vxbr vx1 -- set interface vxlan type=vx1 options:remote_ip=172.31.0.1
    docker run -it --rm  \
        --name host2  \
        --net=none  \
        --privileged=true \
        minions1128/ubuntu /bin/bash
    /usr/bin/ovs-docker add-port vxbr eth0 b062406bc6b6(CONTAINER ID)
    ifconfig eth0 10.0.2.2/16

Then, you can ping container-host1 and container-host2 on each container-host.

*If there is other futher applications need to use, change the MTU of each interface to 1450. The default value may be 1500.
    echo "1450" > /sys/class/net/eth0/mtu

Using iperf or other testing tool to verify its connectivity.
----------------------------------------------------------------------------------------------------------------------------------------
***** But using this kinds of method, we cannot access to Internet from container. 
By solving this problems, we implement linux-bridge and Open vSwtich at the same time.
The topology and IP addesses are the same with above.

We will create a new docker network, default gateway is 10.0.1.1
    docker network create --subnet=10.0.0.0/16 --gateway=10.0.1.1 Jesse
Run a Container with the following argument
    docker run -it --rm  \
        --name host1     \ (optional)
        -h HOST1  \        (optional)
        --net Jesse  \
        --ip 10.0.1.2  \
        minions1128/ubuntu /bin/bash
Create a ovs, which includes a vxlan interface
    ovs-vsctl add-br vxbr
    ovs-vsctl add-port vxbr vx1 -- set interface vx1 type=vxlan options:remote_ip=172.31.0.2
Add the ovs into Linux-Bridge
    brctl addif br-ed82a9291ff2 vxbr
    (Using command brctl show can get this brige name)
    ip link set vxbr up

Do the same config in the other Docker host
    docker network create --subnet=10.0.0.0/16 --gateway=10.0.2.1 Jesse
    docker run -it --rm  \
        --name host1     \ (optional)
        -h HOST1  \        (optional)
        --net Jesse  \
        --ip 10.0.2.2  \
        minions1128/ubuntu /bin/bash
    ovs-vsctl add-br vxbr
    ovs-vsctl add-port vxbr vx1 -- set interface vx1 type=vxlan options:remote_ip=172.31.0.1
    brctl addif br-ed82a9291ff2 vxbr
    (Using command brctl show can get this brige name)
    ip link set vxbr up
