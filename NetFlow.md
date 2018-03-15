# NetFlow & sFlow
## 概述
* As defined by the IETF.  A flow is a sequence of packets from a sending application to a receiving application. 
* sFlow技术使用采样来实现可扩展性，其包括执行两种采样：1，数据包或者应用层操作的随机采样，2，基于时间的计数采样。是将数据流采用上述两种采样方式发送给服务器来分析，最后得出流量结果。其可以部署在硬件或者软件上。软件搭建以及简单使用参考：[http://www.muzixing.com/pages/2014/11/21/sflowru-men-chu-she.html](http://www.muzixing.com/pages/2014/11/21/sflowru-men-chu-she.html)
* NetFlow是一项真正的技术，其在硬件上抓去流量，抓去的流量可以按照7元组的方式来进行抓去：源端口、ToS、源IP、目的IP、源端口、目的端口、IP协议。基本原理和sFlow类似。
* 基于定义的采样率，随机采样平均N个数据包/操作中的一个。这种取样不能提供100％准确的结果，但它确实提供了可量化准确度的结果。
* 具体分析参考：[https://www.plixer.com/blog/netflow-vs-sflow-2/netflow-vs-sflow-which-is-better/](https://www.plixer.com/blog/netflow-vs-sflow-2/netflow-vs-sflow-which-is-better/)

## 配置举例

一、Cisco Netflow配置命令
、常规路由器上配置
在路由器上开启netflow统计的过程和例子：
开启过程：
Router(config)# interface f0/0         进入接口
Router(config-if)# ip route-cache flow   启用netflow
Router(config-if)# exit
Router(config)#
 ip flow-cache timeout active 30 设定netflow记录活动超时间
 ip flow-export source lookback 0
 ip flow-export version 5      设定netflow的版本号
 ip flow-export destination [ip-add][udp-port]  把netflow信息输出到指定的工作站
 ip flow-cache entries   设定netflow记录缓冲区的入口数
Router(config)# exit
Router# sh ip flow export     查看netflow的配置信息

二、例子：
1.配置第一块网卡（要监控几个接口，就重复配置这个步骤）
Router(config)# interface f0/0
Router(config-if)# ip route-cache flow
Router(config-if)# exit
2.配置netflow输出目标，即采集服务器的ip和监听端口
Router(config)# ip flow-export destination 10.21.8.38 9996
3.配置输出版本
Router(config)# ip flow-export version 5
4.配置生成告警和显示故障排除数据时间
 （默认为30分钟，故可不配，若需改变则可输入别的数据）
Router(config)# ip flow-cache timeout active 1
5.配置netflow的数据源（一般交换机上建议配置loopback 0）
Router(config)#  ip flow-export source loopback 0
6.保存配置
Router# wr
7.查看netflow的配置信息
Router(config)# exit
Router(config)# sh ip flow export
8.查看netflow采集到的信息
Router(config)# sh ip cache flow
Router(config)# sh ip cache verbose flow
附加：
一.cisco ASA
1.配置netflow输出目标，即采集服务器的ip和监听端口
(config)#flow-export destination insideNetFlow Analyzer serverIP address 9996
(config)#flow-export template timeout-rate1    默认为30分钟
(config)#flow-export delay flow-create60
2. 禁用日志生成，保证数据库仅仅记录少量的必要信息。默允许netflow的流量
(config)# logging flow-export-syslogs disable
(config)#access-list netflow-export extended permit ipany any  或者[host 10.1.1.1 host 172.16.57.9]
3.配置策略
(config)#class-mapnetflow-export-class
(config-cmap)#matchaccess-list netflow-export
(config)#policy-mapnetflow-export-policy
(config-pmap)#classnetflow-export-class
(config-pmap-c)#flow-export event-typealldestinationNetFlow Analyzer server IP
4.应用
(config)# service-policy netflow-export-policy global
二．关于Cisco 6509/7209 交换机Netflow的配置    
    Netflow 在6500和7209 交换机上配置和路由器上配置有所不同，在公司开发Netflow的应用上，发现现场工程师基本没有配置对，导致流量出不来。下面列出配置信息；CATOS的配置也的参考该配置
1、首先看看Netflow配置是否正常起来：
Switch# show mls nde
一般看到都是Netflow Data Export disabled这说明Netflow都没有起来。
参看Cisco 《Configuring NetFlow Data Export》 PDf文档，默认是Disabled的
2、启动netflow
Switch(config)# mls netflow
3、启动netflow 的双向流量
Switch(config)# mls flow ip destination-source
4、启动NDE发送以及发送版本
Switch(config)# mls nde sender [version {5 | 7}]
如果只输入mls nde sender 系统默认启用的是版本7，如果需要版本5，则mls nde sender version 5 ，目前版本能配的是5或7，这两个版本WEB均能出现正常的数据。
对于Cisco IOS 12.17以下版本的交换机，只有版本7。
5、进入VLAN，启动接口Netflow（如果在物理接口上其3层，则直接进入物理接口）。
Switch(config)# interface vlan 5
Switch(config-if)# ip flow-export ingress
Switch(config-if)# ip route-cache flow
6、配置Netflow的数据源，如果没有配置Loopback的接口，可以采用物理接口，建议配置Loopback接口
Switch(config)# ip flow-export source loopback 0
7、检测
Switch# show mls nde （能看到如下的信息，而且明确Netflow Data Export enabled）
Netflow Data Export enabled
Exporting flows to 10.110.10.254 (9991)
Exporting flows from 10.16.68.72 (55425)
Version: 5
Include Filter not configured
Exclude Filter is:
Total Netflow Data Export Packets are:
49 packets, 0 no packets, 247 records
Total Netflow Data Export Send Errors:
IPWRITE_NO_FIB = 0
IPWRITE_ADJ_FAILED = 0
IPWRITE_PROCESS = 0
Switch(config)# show mls netfow ip
看到大量的流量信息，大量的滚屏信息。
H3C:
 sflow agent ip 设备管理IP
 sflow collector 1 ip 10.21.8.38 port 9996
接口下配置 
 sflow flow collector 1
 sflow sampling-rate 4000
 sflow counter collector 1
 sflow counter interval 120
Juniper交换机（需要在服务器上修改采样率）:
set protocols sflow agent-id 10.50.0.254
set protocols sflow polling-interval 60
set protocols sflow sample-rate ingress 4000
set protocols sflow sample-rate egress 4000
set protocols sflow collector 10.21.8.38 udp-port 9996
set protocols sflow interfaces 接口名
juniper防火墙
set interfaces reth1 unit 0 family inet sampling input
set interfaces reth1 unit 0 family inet sampling output
set forwarding-options sampling input rate 4000
set forwarding-options sampling family inet output flow-server 10.21.8.38 port 9996
