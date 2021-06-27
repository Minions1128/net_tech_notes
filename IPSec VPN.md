# IPSec VPN
## 1. IPSec 概述
* IPSec为一组协议，包含两大部分：
1. 安全交换要加密数据流的密钥，包括IKE（Internet Key Exchange）协议；
2. 保护数据流，包括ESP（Encapsulating Security Payload）或者AH（Authentication Header）。
* AH为IP 50号，由于AH只可以保障数据完整性，而不能做加密。所以现在用途较少。

## 2. ESP

![ESP packet](/img/esp.jpg "ESP packet")

### 2.1 报文封装
IP 51号，其封装格式有两种模式：Transport Mode和Tunnel Mode
* Transport模式：节省了20字节的IP报头，但却要将原IP报文拆分，并且需要读取器协议字段。GRE over IPSec协议、PC2PC可以使用该模式。
* Tunnel模式：不需要拆包，直接可以封装，其效率较高。site to site VPN需要这种模式。
### 2.2 ESP报文
* SPI：安全参数索引；
* 序列号：防止重复攻击
* Next header：相当于IP报文的协议号字段。
* Auth data：存放其hash值。

## 3. IKE

IKE，网络密钥交换协议，通过UDP 500端口发送，解决IPSec自动生成、交换key的问题。IKE拥有的协议有ISAKMP（Internet Security Association Key Management Protocol），SKEME和Oakley，SKEME和Oakley组成ISAKMP。

- 参考：
    - [IPSec VPN之IKE协议详解](https://cshihong.github.io/2019/04/03/IPSec-VPN%E4%B9%8BIKE%E5%8D%8F%E8%AE%AE%E8%AF%A6%E8%A7%A3/ "IPSec VPN之IKE协议详解")
    - [IPSec VPN之IKEv2协议详解](https://cshihong.github.io/2019/04/09/IPSec-VPN%E4%B9%8BIKEv2%E5%8D%8F%E8%AE%AE%E8%AF%A6%E8%A7%A3/ "IPSec VPN之IKEv2协议详解")

### 3.1 第一阶段

* 该阶段用于建立IKE SA
* 为第二阶段交换key材料，该key为数据实际加密的key。
* 分为两种模式：主模式和激进模式。先只讨论主模式。

#### 3.1.1 消息1&2
* 协商IKE SA以及交换cookie
* SA为匹配在策略提议中的5元组：加密算法、散列算法、DH、认证方法（有3种：PSK，PKI以及RSA，这里讨论预共享密钥）和IKE SA寿命。
* Cookie为源目IP，源目端口，本地生成的随机数，日期和时间的HASH值。其作为IKE协商的唯一标识，防止DOS攻击。
#### 3.1.2 消息3&4
* DH密钥生成与交换，根据DH算法，双方分别会生成私钥，分别计算出各自的公钥，然后进行交换。与此同时交换的还有双方产生的随机值。
* 根据对方的公钥，算出双方相等的密值后，连同与共享密钥生成一个skeyID（预共享密钥, 双方的随机值），作为第1阶段5,6报文的hash密钥。然后根据推算，算出一下几个skyID：
* skyID_a（skeyID，DH计算出的密值，Cookie）：第二阶段HASH密钥（HMAC中的密钥）；
* skeyID_d（skeyID，DH计算的密值）：用来协商后续IPSec SA加密使用的密钥；
* skeyID_e（skeyID，DH计算的密值，Cookie）：为第一阶段5,6报文消息以及第二阶段的密钥
#### 3.1.3 消息5&6
* 用于身份验证，交换身份ID（IP地址或者hostname）等其他已经协商好的信息的hash值（skeyID，彼此公钥，Cookie，SA要素）。
* 所有负载已用skeyID_e进行加密。
#### 3.1.4 总结
* 消息传递

![ike](https://github.com/Minions1128/net_tech_notes/blob/master/img/ike_packet.jpg "ike")
* [DH算法](https://my.oschina.net/u/1382972/blog/330456 "DH算法")
* IKE 过程

![IKE SA](https://github.com/Minions1128/net_tech_notes/blob/master/img/ike.sa.jpg "IKE SA")
### 3.2 第二阶段
该阶段会利用IKE SA的保护，协商IPSec SA来保护IPSec数据：使用AH还是ESP，hash是MD5还是SHA，是tunnel还是transport模式。协商一致后，会建立IPSec SA。
#### 3.2.1 消息1&2
* 交换信息，包含HASH，IPSEC策略提议，NONCE和可选的DH，身份ID。
* HASH：给接受方作完整性检查，用于再次认证对等体(必须)。和第一阶段5&6消息一样。
* IPSec策略提议：其中包括了安全协议（AH或者ESP），SPI，散列算法，隧道模式，IPSEC SA生命周期(必须)。
* NONCE：用于防重放攻击，还被用作密码生成的材料。仅当启用PFS时用到。
* ID：描述IPSEC SA是为哪些地址、协议和端口建立的。
* PFS （Perfect Forward Secrecy，利用DH交换，可选）：用了PFS后，就会在第二阶段重新DH出个数据加密KEY。新key和旧key没有关系，每次协商IPSec SA会重新生成，进一步提高安全性。
* DH：重新协商IPSec SA使用（可选）。
* SA由SPI（安全参数索引，唯一标识一个SA，在AH和ESP头中传输），目的IP地址、安全协议号（AH或者ESP）。
#### 3.2.2 消息3
发送方发送第三条消息，其中包含一个HASH，其作用是确认接受方的消息以及证明发送方处于Active状态（表示发送方的第一条消息不是伪造的，确认作用ACK)
#### 3.2.3 总结
![IPSec SA](https://github.com/Minions1128/net_tech_notes/blob/master/img/ipsec.sa.jpg "IPSec SA")
### 3.3 配置举例
* 拓扑如图，R1和R3模拟两站点，使用环回口模拟内网，R2模拟运营商路由器
![IPSec topology](https://github.com/Minions1128/net_tech_notes/blob/master/img/ipsec.topo.jpg "IPSec topology")
* 基本配置为：
```
R1
interface Loopback0
 ip address 1.1.1.1 255.255.255.0
interface FastEthernet0/0
 ip address 12.1.1.1 255.255.255.0
 no shutdown
ip route 0.0.0.0 0.0.0.0 12.1.1.2
--------------------------------------------------
R2
interface FastEthernet0/0
 ip address 12.1.1.2 255.255.255.0
 no shutdown
interface FastEthernet0/1
 ip address 23.1.1.2 255.255.255.0
 no shutdown
--------------------------------------------------
R3
interface Loopback0
 ip address 3.3.3.3 255.255.255.0
interface FastEthernet0/1
 ip address 23.1.1.3 255.255.255.0
 no shutdown
ip route 0.0.0.0 0.0.0.0 23.1.1.2
```
* IPSec配置：
```
R1
crypto isakmp policy 100
 encr 3des
 hash md5
 authentication pre-share
 group 2
 lifetime 222
crypto isakmp key p1_key address 23.1.1.3
crypto ipsec transform-set r1_set esp-3des esp-md5-hmac
 mode tunnel
access-list 100 per ip 1.1.1.0 0.0.0.255 3.3.3.0 0.0.0.255
crypto map r1_map 10 ipsec-isakmp
 set peer 12.1.1.1
 set transform-set r1_set
 match address 100
int fa0/0
 crypto map r1_map
--------------------------------------------------
R3
crypto isakmp policy 100
 encr 3des
 hash md5
 authentication pre-share
 group 2
 lifetime 222
crypto isakmp key p1_key address 12.1.1.1
crypto ipsec transform-set r3_set esp-3des esp-md5-hmac
 mode tunnel
access-list 100 per ip 3.3.3.0 0.0.0.255 1.1.1.0 0.0.0.255
crypto map r3_map 10 ipsec-isakmp
 set peer 12.1.1.1
 set transform-set r3_set
 match address 100
int fa0/1
 crypto map r3_map
```
## 4. GRE over IPSec
* 由于单独的IPSec协议需要配置感兴趣流，而且没有办法通告彼此的路由，而GRE技术又是明文传递。将二者结合，解决了传输路由和私密的问题。
* 拓扑以及基本配置如上图所示。
* GRE配置：
```
R1：
interface Tunnel0
 ip address 192.168.1.1 255.255.255.0
 tunnel source FastEthernet0/0
 tunnel destination 23.1.1.3
router eigrp 1
 network 1.1.1.1 0.0.0.0
 network 192.168.1.1 0.0.0.0
--------------------------------------------------
R3：
interface Tunnel0
 ip address 192.168.1.3 255.255.255.0
 tunnel source FastEthernet0/1
 tunnel destination 12.1.1.1
router eigrp 1
 network 3.3.3.3 0.0.0.0
 network 192.168.1.3 0.0.0.0
```
* IPSec配置：
```
R1：
crypto isakmp policy 100
 encr 3des
 hash md5
 authentication pre-share
 group 2
 lifetime 222
crypto isakmp key p1_key address 23.1.1.3
crypto isakmp keepalive 10
crypto ipsec transform-set r1_set esp-3des esp-md5-hmac
 mode transport
access-list 100 permit gre 12.1.1.0 0.0.0.255 23.1.1.0 0.0.0.255
crypto map r1_map 10 ipsec-isakmp
 set peer 23.1.1.3
 set transform-set r1_set
 match address 100
int fa0/0
 crypto map r1_map
--------------------------------------------------
R3：
crypto isakmp policy 100
 encr 3des
 hash md5
 authentication pre-share
 group 2
 lifetime 222
crypto isakmp key p1_key address 12.1.1.1
crypto isakmp keepalive 10
crypto ipsec transform-set r3_set esp-3des esp-md5-hmac
 mode transport
crypto ipsec profile r3_prof
 set transform-set r3_set
interface Tunnel0
 tunnel protection ipsec profile r3_prof
```
**其中，R1和R3采用了不同的部署方式，分别使用crypto map和crypto ipsec profile方式。**
## 5. DMVPN
* 由于点到点VPN无法建立实现多点的通信，需要DMVPN技术来进行支持。
* 拓扑如图，三台路由器模拟三个站点，Fa0/0口模拟运营商网络，环回口模拟内网

![dmvpn.topology](https://github.com/Minions1128/net_tech_notes/blob/master/img/dmvpn.topo.jpg "dmvpn.topology")

* 基本配置为：
```
R1：
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
interface FastEthernet0/0
 ip address 123.1.1.1 255.255.255.0
 no shutdown
--------------------------------------------------
R2：
interface Loopback0
 ip address 2.2.2.2 255.255.255.255
interface FastEthernet0/0
 ip address 123.1.1.2 255.255.255.0
 no shutdown
--------------------------------------------------
R3：
interface Loopback0
 ip address 3.3.3.3 255.255.255.255
interface FastEthernet0/0
 ip address 123.1.1.3 255.255.255.0
 no shutdown
```
GRE配置：
```
R1：
interface Tunnel0
 ip address 192.168.1.1 255.255.255.0
ip nhrp map multicast dynamic
 ip nhrp network-id 10
 tunnel source FastEthernet0/0
 tunnel mode gre multipoint
 tunnel key 12345
router ospf 1
 network 1.1.1.1 0.0.0.0 area 0
 network 192.168.1.1 0.0.0.0 area 0
--------------------------------------------------
R2：
interface Tunnel0
 ip address 192.168.1.2 255.255.255.0
 ip ospf network broadcast
 ip ospf priority 0
 ip nhrp map 192.168.1.1 123.1.1.1
 ip nhrp map multicast 123.1.1.1
 ip nhrp network-id 10
 ip nhrp nhs 192.168.1.1
 tunnel source FastEthernet0/0
 tunnel mode gre multipoint
 tunnel key 12345
router ospf 1
 network 2.2.2.2 0.0.0.0 area 0
 network 192.168.1.2 0.0.0.0 area 0
--------------------------------------------------
R3：
interface Tunnel0
 ip address 192.168.1.3 255.255.255.0
 ip ospf network broadcast
 ip ospf priority 0
 ip nhrp map 192.168.1.1 123.1.1.1
 ip nhrp map multicast 123.1.1.1
 ip nhrp network-id 10
 ip nhrp nhs 192.168.1.1
 tunnel source FastEthernet0/0
 tunnel mode gre multipoint
 tunnel key 12345
router ospf 1
 network 3.3.3.3 0.0.0.0 area 0
 network 192.168.1.3 0.0.0.0 area 0
```
三台路由器的IPSec配置：
```
crypto isakmp policy 100
 encr 3des
 hash md5
 authentication pre-share
 group 2
crypto isakmp key p1_key address 0.0.0.0
crypto isakmp keepalive 10
crypto ipsec transform-set r_trans esp-3des esp-md5-hmac
 mode transport
crypto ipsec profile r_prof
 set transform-set r_trans
interface Tunnel0
 ip mtu 1440
 tunnel protection ipsec profile r_prof
```
