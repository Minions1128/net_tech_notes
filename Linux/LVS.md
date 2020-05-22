# LVS

## LB Cluster概述

- LB Cluster的实现:
    - 硬件: F5 Big-IP, Citrix Netscaler, A10
    - 软件:
        - lvs: Linux Virtual Server
        - nginx
        - haproxy
        - ats: apache traffic server
        - perlbal
        - pound

- 基于工作的协议层次划分:
    - 传输层(通用): (DPORT)
        - lvs:
        - nginx: (stream)
        - haproxy: (mode tcp)
    - 应用层(专用): (自定义的请求模型分类) roxy server:
        - http: nginx(http), httpd, haproxy(mode http), ...
        - fastcgi: nginx, httpd, ...
        - mysql: ProxySQL, ...

- 会话保持:
    - (1) session sticky
        - Source IP
        - Cookie
    - (2) session replication;
        - session cluster
    - (3) session server

## Linux Virtual Server

- iptables/netfilter:
    - iptables: 用户空间的管理工具;
    - netfilter: 内核空间上的框架;
        - 流入: PREROUTING --> INPUT
        - 流出: OUTPUT --> POSTROUTING
        - 转发: PREROUTING --> FORWARD --> POSTROUTING
    - DNAT: 目标地址转换; PREROUTING;
    - SNAT: 源地址转换; POSTROUTING;
    - LVS: PREROUTING --> INPUT --> POSTROUTING

- lvs: ipvsadm/ipvs
    - ipvsadm: 用户空间的命令行工具, 规则管理器, 用于管理集群服务及相关的RealServer;
    - ipvs: 工作于内核空间的netfilter的INPUT钩子之上的框架;

- lvs集群类型中的术语:
    - vs: Virtual Server, Director, Dispatcher, Balancer
    - rs: Real Server, upstream server, backend server
    - CIP: Client IP, VIP: Virtual serve IP, RIP: Real server IP, DIP: Director IP
    - CIP <--> VIP == DIP <--> RIP

### lvs集群的类型

- nat, dr, tun, fullnat

- lvs-nat: 多目标IP的DNAT, 通过将请求报文中的目标地址和目标端口修改为某挑出的RS的RIP和PORT实现转发;
    - (1) RIP和DIP必须在同一个IP网络, 且应该使用私网地址; RS的网关要指向DIP;
    - (2) 请求报文和响应报文都必须经由Director转发; Director易于成为系统瓶颈;
    - (3) 支持端口映射, 可修改请求报文的目标PORT;
    - (4) vs必须是Linux系统, rs可以是任意系统;
    - 报文路径: CIP:VIP --(Director)--> CIP:RIP --(RS)--> RIP:CIP --(Director)--> VIP:CIP

- lvs-dr: Direct Routing, 直接路由; 通过为请求报文重新封装一个MAC首部进行转发, 源MAC是DIP所在的接口的MAC, 目标MAC是某挑选出的RS的RIP所在接口的MAC地址; 源IP/PORT, 以及目标IP/PORT均保持不变; Director和各RS都得配置使用VIP;
    - (1) 确保前端路由器将目标IP为VIP的请求报文发往Director:
        - (a) 在前端网关做静态绑定;
        - (b) 在RS上使用arptables;
        - (c) 在RS上修改内核参数以限制arp通告及应答级别;
            - arp_announce
            - arp_ignore
    - (2) RS的RIP可以使用私网地址, 也可以是公网地址; RIP与DIP在同一IP网络; RIP的网关不能指向DIP, 以确保响应报文不会经由Director;
    - (3) RS跟Director要在同一个物理网络;
    - (4) 请求报文要经由Director, 但响应不能经由Director, 而是由RS直接发往Client;
    - (5) 不支持端口映射;
    - 报文路径: CIP:VIP --(Director)--> CIP:VIP --(RS)--> VIP:CIP
    - 数据帧结构: CMAC:VMAC --(Director)--> DMAC:RMAC --(RS)--> RMAC:GW-MAC

- lvs-tun: 转发方式: 不修改请求报文的IP首部(源IP为CIP, 目标IP为VIP), 而是在原IP报文之外再封装一个IP首部(源IP是DIP, 目标IP是RIP), 将报文发往挑选出的目标RS; RS直接响应给客户端(源IP是VIP, 目标IP是CIP);
    - (1) DIP, VIP, RIP都应该是公网地址;
    - (2) RS的网关不能, 也不可能指向DIP;
    - (3) 请求报文要经由Director, 但响应不能经由Director;
    - (4) 不支持端口映射;
    - (5) RS的OS得支持隧道功能;
    - CIP -- VIP, DIP(tun CIP) --> RIP(tun VIP), VIP --> CIP

- lvs-fullnat: 通过同时修改请求报文的源IP地址和目标IP地址进行转发;
    - (1) VIP是公网地址, RIP和DIP是私网地址, 且通常不在同一IP网络; 因此, RIP的网关一般不会指向DIP;
    - (2) RS收到的请求报文源地址是DIP, 因此, 只能响应给DIP; 但Director还要将其发往Client;
    - (3) 请求和响应报文都经由Director;
    - (4) 支持端口映射;
    - 注意: 此类型默认不支持;
    - CIP --> VIP, DIP(nat CIP) --> RIP(nat VIP), VIP --> CIP

- 总结:
    - lvs-nat, lvs-fullnat: 请求和响应报文都经由Director;
        - lvs-nat: RIP的网关要指向DIP;
        - lvs-fullnat: RIP和DIP未必在同一IP网络, 但要能通信;
    - lvs-dr, lvs-tun: 请求报文要经由Director, 但响应报文由RS直接发往Client;
        - lvs-dr: 通过封装新的MAC首部实现, 通过MAC网络转发;
        - lvs-tun: 通过在原IP报文之外封装新的IP首部实现转发, 支持远距离通信;

### 调度

- ipvs scheduler: 根据其调度时是否考虑各RS当前的负载状态, 可分为
    - 静态方法: 仅根据算法本身进行调度;
        - RR: roundrobin, 轮询;
        - WRR: Weighted RR, 加权轮询;
        - SH: Source Hashing, 实现session sticky, 源IP地址hash; 将来自于同一个IP地址的请求始终发往第一次挑中的RS, 从而实现会话绑定;
        - DH: Destination Hashing; 目标地址哈希, 将发往同一个目标地址的请求始终转发至第一次挑中的RS, 典型使用场景是正向代理缓存场景中的负载均衡;
    - 动态方法: 主要根据每RS当前的负载状态及调度算法进行调度; Overhead=
        - LC: least connections `Overhead=activeconns*256+inactiveconns`
        - WLC: Weighted LC `Overhead=(activeconns*256+inactiveconns)/weight`
        - SED: Shortest Expection Delay `Overhead=(activeconns+1)*256/weight`
        - NQ: Never Queue
        - LBLC: Locality-Based LC, 动态的DH算法;
        - LBLCR: LBLC with Replication, 带复制功能的LBLC;

### ipvsadm/ipvs

- 集群和集群之上的各RS是分开管理的;
    - 集群定义
    - RS定义

- ipvs: `grep -i -C 10 "ipvs" /boot/config-VERSION-RELEASE.x86_64`

- 支持的协议: TCP,  UDP,  AH,  ESP,  AH_ESP,  SCTP;

- ipvs集群:
    - 集群服务
    - 服务上的RS

- 程序包: ipvsadm
    - Unit File: ipvsadm.service
    - 主程序: /usr/sbin/ipvsadm
    - 规则保存工具: /usr/sbin/ipvsadm-save
    - 规则重载工具: /usr/sbin/ipvsadm-restore
    - 配置文件: /etc/sysconfig/ipvsadm-config

- ipvsadm 命令核心功能:
    - 集群服务管理: 增、删、改;
    - 集群服务的RS管理: 增、删、改;
    - 查看:

```sh
ipvsadm -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine] [-b sched-flags]
ipvsadm -D -t|u|f service-address
ipvsadm -C
ipvsadm -R
ipvsadm -S [-n]
ipvsadm -a|e -t|u|f service-address -r server-address [options]
ipvsadm -d -t|u|f service-address -r server-address
ipvsadm -L|l [options]
ipvsadm -Z [-t|u|f service-address]
```

- 管理集群服务: 增、改、删;
    - 增、改: `ipvsadm -A|E -t|u|f service-address [-s scheduler] [-p [timeout]]`
        - [-s scheduler]: 指定集群的调度算法, 默认为wlc;
    - 删: `ipvsadm -D -t|u|f service-address`
        - service-address: -t|u|f:
            - -t: TCP协议的端口, VIP:TCP_PORT
            - -u: UDP协议的端口, VIP:UDP_PORT
            - -f: firewall MARK, 是一个数字;

- 管理集群上的RS: 增、改、删;
    - 增、改: `ipvsadm -a|e -t|u|f service-address -r server-address [-g|i|m] [-w weight]`
    - 删: `ipvsadm -d -t|u|f service-address -r server-address`
        - server-address: `rip[:port]`
    - 选项:
        - lvs类型:
            - -g: gateway, dr类型
            - -i: ipip, tun类型
            - -m: masquerade, nat类型
        - -w weight: 权重;

- 清空定义的所有内容: `ipvsadm -C`

- 查看: `ipvsadm -L|l [options]`
    - --numeric, -n: numeric output of addresses and ports
    - --exact: expand numbers (display exact values)
    - --connection, -c: output of current IPVS connections
    - --stats: output of statistics information
    - --rate : output of rate information

- 保存和重载:
    - ipvsadm -S = ipvsadm-save
    - ipvsadm -R = ipvsadm-restore

- 负载均衡集群设计时要注意的问题:
    - (1) 是否需要会话保持;
    - (2) 是否需要共享存储;
        - 共享存储: NAS,  SAN,  DS(分布式存储)
        - 数据同步:
        - whats more: rsync+inotify实现数据同步

- lvs-nat 设计要点:
    - (1) RIP与DIP在同一IP网络, RIP的网关要指向DIP;
    - (2) 支持端口映射;
    - (3) Director要打开核心转发功能;
    - whats more: 负载均衡两个php应用(wordpress, discuzx); 测试: (1) 是否需要会话保持; (2) 是否需要共享存储;

- lvs-dr:
    - dr模型中, 各主机上均需要配置VIP, 解决地址冲突的方式有三种:
        - (1) 在前端网关做静态绑定;
        - (2) 在各RS使用arptables;
        - (3) 在各RS修改内核参数, 来限制arp响应和通告的级别;
            - 限制响应级别: arp_ignore
                - 0: 默认值, 表示可使用本地任意接口上配置的任意地址进行响应;
                - 1: 仅在请求的目标IP配置在本地主机的接收到请求报文接口上时, 才给予响应;
            - 限制通告级别: arp_announce
                - 0: 默认值, 把本机上的所有接口的所有信息向每个接口上的网络进行通告;
                - 1: 尽量避免向非直接连接网络进行通告;
                - 2: 必须避免向非本网络通告;

- RS的预配置脚本:

```sh
#!/bin/bash
#
vip=10.1.0.5
mask='255.255.255.255'

case $1 in
start)
    echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce

    ifconfig lo:0 $vip netmask $mask broadcast $vip up
    route add -host $vip dev lo:0
    ;;
stop)
    ifconfig lo:0 down

    echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce

    ;;
*)
    echo "Usage $(basename $0) start|stop"
    exit 1
    ;;
esac
```

- VS的配置脚本:

```sh
#!/bin/bash
#
vip='10.1.0.5'
iface='eno16777736:0'
mask='255.255.255.255'
port='80'
rs1='10.1.0.7'
rs2='10.1.0.8'
scheduler='wrr'
type='-g'

case $1 in
start)
    ifconfig $iface $vip netmask $mask broadcast $vip up
    iptables -F

    ipvsadm -A -t ${vip}:${port} -s $scheduler
    ipvsadm -a -t ${vip}:${port} -r ${rs1} $type -w 1
    ipvsadm -a -t ${vip}:${port} -r ${rs2} $type -w 1
    ;;
stop)
    ipvsadm -C
    ifconfig $iface down
    ;;
*)
    echo "Usage $(basename $0) start|stop"
    exit 1
    ;;
esac
```

- whats more:
    - vip与dip/rip不在同一网段的实验环境设计及配置实现;
    - lvs的详细应用: 讲清楚类型、调度方法; 并且给出nat和dr类型的设计拓扑及具体实现;

- FWM: FireWall Mark, netfilter:
    - target: MARK, This  target  is  used  to set the Netfilter mark value associated with the packet.
        - --set-mark value

- 借助于防火墙标记来分类报文, 而后基于标记定义集群服务; 可将多个不同的应用使用同一个集群服务进行调度;

- 打标记方法(在Director主机): `iptables -t mangle -A PREROUTING -d $vip -p $proto --dport $port -j MARK --set-mark NUMBER`

- 基于标记定义集群服务: `ipvsadm -A -f NUMBER [options]`

- lvs persistence: 持久连接
    - 持久连接模板: 实现无论使用任何调度算法, 在一段时间内, 能够实现将来自同一个地址的请求始终发往同一个RS; `ipvsadm -A|E -t|u|f service-address [-s scheduler] [-p [timeout]]`
    - port Affinity:
        - 每端口持久: 每个端口对应定义为一个集群服务, 每集群服务单独调度;
        - 每防火墙标记持久: 基于防火墙标记定义集群服务; 可实现将多个端口上的应用统一调度, 即所谓的port Affinity;
        - 每客户端持久: 基于0端口定义集群服务, 即将客户端对所有应用的请求统统调度至后端主机, 必须定义为持久模式;

- 保存及重载规则:
    - 保存: 建议保存至`/etc/sysconfig/ipvsadm`
        - `ipvsadm-save > /PATH/TO/IPVSADM_FILE`
        - `ipvsadm -S > /PATH/TO/IPVSADM_FILE`
        - `systemctl stop ipvsadm.service`
    - 重载:
        - `ipvsadm-restore < /PATH/FROM/IPVSADM_FILE`
        - `ipvsadm -R < /PATH/FROM/IPVSADM_FILE`
        - `systemctl restart ipvsadm.service`

- 考虑:
    - (1) Director不可用, 整个系统将不可用; SPoF
        - 解决方案: 高可用
            - keepalived
            - heartbeat/corosync
    - (2) 某RS不可用时, Director依然会调度请求至此RS;
        - 解决方案: 对各RS的健康状态做检查, 失败时禁用, 成功时启用;
                - keepalived
                - heartbeat/corosync, ldirectord
        - 检测方式:
            - (a) 网络层检测;
            - (b) 传输层检测, 端口探测;
            - (c) 应用层检测, 请求某关键资源;

- ldirectord: Daemon to monitor remote services and control Linux Virtual Server. ldirectord is a daemon to monitor and administer real servers in a cluster of load balanced virtual servers. ldirectord typically is started from heartbeat but can also be run from the command line. 配置示例:

```sh
checktimeout=3
checkinterval=1
fallback=127.0.0.1:80
autoreload=yes
logfile="/var/log/ldirectord.log"
quiescent=no
virtual=5
    real=172.16.0.7:80 gate 2
    real=172.16.0.8:80 gate 1
    fallback=127.0.0.1:80 gate
    service=http
    scheduler=wrr
    checktype=negotiate
    checkport=80
    request="index.html"
    receive="CentOS"
```

- 补充: 共享存储
    - NAS: Network Attached Storage
        - nfs/cifs
        - 文件系统接口
    - SAN: Storage Area Network, “块”接口
