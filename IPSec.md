# IPSec
## 1. 概述
* IPSec为一组协议，包含两大部分：
1. 安全交换要加密数据流的密钥，包括IKE（Internet Key Exchange）协议；
2. 保护数据流，包括ESP（Encapsulating Security Payload）或者AH（Authentication Header）。
* IPSec协议框架可以由4部分构成：
1. IPSec Protocol，包括ESP和AH；
2. 加密算法，DES、AES；
3. 认证、MD5和SHA；
4. DH。
* AH为IP 50号，由于AH只可以保障数据完整性，而不能做加密。所以现在用途较少。

## 2. ESP
![ESP packet](https://github.com/Minions1128/net_tech_notes/blob/master/img/esp.jpg "ESP packet")
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
### 3.1 第一阶段
* 该阶段会协商IKE安全策略，建立安全通道。
* 先进行peer的认证，使用证书方式或者与共享密钥。
* 创建DH key，DH协议会独立的在两端产生只能让对端知道的共享密钥。
* 为第二阶段交换key材料，该key为数据实际加密的key。
* 产生DH key的过程是缓慢的、消耗资源的。
* 分为两种模式：主模式和激进模式。先只讨论主模式。
#### 3.1.1 消息1&2
* 交换Cookie和SA协商。
* Cookie为源目IP，源目端口，本地生成的随机数，日期和时间的HASH值。其作为IKE协商的唯一标识，防止DOS攻击。
* SA为匹配在策略提议中的5元组：加密算法（协商包第5-6个包）、散列算法、DH、认证方法和IKE SA寿命。为消息3&4的DH做准备。
#### 3.1.2 消息3&4
* DH密钥交换与生成，交换内容为Cookie、DH公开信息以及最大随机数。
* 根据DH算法，算出双方相等的密值后，连同与共享密钥生成一个skyID，然后根据推算，算出一下几个skyID：
* skyID_a：为后续的IKE消息协商以及IPSec SA协商进行完整性检查，（HMAC中的密钥）；
* skeyID_d：用来协商后续IPSec SA加密使用的密钥；
* skeyID_e：为后续的IKE消息协商以及IPSec SA协商进行加密
#### 3.1.3 消息5&6
* 这2条消息用于双方彼此验证，用sky_ID_e加密保护。
* 用HASH认证，HASH认证成分：sky_ID_a，两端cookie，预共享密钥，IKE SA，转换集、策略。
#### 3.1.4 总结
![IKE SA](https://github.com/Minions1128/net_tech_notes/blob/master/img/ike.sa.jpg "IKE SA")
### 3.2 第二阶段
该阶段会利用IKE SA保护的，协商IPSec SA来保护IPSec数据：使用AH还是ESP，hash是MD5还是SHA，是tunnel还是transport模式。数据一直后，会建立SA。
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
### 3.3 其他功能
支持邻居检测功能和NAT功能。
### 3.4 配置举例
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