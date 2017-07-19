# 网络监控
监控方式有：SNMP、RRDTool、Cacti、Nagios、Remote script
* Cacti用于将RRDTool监控到的时间序列数据，进行展示。
* Nagios用于监控状态：on --> off

网络管理可以管理的要素有：故障管理、配置管理、审计管理、性能管理、安全管理。
## 1. SNMP
SNMP，Simple Network Management Protocol，简单网络管理协议，其支持网络管理系统，用以监测连接到网络上的设备是否有任何引起管理上关注的情况。应用层协议：UDP 161/162
### 1.1 基本组件
其由三个组件构成：网络管理系统（NMS，Network Management System），被管理设备和代理（Agent）。
- NMS：一个运行在管理节点上的软件，其定期会将被管设备发送处理器、内存状态等请求信息，这些请求信息会发送给被管设备的agent。
- Agent：一个运行在被管理设备上的软件模块，通过接受NMS发送来的请求，查询本地MIB之后，返回给NMS。

双方通过community进行通信，community有三类：read-only、read-write和trap。设备默认会有两类community，一个是public为read-only，一个是private为read-write。Trap：agent会主动发送消息给NMS，通常为故障信息。
### 1.2 版本及操作
* SNMP v1：get（获取指定OID信息）、getnext（获取指定叶子的父节点的OID以及其叶子节点的相关信息，）、set、getresponse（响应消息）、trap
* SNMP v2c，v3：getbulk（获取指定OID及其所有子节点的信息）、notification、inform、report
### 1.3 MIB
管理信息库（Management Information Base），描述全球唯一的资源。用点分十进制数标识，称为OID（Object Identifier）。
* 设备网络接口信息为1.3.6.1.2.1.2，Host管理OID为1.3.6.1.2.1.25
* 在/etc/snmp/snmpd.conf中会有可以查看的mib库
### 1.4 通信过程
![snmp_com](https://github.com/Minions1128/net_tech_notes/blob/master/img/snmp_com.jpg "snmp_com")
### 1.5 相关命令
Redhat中两个snmp软件包net-snmp（发包）以及net-snmp-utils（收包）
```
snmpwalk -v 2c -c public 127.0.0.1
```
## 2. RRDTool
### 2.1 名词解释
* RRD，Round Robin Database，轮询数据库，为环形数据库，分为许多扇形，数据会存在这些扇形里，每个扇形称之为time slot。当数据存满后，会将最初的数据覆盖，其数据库大小不会改变。
* RRA：Round Robin Archive，轮转归档信息，描述CDP聚合PDP的数量。
* 当抓取到数据时，先会放到PDP（Primary Data Point，主数据节点），将其进行聚合计算，得到CDP（Consolidation Data Point，聚合数据点）才会保存到time slot中。
### 2.2 相关命令
#### 2.2.1 创建数据库
```
rrd create filename \   # filename：保存文件的文件名
    [--start | -b start time] \     # --start：开始时间，默认10s之前
    [--step | -s step] \    # --step：接受数据的时间跨度
    [--no | -overwrite] \
    [DS:ds-name:DST:dst arguments] \
    [RRA:CF:cf argument]
# DS：指定数据源；
#   ds-name：数据源名称；
#   DST：对数据如何聚合，数据源类型有：
#     gauge，保存PDP精确数值；
#     counter，递增数据的相对值；
#     derive，任意数据的相对值；
#     absolute，与初始值的相对值；
#     compute，自定义计算；
#   dst arguments：
#     heartbeat（描述数据在某个时间内达到有效，如step为5s，数据在10s以内达到都有效）
#     min，max（描述可以接受值的范围）
# RRA：如何聚合，average，min，max，last；
#   CF：聚合参数：
#     xff（描述PDP比例为多大时，还可以进行计算CDP，unknown值会进行智能计算）
#     steps（聚合跨度）
#     rows（保存结果的数量）
```
举个例子
```
rrdtool create test.rrd --step 5 \ # 创建一个RRDTool文件名为test.rrd，每5s收集一次数据
    DS:testds:GAUGE:8:0:U        \ # 数据源名称为testds，保存的数据类型为GAUGE，
                                 \ # 数据在8s以内到达都有效，数值的范围是0到无穷大
    RRA:AVERAGE:0.5:1:17280      \ # 聚合方法为取平均数，50%的PDP为unknown时，
                                 \ # CDP为unknown，CDP对每1个PDP进行聚合，
                                 \ # 要保存17280(CDP)*5(s/PDP)*1(PDP/CDP)=1天
    RRA:AVERAGE:0.5:10:3456      \ # 聚合方法为取平均数，50%的PDP为unknown时，
                                 \ # CDP为unknown，CDP对每10个PDP进行聚合，
                                 \ # 要保存3456(CDP)*5(s/PDP)*10(PDP/CDP)=2天
    RRA:AVERAGE:0.5:100:1210     \ # 聚合方法为取平均数，50%的PDP为unknown时，
                                 \ # CDP为unknown，CDP对每100个PDP进行聚合，
                                 \ # 要保存1210(CDP)*5(s/PDP)*100(PDP/CDP)=7天
    rrdtool info test.rrd        \ # 查看该数据库文件格式
```
#### 2.2.2 填充数据
```
rrdtool {update | updatev} \    
    filename \  # filename：数据库文件
    [--template | -t ds-name[:ds-name[:…]]] \
    timestamp:time:value1[:value2[…]]   # timestamp：时间戳；
                                        # value1：对应第一个ds的值；
                                        # value2：对应第二个ds的值……
# template：指定ds的顺序，如：
# rrdtool create test.rrd DS:ds1 DS:ds2
# rrdtool update test.rrd N:30:40     #or rrdtool update test.rrd -t ds2:ds1 40:30
```
举个例子：
```
rrdtool update test.rrd N:$RANDOM
rrdtool fetch [-r 10] test.rrd AVERAGE      # 查看数据源[指定解析度为10的数据]
```
编写脚本：gen.sh
```
while true; do
  rrdtool update test.rrd N:$RANDOM
  sleep 5
done
bash -n gen.sh      #检查是否有语法错误
bash -x gen.sh      #让程序在前台执行
```
#### 2.2.3 绘图数据
```
rrdtool {graph | graphy} filename-pic [option…] \
    [data definetion] [data calculation]
option：[-s | --start time] [-e | --end time] \
    [-S | --step seconds] [-t | --title string] \
    [-v | --vertical-label string] [-w | --width pixels] \
    [-h | --height pixels] [-j | --only-graph] \
    [-D | --full-size-mode] [-a | --imgformat PNG|SVG|EPS|PDF] [13min]
data definetion：
    DEF（vname=rrdfile:ds-name:CF[:step =step][:start =time][:end =time]）
    CDEF
    VDEF
```
举个例子：
````
rrdtool graph a.png \   #画一个图，文件名为a.png
    -s 1494568250 \     #开始时间为1494568250
    DEF:vartest5=test.rrd:testds:AVERAGE:step=5 \   
    \ # 定义DEF：vartest5，其数据库为test.rrd，聚合方法为AVERAGE，聚合度为5
    DEF:vartest50=test.rrd:testds:AVERAGE:step=50 \
    \ # 定义DEF：vartest50，其数据库为test.rrd，聚合方法为AVERAGE，聚合度为50
    LINE1:vartest5#0000FF:"5 sec" \     # 利用DEF：vartest5绘制线条，
                                    \   # 颜色为蓝色，显式为‘5 sec’
    LINE1:vartest50#FF0000:"50 sec" \   # 利用DEF：vartest50绘制线条，
                                        # 颜色为红色，显式为‘50 sec’
````
### 2.3 完整的例子
每个3s钟抓取一次ens32口的发出的字节数，并且将其绘制成表
创建数据库：
rrdtool create ifrx.rrd --step 3 \
DS:ifrxds:GAUGE:5:0:U \
RRA:AVERAGE:0.5:1:28800 \
RRA:AVERAGE:0.5:10:2880 \
RRA:MAX:0.5:10:100
撰写脚本，输入数据：
while true; do
  RX=`/sbin/ifconfig ens32 | grep "RX bytes" | awk -F'[ :]+' '{print $4}'`
  rrdtool update ifrx.rrd N:$RX
  sleep 2
done
绘制图像：
rrdtool graph ifrx.png \
-s 1494576879 -t "if ens32" \
-v "if ens32/3" \
DEF:if3=ifrx.rrd:ifrxds:AVERAGE:step=3 \
LINE1:if3#ff0000:"if3"
3．  CACTI
Cacti是基于RRDTool的一款展示工具，可以建立，周期性的更新数据，并生成图，支持多种模版来展示数据，支持插件，thold具有报警功能。
安装cacti：http://os.51cto.com/art/201404/434909_all.htm
3.1 收集方法
分为数据查询和数据输入方法。数据查询使用xml语言。数据输入方法使用命令或者脚本，使用的脚本是需要指定如何获取数据，并且获取到的数据经过处理后要按照规定输入：TAG:data TAG:data
3.2 主要添加步骤
add device  add graph  add data source  add graph trees
3.3 创建模版
1，撰写脚本，输出格式为：【TAG1:data1 TAG2:data2】；2，添加数据收集方法（Data Input Methods）；3，创建数据模版（Data Template）&数据源（Data Source）；4，创建图像模版（Graph Template）&图片（Graph Management）
3.4 报警插件
thold-v0.4.9-3.tgz    settings-v0.71-1.tgz







