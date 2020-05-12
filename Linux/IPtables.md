# IPtables

## 概述

- Firewall：防火墙，隔离工具；工作于主机或网络边缘，对于进出本主机或本网络的报文根据事先定义的检查规则作匹配检测，对于能够被规则匹配到的报文作出相应处理的组件。

- Linux防火墙发展：
    - ipfw (firewall framework)
    - ipchains (firewall framework)
    - IPtables(netfilter)
        - netfilter：kernel
        - IPtables：rules until
    - nftables

- FirewallD：[CentOS 上的 FirewallD 简明指南](https://linux.cn/article-8098-1.html "CentOS 上的 FirewallD 简明指南")

- hook function（链（内置））：
    - PREROUTING
    - INPUT
    - FORWARD
    - OUTPUT
    - POSTROUTING

- 功能（优先级由高到低）：
    - **raw**：该表有较高优先级，为了不再让IPtables做数据包的链接跟踪处理，可以关闭nat表上启用的连接追踪机制，提高性能，包含PREROUTING链和OUTPUT链上
    - **mangle**：该表可以拆解报文，对报文做出修改（如，ToS、CoS、QoS、TTL等），并重新封装起来，包含：PREROUTING、INPUT、FORWARD、OUTPUT、POSTROUTING五个表链。
    - **nat**：用于修改源IP或目标IP，也可以改端口，包括PREROUTING（刚到达本机，在路由转发前的数据包，处理DNAT）、POSTROUTING（即将离开本机的数据包，处理SNAT）、OUTPUT（处理本机产生的数据包）。
    - **filter**：该表有包过滤、防火墙的作用，由INPUT（inbound流量），OUTPUT（outbound流量），FORWARD（转发流量）表链组成。

- 表执行过程

[![iptables.proc](https://github.com/Minions1128/net_tech_notes/blob/master/img/iptables.proc.png "iptables.proc")](https://github.com/Minions1128/net_tech_notes/blob/master/img/iptables.proc.png "iptables.proc")

- 报文流向：
    - 流入本机：PREROUTING --> INPUT
    - 由本机流出：OUTPUT --> POSTROUTING
    - 转发：PREROUTING --> FORWARD --> POSTROUTING


## IPtables规则

- 组成部分：根据规则匹配条件来尝试匹配报文，一旦匹配成功，就由规则定义的处理动作作出处理
    - 匹配条件：
        - 基本匹配条件：内建
        - 扩展匹配条件：由扩展模块定义；
    - 处理动作：
        - 基本处理动作：内建
        - 扩展处理动作：由扩展模块定义；
        - 自定义处理机制：自定义链

- IPtables的链：
    - 内置链：对应于hook function
    自定义链接：用于内置链的扩展和补充，可实现更灵活的规则管理机制；

- 添加规则时的考量点：
    - (1) 要实现哪种功能：判断添加到哪个表上；
    - (2) 报文流经的路径：判断添加到哪个链上；

- 链：链上的规则次序，即为检查的次序；因此，隐含一定的应用法则：
    - (1) 同类规则（访问同一应用），匹配范围小的放上面；
    - (2) 不同类的规则（访问不同应用），匹配到报文频率较大的放在上面；
    - (3) 将那些可由一条规则描述的多个规则合并起来；
    - (4) 设置默认策略；


## IPtables

- 高度模块化，由诸多扩展模块实现其检查条件或处理动作的定义；
    - `/usr/lib64/xtables/`
        - IPv6：`libip6t_`
        - IPv4：`libipt_`, `libxt_`

- SYNOPSIS
    ```
    iptables [-t table] {-A|-C|-D} chain rule-specification
    ip6tables [-t table] {-A|-C|-D} chain rule-specification
    iptables [-t table] -I chain [rulenum] rule-specification
    iptables [-t table] -R chain rulenum rule-specification
    iptables [-t table] -D chain rulenum
    iptables [-t table] -S [chain [rulenum]]
    iptables [-t table] {-F|-L|-Z} [chain [rulenum]] [options...]
    iptables [-t table] -N chain
    iptables [-t table] -X [chain]
    iptables [-t table] -P chain target
    iptables [-t table] -E old-chain-name new-chain-name
    rule-specification = [matches...] [target]
    match = -m matchname [per-match-options]
    target = -j targetname [per-target-options]
    ```

- 规则格式：`iptables [-t table] COMMAND chain [-m matchname [per-match-options]] -j targetname [per-target-options]`
    - -t table：raw, mangle, nat, [filter]
    - COMMAND：
        - 链管理：
            - -N：new, 自定义一条新的规则链；`iptables -N asdf`
            - -P：Policy，设置默认策略；对filter表中的链而言，其默认策略有：
                - ACCEPT：接受
                - DROP：丢弃
                - REJECT：拒绝
                - `iptables -P FORWARD DROP`
            - -E：重命名自定义链；引用计数不为0的自定义链不能够被重命名，也不能被删除；
                - `iptables -E asdf asdff`
            - -X：delete，删除自定义的规则链；
                - `iptables -E asdf asdff`
                - 注意：仅能删除用户自定义的，引用计数为0的空的链；
        - 规则管理：
            - -A：append，追加；
            - -I：insert, 插入，要指明位置，省略时表示第一条；
            - -D：delete，删除；
                - (1) 指明规则序号；
                - (2) 指明规则本身；
            - -R：replace，替换指定链上的指定规则；
            - -F：flush，清空指定的规则链；`iptables -F [chain]`
            - -Z：zero，置零；
                - IPtables的每条规则都有两个计数器：
                    - (1) 匹配到的报文的个数；
                    - (2) 匹配到的所有报文的大小之和；
        - 查看：
            - -L：list, 列出指定鏈上的所有规则；
            - -n：numberic，以数字格式显示地址和端口号；
            - -v：verbose，详细信息；-vv, -vvv，显示更详细的信息
            - -x：exactly，显示计数器结果的精确值；
            - --line-numbers：显示规则的序号；
            - 一般写作：
                - `iptables -vnL`
                - `iptables [-t nat] -[vnx]L [INPUT] [--line-numbers]`
    - chain：PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING
    - 匹配条件：
        - 基本匹配条件：无需加载任何模块，由IPtables/netfilter自行提供；
            - [!] -s, --source address[/mask][,...]：检查报文中的源IP地址是否符合此处指定的地址或范围；
                - `iptables -A INPUT -s 172.16.50.0/24 -d 10.0.8.34 -p tcp -j ACCEPT`
            - [!] -d, --destination address[/mask][,...]：检查报文中的目标IP地址是否符合此处指定的地址或范围；
            - [!] -p, --protocol protocol
                - protocol: tcp, udp, udplite, icmp, icmpv6,esp, ah, sctp, mh or  "all", {tcp|udp|icmp}
            - [!] -i, --in-interface name：数据报文流入的接口；只能应用于数据报文流入的环节，只能应用于PREROUTING，INPUT和FORWARD链；
            - [!] -o, --out-interface name：数据报文流出的接口；只能应用于数据报文流出的环节，只能应用于FORWARD、OUTPUT和POSTROUTING链；
        - 扩展匹配条件：
            - 隐式扩展：在使用-p选项指明了特定的协议时，无需再同时使用-m选项指明扩展模块的扩展机制；不需要手动加载扩展模块；因为它们是对协议的扩展，所以，但凡使用-p指明了协议，就表示已经指明了要扩展的模块；
                - tcp：
                    - [!] --source-port, --sport port[:port]：匹配报文的源端口；可以是端口范围；
                        - `iptables -I INPUT 1 -s 172.16.0.0/16 -d 172.16.0.67 -p tcp --dport 22 -j ACCEPT`
                    - [!] --destination-port,--dport port[:port]：匹配报文的目标端口；可以是端口范围；
                        - `iptables -I OUTPUT 1 -s 172.16.0.67 -d 172.16.0.0/16 -p tcp --sport 22 -j ACCEPT`
                    - [!] --tcp-flags mask comp
                        - mask is the flags which we should examine, written as a comma-separated list, 例如`SYN,ACK,FIN,RST`
                        - comp is a comma-separated list of flags which must be set，例如`SYN`
                        - 例如：`--tcp-flags SYN,ACK,FIN,RST SYN`表示，要检查的标志位为SYN, ACK, FIN, RST四个，其中SYN必须为1，余下的必须为0；
                    - [!] --syn：用于匹配第一次握手，相当于`--tcp-flags SYN,ACK,FIN,RST SYN`；
                - udp
                    - [!] --source-port, --sport port[:port]：匹配报文的源端口；可以是端口范围；
                    - [!] --destination-port,--dport port[:port]：匹配报文的目标端口；可以是端口范围；
                - icmp
                    - [!] --icmp-type {type[/code]|typename}
                        - echo-request：8
                        - echo-reply：0
                    - 只允许本机ping其他主机，不允许其他ping本机：
                        - `iptables -I OUTPUT 1 -s 172.16.0.67 -p icmp --icmp-type 8 -j ACCEPT`
                        - `iptables -I INPUT 1 -d 172.16.0.67 -p icmp --icmp-type 0 -j ACCETP`
            - 显式扩展：必须使用[-m matchname [per-match-options]]选项指明要调用的扩展模块的扩展机制；
                - 1、multiport: This module matches a set of source or destination ports. Up to 15 ports can be specified. A port range (port:port) counts as two ports. It can only be used in conjunction with one of the following protocols: tcp, udp, udplite(轻量级用户数据包协议), dccp(数据拥塞控制协议) and sctp(流控制传输协议). 以离散或连续的 方式定义多端口匹配条件，最多15个；
                    - [!] --source-ports,--sports port[,port|,port:port]...：指定多个源端口；
                    - [!] --destination-ports,--dports port[,port|,port:port]...：指定多个目标端口；
                    - `# iptables -I INPUT -d 172.16.0.7 -p tcp -m multiport --dports 22,80,139,445,3306 -j ACCEPT`
                - 2、iprange: 以连续地址块的方式来指明多IP地址匹配条件；
                    - [!] --src-range from[-to]
                    - [!] --dst-range from[-to]
                    - `# iptables -I INPUT -d 172.16.0.7 -p tcp -m multiport --dports 22,80,139,445,3306 -m iprange --src-range 172.16.0.61-172.16.0.70 -j REJECT`
                - 3、time: This matches if the packet arrival time/date is within a given range.
                    - --timestart hh:mm[:ss] 和 --timestop hh:mm[:ss]
                    - [!] --weekdays day[,day...] 和 [!] --monthdays day[,day...]
                    - --datestart YYYY[-MM[-DD[Thh[:mm[:ss]]]]] 和 --datestop YYYY[-MM[-DD[Thh[:mm[:ss]]]]]
                    - --kerneltz：使用内核配置的时区而非默认的UTC
                    - `iptables -I INPUT -d 172.16.0.67 -p tcp --dport 23 -m time --timestart 10:00:00 --timestop 17:00:00 --weekdays 1,2,3,4,5 --kerneltz -j ACCETP`
                - 4、string: This modules matches a given string by using some pattern matching strategy.
                    - --algo {bm|kmp}
                    - [!] --string pattern
                    - [!] --hex-string pattern
                    - --from offset
                    - --to offset
                    - `# iptables -I OUTPUT -m string --algo bm --string "porn" -j REJECT`
                - 5、connlimit: Allows  you  to  restrict  the  number  of parallel connections to a server per client IP address (or client address block).
                    - --connlimit-upto n：
                    - --connlimit-above n：
                    - `# IPtables -I INPUT -d 172.16.0.7 -p tcp --syn --dport 22 -m connlimit --connlimit-above 2 -j REJECT`
                - 6、limit: This module matches at a limited rate using a token bucket filter. 限制发包速率
                    - --limit rate[/second|/minute|/hour|/day]
                    - --limit-burst number: Maximum initial number of packets to match: this number gets recharged by one every time the limit specified above is not reached, up to his number; the default is 5. 即令牌桶最大放置令牌的个数
                    - `iptables -I INPUT -s 172.16.0.7 -p icmp --icmp-type 8 -m limit --limit-burst 5 --limit 20/minute -j ACCEPT`
                    - 限制本机某tcp服务接收新请求的速率：`--syn -m limit`
                - 7、state: The "state" extension is a subset of the "conntrack(连接追踪)" module. "state" allows access to the connection tracking state for this packet.
                    - [!] --state state: NEW, ESTABLISHED, INVALID, RELATED or UNTRACKED.
                        - NEW: 新连接请求，如TCP中的SYN包。
                        - ESTABLISHED：已建立的连接，已经匹配到两个方向上的数据传输，而且会继续匹配这个连接的包。
                        - INVALID：无法识别的连接；
                        - RELATED：相关联的连接，当前连接是一个新请求，但附属于某个已存在的连接，如，FTP，FTP-data 连接就是和FTP-control有关联的。
                        - UNTRACKED：未追踪的连接，如，raw可以关闭追踪。
                        - `iptables -I INPUT -d 172.16.0.67 -m state --state ESTABLISHED -j ACCEPT`
                    - state扩展：
                        - 内核模块装载：
                            - nf_conntrack
                            - nf_conntrack_ipv4
                        - 手动装载：nf_conntrack_ftp
                    - 追踪到的连接：`/proc/net/nf_conntrack`
                    - 调整可记录的连接数量最大值：`/proc/sys/net/nf_conntrack_max`
                    - 超时时长：`/proc/sys/net/netfilter/*timeout*`
    - 处理动作（跳转目标）：`-j targetname [per-target-options]`
        - 简单target：ACCEPT，DROP
        - 扩展target：
            - REJECT: This is used to send back an error packet in response to the matched packet: otherwise it is equivalent to DROP so it is a terminating TARGET, ending rule traversal.
                - --reject-with type: The type given can be icmp-net-unreachable, icmp-host-unreachable, icmp-port-unreachable, icmp-proto-unreach‐ able, icmp-net-prohibited, icmp-host-prohibited, or icmp-admin-prohibited ( * ), which return the appropriate ICMP error message (icmp-port-unreachable is the default).
            - LOG: Turn on kernel logging of matching packets.
                - --log-level
                - --log-prefix
                - `iptables -I INPUT -d 172.16.0.67 -p tcp --dport 23 -m state --state NEW -j LOG --log-prefix "access telnet"`
                - 默认日志保存于`/var/log/messages`
            - RETURN：返回调用者；
            - 自定义链做为target：
                ```
                ~]# iptables -N in_ping_rules
                ~]# iptables -A in_ping_rules -d 172.16.0.67 -p icmp --icmp-type 8 -j ACCEPT
                ~]# iptables -I in_ping_rules -d 172.16.0.67 -s 172.16.0.68 -p icmp -j ACCEPT
                ~]# iptables  -I INPUT -d 172.16.0.67 -p icmp -j in_ping_rules
                ~]# iptables -vnL --line-numbers
                Chain INPUT (policy ACCEPT 274 packets, 29788 bytes)
                num   pkts bytes target     prot opt in     out   source        destination
                1        0     0 in_ping_rules  icmp --  *    *   0.0.0.0/0     172.16.0.67

                Chain in_ping_rules (1 references)
                num   pkts bytes target     prot opt in     out   source        destination
                1        0     0 ACCEPT     icmp --  *      *     172.16.0.68   172.16.0.67
                2        0     0 ACCEPT     icmp --  *      *     0.0.0.0/0     172.16.0.67   icmptype 8
                ```

- 保存和载入规则：
    - 保存：`iptables-save > /PATH/TO/SOME_RULE_FILE`
        - CentOS 6：`service iptables save`，覆盖保存规则于/etc/sysconfig/iptables文件。
    - 重载：`iptables-restore < /PATH/FROM/SOME_RULE_FILE`
        - -n, --noflush：不清除原有规则
        - -t, --test：仅分析生成规则集，但不提交
        - CentOS 6：`service iptables restart`，默认重载/etc/sysconfig/iptables文件中的规则
    - 配置文件：/etc/sysconfig/iptables-config

- 规则优化的思路：使用自定义链管理特定应用的相关规则，模块化管理规则；
    - (1) 优先放行双方向状态为ESTABLISHED的报文；
    - (2) 服务于不同类别的功能的规则，匹配到报文可能性更大的放前面；
    - (3) 服务于同一类别的功能的规则，匹配条件较严格的放在前面；
    - (4) 设置默认策略：白名单机制
        - (a) IPtables -P，不建议；
        - (b) 建议在规则的最后定义规则做为默认策略；


## FORWARD

- [IPtables之FORWARD转发链](https://blog.51cto.com/linuxcgi/1965296 "IPtables之FORWARD转发链")

- 要注意的问题：
    - (0) 开启转发功能：`echo "1" > /proc/sys/net/ipv4/ip_forward`
    - (1) 请求-响应报文均会经由FORWARD链，要注意规则的方向性；
    - (2) 如果要启用conntrack机制，建议将双方向的状态为ESTABLISHED的报文直接放行；


## NAT

-NAT: Network Address Translation
    - 请求报文：由管理员定义；
    - 响应报文：由NAT的conntrack机制自动实现；
    - 请求报文：
        - 改源地址：SNAT，MASQUERADE
        - 改目标地址：DNAT

- IPtables/netfilter：
    - NAT定义在nat表；
        - PREROUTING，INPUT，OUTPUT，POSTROUTING
        - SNAT：POSTROUTING
        - DNAT：PREROUTING
        - PAT：

- target：
    - SNAT：
        - This target is only valid in the nat table, in the POSTROUTING and INPUT chains, and user-defined chains which are only called from those chains.
        - --to-source [ipaddr[-ipaddr]]
        - `iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j SNAT --to-source 123.123.123.123`
    - DNAT：
        - This target is only valid in the nat table, in the PREROUTING and OUTPUT chains, and user-defined chains which are only called from those chains.
        - --to-destination [ipaddr[-ipaddr]][:port[-port]]
        - `iptables -t nat -A PREROUTING -d 123.123.123.123 -p tcp --dport 442 -j DNAT --to-destination 192.168.10.18:22`
    - MASQUERADE
        - This target is only valid in the nat table, in the POSTROUTING chain. It should only be used with dynamically assigned IP (dialup) connections: if you have a static IP address, you should use the SNAT target.SNAT场景中应用于POSTROUTING链上的规则实现源地址转换，但外网地址不固定时，使用此target
    - REDIRECT
        - This target is only valid in the nat table, in the PREROUTING and OUTPUT chains, and user-defined chains which are only called from those chains.
        - --to-ports port[-port]
        - `iptables -A PREROUTING -t nat -d 192.168.10.2 -p tcp --dport 80 -j REDIREDT --to-ports 8080`


## 一些例子
- 拒绝192.168.1.22访问本地ssh服务
```
iptables -A INPUT -i eth0 -p tcp -s 192.168.1.22 --dport 22 -j REJECT
iptables -A OUTPUT -o eth0 -p tcp -d 192.168.1.22 --sport 22 -j REJECT
```
- 只允许本机ping其他主机，不允许其他主机ping本机
```
iptables -A INPUT -p icmp --icmp-type 8 -j DROP
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -j DROP
```
- 多端口应用
```
iptables -A INPUT -p tcp -m multiport --sport 22,53,80,110
```
- 速率的限制
```
iptables -A INPUT -m limit --limit 300/s    # 限制速率为300个包每秒
iptables -I FORWARD 1 -p tcp -i eth0 -o eth1 -s 192.168.2.3 -d 192.168.3.3 \
    --dport 80 -m limit --limit=500/s --limit-burst=1000  -j ACCEPT \
    # 允许转发从eth0进来的源IP为192.168.2.3， \
    # 去访问从eth1出去的目的IP为192.168.3.3的80端口（即http服务）的数据包, \
    # 其中会对包的速率做匹配，是每秒转发500个包，burst值是1000， \
    # --limit-burst 表示令牌桶的值 (预设5)
```
- NAT
```
iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j SNAT \
    --to-source 123.123.123.123 \
    # SNAT: 内网源192.168.122.0/24地址映射到公网123.123.123.123出口
iptables -t nat -A PREROUTING -d 123.123.123.123 -p tcp \
    --dport 442 -j DNAT --to-destination 192.168.10.18:22 \
    # 外部要访问内网服务器
```
- 负载均衡
```
iptables -t nat -A PREROUTING -d 10.192.0.65/32 -p tcp -m tcp \
    --dport 8080 -m statistic --mode nth --every 2 --packet 0 \
    -j DNAT --to-destination 10.1.160.14:8080
iptables -t nat -A POSTROUTING -d 10.1.160.14/32 -p tcp -m tcp \
    --dport 8080 -j SNAT --to-source 10.192.0.65
iptables -t nat -A PREROUTING -d 10.192.0.65/32 -p tcp -m tcp \
    --dport 8080 -m statistic --mode nth --every 1 --packet 0 \
    -j DNAT --to-destination 10.1.160.15:8080
iptables -t nat -A POSTROUTING -d 10.1.160.15/32 -p tcp -m tcp \
    --dport 8080 -j SNAT --to-source 10.192.0.65
```


## 补充
- [鸟哥私房菜-防火墙与NAT服务器](http://cn.linux.vbird.org/linux_server/0250simple_firewall.php "鸟哥私房菜-防火墙与NAT服务器")
- [IPtables的限速测试总结](http://ptallrights.blog.51cto.com/11151122/1841911 "IPtables的限速测试总结")
- [基于IPTABLES MARK机制实现策略路由](http://www.just4coding.com/blog/2016/12/23/iptables-mark-and-polices-based-route/ "基于IPTABLES MARK机制实现策略路由")
