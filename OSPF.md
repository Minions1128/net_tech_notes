# OSPF
## 1. 概述
* 支持中大型IGP，以组播的形式发送LSA（p2p链路类型除外），组播地址为224.0.0.5和224.0.0.6。管理距离为110
* OSPF为进程级的路由协议，不同进程号不影响建立邻接关系。
* OSPF报文确认方式：隐式确认（使用相同报文回复，序列号相同）和显式确认（单独报文回复）。
* RID，唯一标示一台路由器，可以1，手动配置；2，选UP环回口最大IP地址；3，物理接口最大的UP口（不一定非要运行OSPF）。即使回环口、物理口down之后，RID不会改变。
## 2. 区域
### 2.1 两类区域
区域的划分基于端口，可以缩小路由表项，减少LSA泛洪。
* 主干区域：transit area或者area 0
* 非主干区域：regular area
>所有非主干区域必须连接到主干区域上
### 2.2 特殊区域
#### 2.2.1 Stub Area
1. 将4、5类LSA过滤，即过滤OSPF外部路由信息；
2. 注入一条拥有默认路由的3类LSA到该区域。
> 配置建议：只有一个ABR；保证该区域所有 路由器均配置Stub属性；不允许有ASBR；不允许在Area 0；不允许有虚链路。
#### 2.2.2 Totally Stubby Area
1. 将3、4、5类LSA过滤，即过滤域间路由以及OSPF外部路由；
2. 注入一条拥有默认路由的3类LSA到该区域。
#### 2.2.3 NSSA Area
1. 将4，5类LSA过滤，即过滤OSPF非本区域重分发进入的外部路由信息；
2. 不会注入一条拥有默认路由的3类LSA到该区域；
3. 通过ASBR重分发进入OSPF的路由转化为7类（nssa-external）LSA，可以在NSSA区域内传递；
4. RID较大的ABR会将7类LSA转换成5类LSA在其他区域进行传递。
#### 2.2.4 Total NSSA Area
1. 将3，4，5类LSA过滤，即过滤域间路由以及OSPF非本区域重分发进入的外部路由信息；
2. 注入一条拥有默认路由的3类LSA到该区域；
3. 通过ASBR重分发进入OSPF的路由转化为7类（nssa-external）LSA，可以在NSSA区域内传递（同NSSA）；
4. RID较大的ABR会将7类LSA转换成5类LSA在其他区域进行传递（同NSSA）。
#### 2.2.5 4种区域对比
| 区域  | 过滤掉的LSA  | 拥有的LSA  |
| :------------: | :------------: | :------------: |
| Stub  | 4, 5  | 1, 2, 3  |
| Totally Stub  | 3, 4, 5  | 1, 2, 3(一条)  |
| NSSA  | 4, 5  | 1, 2, 3, 7  |
| Totally NSSA  | 3, 4, 5  | 1, 2, 3(一条), 7  |
## 3. 路由计算
### 3.1 路由表优先级
O（域内路由） > O IA（域间路由） > O E1/E2（重分发路由，LSA5） = O N1/N2（重分发路由，LSA7）
### 3 .2 路由计算
* 域内的每台路由器有完全一致的LSDB，并可以将自己作为root，根据Dijkstra计算路径。通过分段带宽，COST计算方式为(10^8)/(BW(bit/s))，可以通过命令auto-cost reference-bandwidth来修改10^8的值。
* E路由为外部路由重分发进入OSPF的路由，E1类型的路由会计算OSPF和外部的cost值，而E2只会计算OSPF外部的值
### 3.3 路由计算举例
* 拓扑如下所示，环回口的cost为1

`R1(11)↔(12)R2(13)↔(14)R3(15)↔(16)R4`

* 每个路由器有一个环回口，R1的环回口的地址为1.1.1.1

R1的路由表中

| 路由条目 | Metric |
| :------------: | :------------: |
| 1.1.1.1  | 0 |
| 12.1.1.0  | 0 |
| 2.2.2.2 | 1+11=12 |
| 3.3.3.3 | 1+13+11=25 |
|4.4.4.4 | 1+15+13+11=40 |
| 23.1.1.0 | 13+11=24 |
| 34.1.1.0 | 15+13+11=39 |

R4的路由表中

| 路由条目 | Metric |
| :------------: | :------------: |
| 4.4.4.4 | 0 |
| 34.1.1.0 | 0 |
| 1.1.1.1 | 1+12+14+16=43 |
| 2.2.2.2 | 1+14+16=31 |
| 3.3.3.3 | 1+16=17 |
| 12.1.1.0 | 12+14+16=42 |
| 23.1.1.0 | 14+16=30 |
* 如果R4的loopback接口是重分发进入的，并且指定重分发进入的metric-type为2，则在R1的路由表中，其cost为20（默认20）；
* 若其重分发metric-type为1，则cost为100 + 15 + 13 + 11 = 139
## 4. 邻接关系
### 4.1 必要条件
* 相同的Hello、Dead时间；
* 相同的Area；
* 相同的认证类型和密钥；
* 相同的STUB标识；
* 相同MTU；
* 相同网络类型。
### 4.2 7类邻接关系
1. Down，接口刚被宣告进入OSPF；
2. Init，收到了邻居发来的hello报文，但是双向通信还没有建立；
3. 2-way，收到一份neighbor字段有自己的RID的hello报文；
> MA网络中，第一台到达该状态的路由器宣布开始选择DR、BDR；
4. Exstart，交互三个不带LSA的DBD，选出Master/Slave。
> 接口MTU不一致会一直卡在这一状态。接口使用命令ip ospf mtu-ignore忽略MTU检查；
5. Exchange，Master发出带有LSA的DBD；
6. Loading，交互LSR、LSU以及LSAck；
7. Full，LSDB同步完成。
### 4.3 MA网络邻接关系
MA网络DR和BDR可以建立full邻接关系，others建立2-way邻接关系。
## 5. LSA
* 每30分钟发一次，且都有序列号，最大为0x80000001，最小为0x7fffffff。
* 当一个接口被宣告进入OSPF进程中，该端口会开始监听发往224.0.0.5的流量。MA网络中，DR和BDR会监听发往224.0.0.6的流量，DR Other利用224.0.0.6地址传递LSA，DR会将其进行综合，再利用224.0.0.5地址分发给大家。
### 5.1 Router LSA
* 通告者：每台属于一个区域的路由器都会通告一条；
* 传播范围：区域以内
* 内容：本地接口拓扑信息。
* MA网络中，会有DR的RID和本地接口的信息。Link-ID：为DR的RID；
* P2P网络中，会有两条链路信息，一种是P2P消息，包含有对端RID和本地接口信息，Link-ID为对端接口的地址；另一条是stub信息，会有链路的网络前缀和子网掩* 码，Link-ID为该链路的网络号。
### 5.2 Network LSA
* 通告者：DR
* 传播范围：区域内
* 内容：MA网络中所连接的路由器以及掩码
* Link-ID：DR的接口地址
### 5.3 Summary Network LSA
* 通告者：ABR
* 传播范围：除该区域以外的区域
* 内容：一条域间路由
* Link-ID：路由前缀
* ADV Router：ABR的RID
### 5.4 Summary ASB LSA
* 通告者：与ASBR在同一区域的ABR
* 传播范围：除该区域以外的区域
* 内容：描述ASBR所在位置
* Link-ID：ASBR的RID
* ADV Router：ABR，且会因跨区域而更改为本区域的ABR
### 5.5 External LSA
* 通告者：ASBR
* 传播范围：整个OSPF区域
* 内容：一条OSPF区域外路由条目
* Link-ID：路由前缀
* 查看边界路由器：show ip ospf border-routers
### 5.6 Group Membership LSA
### 5.7  NSSA External LSA
* 通告者：ASBR
* 传播范围：NSSA
* 内容：一条OSPF域外路由条目
## 6. 报文类型
1. Hello 用于建立和维护邻居关系。
> 时间间隔10s或者30s，取决于链路类型。乘以4为dead和wait时间。Hello时间可以修改，在接口下使用命令：ip ospf hello-interval 12，hello时间改为12秒，wait和dead时间自动改为48s；而单独修改wait和dead时间，hello时间不会跟着被修改。其还可以选择DR和BDR。
2. DBD 用于传递LSDB，其包含LSA的包头、使用隐式确认。DBD中的flag位，I->M->M/S。
3. LSR 链路状态请求，用LSU确认
4. LSU 链路状态更新，使用LSAck确认
5. LSAck 链路状态确认。
* 请参考：[OSPF报头及各种报文格式](http://blog.csdn.net/lycb_gz/article/details/9662965)
## 7. DR与BDR
MA网络中，第一台到达2-way状态的路由器宣布开始选择DR、BDR。
### 7.1 选择原则
1. 优先级较高的端口，默认为1，范围是0-255，0代表不参选DR、BDR；
2. 该接口的路由器有较高的RID
### 7.2 特点
1. DR、BDR具有非抢占性；
2. DR掉线之后，BDR成为DR，新的BDR需要在DR Other中选择；
3. 每个单独的MA网络，选择DR与BDR是单独进行的；
4. 如果一个MA网络中没DR、BDR，该网段中不会收发LSA；
## 8. 路由汇总
* 域间汇总：在ABR上部署，对3类LSA的汇总，命令：`area 0 range 0.0.0.0 0.0.0.0`。会生成Null 0路由；
* 域外汇总：在ASBR上部署，对5类LSA的汇总。命令：`summary-address 0.0.0.0 0.0.0.0`。会产生Null 0路由。
## 9. 连接非直连的普通区域和骨干区域
如何连接：area2 -- area 1 -- area 0
1. 两个OSPF进程相互重分布；
2. 使用隧道技术，Tunnel；
3. 使用OSPF虚拟链路：在两个ABR之间建立虚拟链路：area 2 virtual-link 1.1.1.1
## 10. 认证
* 链路级明文认证：接口下：`ip ospf authentication-key cisco`和`ip ospf authentication`
* 链路级密文认证：接口下：`ip ospf message-digest-key 13 md5 huawei`和`ip ospf authentication message-digest`
* 区域级明文认证：接口下：`ip ospf authentication-key h3c`，进程下：`area 0 authentication`
* 区域级密文认证：接口下：`ip ospf message-digest-key 12 md5 shenxinfu`，进程下：`ip ospf authentication message-digest`
* 虚链路级明文认证：进程下：`area 2 virtual-link 91.1.1.1 authentication-key cisco`和`area 2 virtual-link 91.1.1.1 authentication`
* 虚链路级密文认证：进程下：`area 2 virtual-link 91.1.1.1 message-digest-key 12 md5 cisco`和`area 2 virtual-link 91.1.1.1 authentication message-digest`