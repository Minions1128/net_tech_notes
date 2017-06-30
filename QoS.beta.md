# QoS
## 1. 概述
* QoS(Quality of Service，服务质量)，为某种流量可以保证服务质量，即保证带宽。
* 在路由器转发流量的延时有：进程延迟、串行化延时和转发延时和队列延时，其中只有队列延迟是可以通过优化机制来减少延迟，其他的无法减少。
### 1.1 QoS服务模型
* QoS有三种服务模型
1. 尽力而为（Best Effort）：报文按照IP的方式，自由发送，即不使用QoS，无法保证服务质量。
2. IntServ集成服务模型：这种服务模型，会给流量预留带宽，即使链路空闲时其他流量无法占用此带宽。如：资源预留协议(RSVP，Resource Reservation Protocol)。将在第2部分讨论。
3. DiffServ区分服务模型：这种服务模型，会抓去需要流量，然后给其较好的处理待遇。如：基于跳的处理(PHB，Per-hop Behavior)
### 1.2 区分服务模型
* 这种服务模型是应用最多的应用模型。将由分类、队列，拥塞避免以及管制整形4部分讨论，分别在第3-6部分。
1. 分类/标记：将一些流量进行标记与分类，便于以后的操作；
2. 管制/整形：主要作用为限速；
3. 拥塞避免：采用一些丢弃机制，如：RED、WRED
4. 队列：主要描述软件队列，如：FIFO、PQ，CQ、WFQ、LLQ、CBWFQ、CBLLQ等
* 其主流部署思路为：先将流量进行基于类进行划分，再使用ACL抓去流量，然后给抓取的流量打上标记，最后定义QoS的策略。
流量优先级：语音，视频，重要的业务流量。
### 1.3 名词解释
* 承诺突发：将1s逻辑的分为多份，在每份时间间隔内，网络允许在虚电路上传送的数据总量。
* 预留方式有：ff，独占欲流；se，共享式预留，可以知道源地址的方式；wf，共享式预留，无法知道源的位置。
## 2. 集成服务模型
该模型可以使用RSVP（Resource Reservation Protocol）实现，使用IntServ的应用，大多数在应用软件中自带有客户端与服务器端，即会自身完成RSVP的信令连通。
### 2.1 RSVP报文类型
* 有2种报文类型Path、Reserve报文。
* Path报文：沿着数据的传输方向，由源发送给目的，沿途路由器会缓存一份该报文，然后转发出去。
* Reserve报文：目的端收到Path报文之后，会向源回复该报文，在沿途路由器收到该报文之后，会做出2个判断：Admission Control，判断是否有足够的带宽；Policy Control，判断是否有资格预留带宽，即是否开启RSVP。满足这两个条件之后，才会预留带宽。
* 报文封装有2种封装，一种是封装在IP报文中，协议号46，另一种封装在tcp/udp 3455
* 详细报文格式参见：[RSVP报文格式](http://www.023wg.com/message/message/cd_feature_rsvp_message_format.html)
### 2.2 配置命令
* 如果应用程序不支持RSVP，需要路由器模拟源和目的。
* 模拟拓扑为：
```
R4(PC)--R2(源)--R1--R3(目的)--R5(PC)
```
R2代替R4发送Path给R5，R3代替R5发送Reserve给R4
* 部署步骤：
1. 配置地址，R1-R3部署IGP；
2. 开启cef；
3. 在接口开启RSVP：
```
ip rsvp bandwidth             #默认预留75%的带宽
ip rsvp bandwidth 2000 1000   #为单股流量预留1000k，预留最大带宽2000k
ip rsvp bandwidth [interface-kbps [single-flow-kbps]]
```
4. R2模拟R4发送Path报文给R5：
```
ip rsvp sender 目的地址 源地址 tcp/udp 目的端口 源端口 接口 预留带宽 承诺突发
```
5. R3代替R5发送Reserve给R4：
```
ip rsvp reservation 源地址 目的地址 tcp/udp 源端口 目的端口 接口 预留方式 预留带宽 承诺突发
```
如果R4，R5为自己部署预留带宽，则：将R4和R5运行IGP，在接口启用RSVP，配置命令中sender换为sender-host。
## 3. 分类
流量的分类可以基于：入站端口、IP Precedence、DSCP、源目的地址以及应用。然后将其打上不同的标记，如IP中的ToS，链路层的CoS。拆掉封装之后，其CoS的值要与ToS的值进行映射，以保证QoS的信息不丢失。
### 3.1 IP Precedence
* 使用IP报文中的ToS字段中的前3 bit，来描述流量的类型以及需要提供的处理待遇。
* 业界规定IP Precedence分为7类，由低到高的排序为：

| Tag | Description | 描述 |
| :------------: | :------------ | :------------ |
| 1 | priority | 垃圾流量 |
| 0 | routine | 冲浪流量 |
| 2 | immediated | 业务流量 |
| 3 | flash | 信令流量和重要业务流量 |
| 4 | flash-override | 视频流量 |
| 5 | critical | VoIP |
| 6 | internet | 控制层面的路由协议 |
| 7 | network | 保留 |
### 3.2 DSCP
![qos_dscp](https://github.com/Minions1128/net_tech_notes/blob/master/img/qos_dscp.jpg "qos_dscp")
* 由于IP Precedence可使用的数值较少，无法细分流量，IETF有定义了DSCP（Differ Service Code Point），使用ToS的前6 bit。前3 bit为X，值越大，优先级越高；* 然后2 bit为Y，丢弃优先级，值越低，优先级越高；* 最后1 bit保留。
* DCSP分为四类：
1. Default：X==Y==0（1个）
2. CS类为IP Precedence：X!=0, Y==0，兼容IP Precedence（7个）
3. AF：X = {001, 010, 011, 100}，Y = {01, 10, 11}。例如：ToS字段为：10011000意为AF43类（12个）
4. EF：X=5，Y=3，在VoIP中使用（1个）
### 3.3 以太网标记
不仅三层报文中可以加入标记，2层设备也可以添加标记，在802.1q中，PRI中有3 bit的CoS可以用来标记，标记之后的协议称之为802.1p

| CoS | Application |
| :------------: | :------------ |
| 7 | Reserved |
| 6 | Reserved |
| 5 | Voice Bearer |
| 4 | Videoconferencing |
| 3 | Call Signaling |
| 2 | High-Priority Data |
| 1 | Medium-Priority Data |
| 0 | Best-Effort Data |
### 3.4 打标记配置举例
标记建议在信任边界的位置打，即IP电话或者连接交换机的位置。如果终端电脑发出的报文带有异常的QoS标记，IP电话或者交换机会修改为正确的值之后，在帮其转发。
* 需求：FTP流量设置为IP Precedence 1，HTTP为DSCP CS 2，Telnet为DSCP AF 31，Voice为DSCP 46，EIGRP为DSCP CS 6
#### 3.4.1 基于PBR实现
使用ACL抓去流量，使用Route-map打标记。这种方式无法实现DSCP，而且只能调用入向，无法实现出向调用。
```
access-list 100 permit tcp any any range ftp-data ftp
access-list 100 permit tcp any range ftp-data ftp any
...
route-map PBR permit 10
 match ip address 100
 set ip precedence priority
...
interface FastEthernet0/0
 ip policy route-map PBR
```
#### 3.4.2 使用CB-Marking
CBMarking使用MQC模块化部署，嵌套性强，便于实施。MQC的工具：class-map调用ACL，然后分类；Policy-map，调用Class-Map然后做QoS
```
# 先使用ACL抓去流量
ip access-list extended EIGRP
 permit eigrp any host 224.0.0.10
ip access-list extended FTP
 permit tcp any any range ftp-data ftp
 permit tcp any range ftp-data ftp any
ip access-list extended HTTP
 permit tcp any any eq www
 permit tcp any eq www any
ip access-list extended TELNET
 permit tcp any any eq telnet
 permit tcp any eq telnet any
ip access-list extended VoIP
 permit udp any any range 16384 32767
 permit udp any range 16384 32767 any

# 使用class-map调用acl，class-map中有match-all和match-any区分
class-map match-all TELNET
 match access-group name TELNET
class-map match-all HTTP
 match access-group name HTTP
class-map match-all VoIP
 match access-group name VoIP
class-map match-all FTP
 match access-group name FTP
class-map match-all EIGRP
 match access-group name EIGRP

# 再使用policy-map调用每个class-map
policy-map CBMarking
 class FTP
  set ip precedence 1
 class HTTP
  set ip dscp cs2
 class TELNET
  set ip dscp af31
 class VoIP
  set ip dscp 46
 class EIGRP
  set ip dscp cs6

# 最后在接口应用
interface FastEthernet0/0
 service-policy input CBMarking
interface FastEthernet0/1
 service-policy output CBMarking

sh policy-map interface   # 可以show出每个接口的详细policy-map的情况
```
#### 3.4.3 基于网络的应用识别
NBAR，Network Based Application Recognition，其作用主要是对动态分配TCP/UDP端口号的应用程序和HTTP流量等进行分类，在分类的同时，还可以对该分类数据流量进行统计。还可以基于包描述语言模块（PDLM, Packet Description Language Module）抓取，这种特征库可以在官网下载。参考：[使用NBAR统计与分析流量](http://7658423.blog.51cto.com/7648423/1346546)
## 4. 队列
* 当报文即将要从路由器某个接口转发走时，路由器会给这些报文定义一段缓冲区buffer，即队列。
* 默认存在的队列为：接口带宽大于2.048Mbps，默认使用FIFO，小于则使用WFQ。
### 4.1 FIFO
* FIFO, First In First Out，先进先出，不支持分类，执行尾丢弃。无法实现QoS标记识别，因此不被普遍使用。
```
no fair-queue            # 将该接口部署为FIFO
hold-queue 300 in/out    # 修改该接口的出入队列长度
show interface fa0/0     # 查看队列类型
```
### 4.2 PQ
* PQ, Priority Queue，支持分类。
* 队列机制：将队列分为4类：low，normal（默认），medium以及high。如果高优先级的队列中有报文就会优先转发，只有高优先级队列为空之后才会转发中低优先级队列，每个优先级队列采用FIFO的模式。缺点为可以“饿死”其他优先级的流量。
* 实验：将telnet流量放入high队列，ICMP、non-IP流量放入low队列，IP流量以及fa0/1进入的流量放入medium队列。
```
priority-list 15 protocol ip high tcp telnet  #在优先级列表15中，将telnet流量放入高优先级队列
access-list 100 per icmp any any
priority-list 15 protocol ip low list 100     #将ACL100的流量加入到low队列中
priority-list 15 protocol ip medium           #将其他IP流量加入到medium中
priority-list 15 default low                  #将非IP流量缴入到low队列
priority-list 15 interface fa0/1 medium       #将fa0/1接受的流量放入到medium队列中
priority-group 15                             #在接口中调用该优先级列表
priority-list 15 queue-limit 25 25 25 25      #修改队列长度
debug priority                                #debug PQ
```
### 4.3 CQ
* CQ, Custom Queue，支持分类。
* 队列机制：默认有17个队列，分为队列0和队列1-16两种，每个子队列采用FIFO。队列0为优先级队列缓存系统流量，当队列0为空时，队列1-16使用Round Robin轮巡调度转发流量。与PQ相比，不会饿死流量。缺点为无法保证优先级队列的带宽。
* 实验部署：telnet流量放入队列3，ICMP流量放入队列4，fa0/1流量放入队列5，IP流量放入队列6，non IP流量放入队列7，将VoIP放入队列1
```
queue-list 10 protocol ip 3 tcp telnet #将telnet流量放入到队列3中
queue-list 10 protocol ip 4 list 100 #将ACL 100的流量放入队列4
queue-list 10 int fa0/1 5 #fa0/1流量放入队列5
queue-list 10 protocol ip 6 #将IP流量放入队列6
queue-list 10 default 7 #讲其他非IP流量放入队列7
custom-queue-list 10 #在接口中调用该CQ，调用之前确保接口中没有调用其他队列
access-list 101 permit udp any range 16384 32767 any
access-list 101 permit udp any any range 16384 32767
queue-list 10 protocol ip 1 list 100
queue-list 10 lowest-custom 2 #设置最低轮巡队列为2，则轮巡队列会设置为2-16
queue-list 10 queue 0 limit 30 #设置队列长度为30
queue-list 10 queue 3 byte-count 3000 #轮巡队列默认一次发送1500字节，该命令将3队列每次发送3000字节
```
### 4.4 WFQ
* WFQ, Weighted Fair Queuing，又称为FBWFQ, Flow-Based WFQ。
* 队列机制：基于IP地址，TCP/UDP端口号，IP协议号或者ToS值动态地创建队列，最大有256个队列，可扩充到4096个队列。若每个队列的ToS值相同，则带宽被均等地分配给所有队列，即，low-traffic优先。若ToS不同时，每个队列会将每个到达的报文分配一个序列号，该序列号乘以其inverse权重即为其转发序列号，队列会从转发序列号由低向高依次转发。这样高优先级会被先服务。
* 不会计算每个队列的容纳报文数量，而会宏观调控，关注整个队列容纳报文数量。定义了2个名词CDT和HQO：CDT, Congestive Discard Threshold，下限阈值，若报文数到达下限阈值，无法加入到已经满的子队列，但是可以加入到非满的队列中；HQO为上限阈值，到达HQO后，会丢弃所有后续报文。
* 举个栗子：队列有3个子队列，每个子队列的容量为4个报文。第一个子队列有4个报文，队列已经满了；第二个子队列中有3个报文，队列还可以容纳一个报文；第三个子队列有1个报文，可以容纳3个报文。该队列一共有8个报文。如果CDT为8时，新报文想要加入到第一个子队列是无法加入，但其可以加入到第二个、第三个子队列中；如果该队列的HQO为8，则该队列中即使有子队列为空，新来的报文也无法加入。
配置命令：
```
fair-queue #在接口启用WFQ
fair-queue cdt 活动队列数量 预留队列数量 #修改WFQ的参数
hold-queue 3000 out #接口下修改FIFO和WFQ的HQO
show queuing fair #查看WFQ详细信息
```
### 4.5 LLQ
* LLQ, Low-latency queue，其实LLQ也为Flow-based LLQ，即FBLLQ=PQ+FBWFQ。
* 队列机制：把FBWFQ基于优先级区分，高优先级的先被转发，然后其次是其他优先级的流量。
```
ip rtp priority 16384 16383 200
#老版本的配置FBLLQ命令，接口先启用FBWFQ，然后使用该命令，为语音流量预留200k的流量
```
### 4.6 CBWFQ
* 一种配置WFQ的策略，基于类的WFQ，先使用ACL抓去流量，然后将不同的类应用不通的策略，该机制有一个默认的class-default，将所有没有定义的流量放入该类中。这中default class使用FIFO转发。
* 实验需求：VoIP流量占用带宽的20%，Video占用30%，Business占用30%，控制流量2000kbps占用100K，其余为Internet流量。
* 部署举例：
```
class-map match-all VoIP
 match protocol rtp audio
class-map match-all Video
 match protocol rtp video
class-map match-all Business
 match protocol ftp
class-map match-all Control
 match protocol eigrp
policy-map CBWFQ
 class VoIP
  bandwidth percent 20
 class Video
  bandwidth percent 30
 class Business
  bandwidth percent 30
 class Control
  bandwidth 5
 class class-default
  fair-queue
int fa0/0
 max-reserved-bandwidth 85
 service-policy output CBWFQ
 ip nbar protocol-discovery
```
4.7 CBLLQ
* CBLLQ=PQ+CBWFQ，定义了一个强制优先级队列
* 实验举例：VoIP流量占用带宽的20%（强制优先），Video占用30%，Business占用30%，控制流量2000kbps占用100K（强制优先），其余为Internet流量。
```
policy-map CBLLQ
 class Control
  priority 100
 class VoIP
  priority percent 20
 class Video
  bandwidth percent 30
 class Business
  bandwidth percent 30
 class class-default
  fair-queue
```
## 5. 拥塞避免
### 5.1 RED
RED, Random Early Detection，早期随即检测，一种拥塞避免机制，在0到最大带宽之间定义一个阈值，当带宽达到阈值时，报文开始随机被丢弃，带宽越大，报文丢弃的概率会越大，达到最大会执行尾丢弃。避免多种流量在同一时间出现拥塞，造成带宽利用率较低。
### 5.2 WRED
![qos_cbred](https://github.com/Minions1128/net_tech_notes/blob/master/img/qos_cbred.png "qos_cbred")
* WRED, Weighted Random Early Detection，加权的早期随即检测，权重一般为IP Precedence以及DSCP。以IP Precedence举例，WRED会根据阈值划分多个阈值，Precedence越大，子阈值也越大。该机制会将不同的流量根据不同的Precedence进行RED丢弃。 
* 举例：
```
random-detect #定义RED
random-detect prec-based #基于Precedence定义WRED
show queueing random-detect #查看RED内容
random-detect dscp-based #基于DSCP定义WRED
random-detect dscp ef 39 45 20 #修改ef的低阈值为39，高阈值为45，丢弃概率为1/20
```
5.3 FBWRED, CBWRED
FBWRED，基于流的WRED；CBWRED，基于类的WRED
```
配置举例：
random-detect flow #开启FBWRED
部署需求：Voice使用30%的Priority，重要Data使用30%的带宽，Business使用20%的带宽
ip access-list extended Data
 permit tcp any any eq telnet
 permit tcp any eq telnet any
ip access-list extended FTP
 permit tcp any any range ftp-data ftp
 permit tcp any range ftp-data ftp any
ip access-list extended VoIP
 permit udp any any range 16384 32767
 permit udp any range 16384 32767 any
class-map match-all VoIP
 match access-group name VoIP
class-map match-all Data
 match access-group name Data
class-map match-all Business
 match access-group name ftp
policy-map CBWRED
 class VoIP
  priority percent 30
 class Data
  bandwidth percent 30
  random-detect dscp-based
 class Business
  bandwidth percent 30
  random-detect dscp-based
 class class-default
  fair-queue
  random-detect dscp-based ecn
  #ecn参数表示，这种流量不会被随机丢弃，而是产生一些日志警告
int fa0/0
 max-reserved-bandwidth 85
 service-policy output CBWRED #需要先去掉其他RED
```
6. 整形与管制
整形与管制用于对接口流量的限速，这两种机制的区别在于：1，对于过量（exceed）流量而言，整形会将过量的报文缓冲到整形队列中，而管制可能会将过量的报文进行丢弃；2，对于控制流量的方向上，整形只能基于流量的出向实现，而管制可以基于流量的出向和入向同时限制。在接口处，整形与管制优先级高于软件队列。这些机制都是基于令牌桶（Token-Bucket）算法来实现的。
6.1 令牌桶算法
6.1.1 相关名字
CIR, Committed Information Rate，承诺信息率，即限速带宽。
Tc, Time committed，时间分片，交换机的物理转发速率不会受到软件的控制而降低，而是通过限制转发时间来限制带宽。算法将一秒逻辑的划分为若干个，使得报文在某些时间分片内可以转发，有些时间分片内无法转发。每个时间间隔即为Tc，一般为125ms。
Bc, Burst committed，承诺突发，在时间片内发送的报文总量。Bc的单位，在整形中单位为bit，管制的单位是Byte。
CIR=Bc/Tc
根据流量类别以及速率限制的范围，算法可以分为三种：单速率双色令牌桶、单速率三色令牌桶以及双速率三色令牌桶。
6.1.2 单速率双色令牌桶
当部署整形或者管制后，会生成一个桶，桶的大小为Bc大小，会在每个Tc内被装满，多余的令牌会被丢弃。报文在进入软件queue之前，会从令牌桶中抓取一个令牌，如果抓到令牌，则报文被标记为绿色，然后进入软件queue，如果软件queue没有排队，可以绕过软件queue，直接进入硬件queue，从而被转发；没有拿到令牌的报文会被标记为红色，称之为超速报文，对于管制和整形的处理方式不同：管制会丢弃（默认行为），或者将其加上其他标记进行转发。整形会放入shapping queue，该队列的报文会标记为优先级最高的报文，来到令牌桶中找令牌，如果找到令牌，则被标记为绿色报文，进而转发。
6.1.3 单速率三色令牌桶
该机制在Bc的基础上定义了Be，Burst exceeded，装载过量突发的流量，其大小和Bc一致。令牌会在每个Tc中装在Bc中，当Bc装满之后，令牌才会被装到Be令牌桶中。若报文抓取的令牌为Bc桶中的，标记其为绿色，抓的报文为Be桶中的，标记其为黄色，没有抓取到令牌的，标记其为红色。其后的操作与单速率双色令牌桶。
6.1.4 双速率三色令牌桶
这种机制在之前的基础之上，定义了PIR（Peak information rate，峰值信息率），即带宽在CIR到PIR之间浮动限制。由定义EIR（Exceeded information rate，过量信息率），EIR= PIR – CIR。该机制定义的Bc桶和Be桶，在每个Tc内均可以被填满令牌，均可以同时转发报文。这样就实现了带宽的浮动。
6.2 整形机制
整形机制有3中常规的部署方法：通用流量整形（GTS, Generic Traffic Shape）、帧中继流量整形（FRTS, Frame-Relay Traffic Shape）以及基于类的流量整形（CBTS, Class-based Traffic Shape）。
6.2.1 GTS
这种整形机制中，整形Queue只能为WFQ，可以使用任何软件Queue。配置命令以及相关解释如下：
traffic-shape rate 1000000 #开启GTS，CIR为1M
show traffic-shape #查看整形流量
Target Bit Rate, CIR
Bits per interval, sustained, Bc
Bits per interval, excess in first interval, Be
Set buffer limit, Shaping Queue
traffic-shape group 100 #基于对ACL 100作整形
6.2.2 FRTS
FRTS，只能在Frame-Relay接口使用，只能使用FIFO队列
6.2.3 CBTS
CBTS，shaping-queue为WFQ，并且无法改变，可以在任何接口启用，不要求接口的队列使用特殊队列。
access-list 101 permit ip host 1.1.1.1 host 2.2.2.2
access-list 102 permit ip host 1.1.1.1 host 3.3.3.3
!
class-map match-all R1R3
 match access-group 102
class-map match-all R1R2
 match access-group 101
!
policy-map CBTS
 class R1R2
  shape average 64000 6400 0
  shape adaptive 32000
  shape peak 
 class R1R3
  shape average 70000 7000 0
  shape adaptive 35000
!
interface FastEthernet0/0
 service-policy output CBTS
6.3 管制
管制中对流量的定义有conform-action 绿色流量，exceed-action 红色流量，iolation-action 黄色流量。管制机制常规有2种方法：CAR (Committed Access Rate)以及CBPolicing。
6.3.1 CAR
举个例子，需求：R1到R3的所有流量，CIR 1M，BC 100K，BE 100K，TC 100ms，绿色流量转发，红色流量，1，丢弃；2，降格发送。
rate-limit output access-group 100 1000000 12500 12500 conform-action transmit exceed-action drop #在接口模式下，对出向流量抓取ACL 100，CIR为1M，BC为12500字节，be为12500字节对于绿色、黄色流量转发，红色流量丢弃。
rate-limit output access-group 100 1000000 12500 12500 conform-action set-dscp-continue 32 exceed-action drop #对于拿到令牌的流量，设置dscp为32然后继续匹配下面的语句
 rate-limit output access-group 105 1000000 12500 12500 conform-action transmit exceed-action drop #两条语句中，均拿到令牌，则可以转发，否则丢弃
6.3.2 CBPolicing
举个例子
class-map match-all CBPolicyCM
 match access-group 100
!
policy-map CBPolicyPM
 class CBPolicyCM
  police cir 1000000 bc 12500 be 12500 conform-action transmit  exceed-action drop
interface FastEthernet0/0
 service-policy output CBPolicyPM
承诺突发：将1s中划分为[200（前）/200（后）]份，每份分发200（后）