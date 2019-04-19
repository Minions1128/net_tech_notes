# 网络相关

## 地址、接口

- 配置地址的方式：
    - 静态指定
        - 命令：
            - ifcfg家族：
                - ifconfig：配置IP，NETMASK
                - route：路由
                - netstat：状态及统计数据查看
            - iproute2家族：
                - ip OBJECT：
                    - addr：地址和掩码
                    - link：接口
                    - route：路由
                - ss：状态及统计数据查看
            - nm(Network Manager)家族（CentOS 7）
                - nmcli：命令行工具
                - nmtui：text window 工具
            - 注意：
                1. DNS服务器指定：配置文件：`/etc/resolv.conf`
                2. 本地主机名配置：配置文件：`/etc/sysconfig/network`
                    - CentOS 7：hostnamectl                    

        - 配置文件：RedHat及相关发行版
            `/etc/sysconfig/network-scripts/ifcfg-NETCARD_NAME`
    - 动态分配：依赖于本地网络中有DHCP服务

- 网络接口命名方式：
    - 传统命名：
        - 以太网：ethX, [0,oo)，例如eth0, eth1, ...
        - PPP网络：pppX, [0,...], 例如，ppp0, ppp1, ...
    - 可预测命名方案（CentOS）：支持多种不同的命名机制，如：Fireware（固件）, 拓扑结构
        1. 如果Firmware或BIOS为主板上集成的设备提供的索引信息可用，则根据此索引进行命名，如eno1, eno2, ...
        2. 如果Firmware或BIOS为PCI-E扩展槽所提供的索引信息可用，且可预测，则根据此索引进行命名，如ens1, ens2, ...
        3. 如果硬件接口的物理位置信息可用，则根据此信息命名，如enp2s0, ...
        4. 如果用户显式定义，也可根据MAC地址命名，例如enx122161ab2e10, ...
        5. 上述均不可用，则仍使用传统方式命名
    - 命名格式的组成：
        - en：ethernet
        - wl：wlan
        - ww：wwan
    - 名称类型：
        - o<index>：集成设备的设备索引号
        - s<slot>：扩展槽的索引号
        - x<MAC>：基于MAC地址的命名
        - p<bus>s<slot>：基于总线及槽的拓扑结构进行命名


## ifcfg

- ifconfig命令：接口及地址查看和管理
    - `ifconfig [INTERFACE]`
    - `-a`：显示所有接口，包括inactive状态的接口
    
    - `ifconfig interface [aftype] options | address ...`：配置地址的方式
        - `ifconfig IFACE IP/MASK [up|down]`或者`ifconfig IFACE IP netmask NETMASK`
            - options：[-]promisc：（关闭）开启接口的混杂模式：（混杂模式，是指一台机器的网卡能够接收所有经过它的数据流，而不论其目的地址是否是它。）
    - 注意：立即送往内核中的TCP/IP协议栈，并生效
    - 管理IPv6地址：
        - `add addr/prefixlen`
        - `del addr/prefixlen`

- route命令：路由查看及管理
    - 查看：`route -n`
    - 添加：`route add [-net|-host] target [netmask Nm] [gw GW] [[dev] If]`
        - 示例：
            - `route add -net 10.0.0.0/8 gw 192.168.10.1 dev eth1`
            - `route add -net 0.0.0.0/0.0.0.0 gw 192.168.10.1`
            - `route add default gw 192.168.10.1`
    - 删除：`route del [-net|-host] target [gw Gw] [netmask Nm] [[dev] If]`
        - 示例：
            - `route del -net 10.0.0.0/8 gw 192.168.10.1`
            - `route del default`

- netstat命令：
    - Print network connections, routing tables, interface statistics, masquerade connections, and multicast memberships.
    - 显示路由表：netstat -rn
        - `-r`：显示内核路由表
        - `-n`：数字格式
    - 显示网络连接：
        - `netstat [--tcp|-t] [--udp|-u] [--udplite|-U] [--sctp|-S] [--raw|-w] [--listening|-l] [--all|-a] [--numeric|-n]  [--extend|-e[--extend|-e]] [--program|-p]`
            - `-t`：TCP协议的相关连接，连接均有其状态FSM（Finate State Machine）
            - `-u`：UDP相关的连接
            - `-w`：raw socket相关的连接
            - `-l`：处于监听状态的连接
            - `-a`：所有状态
            - `-n`：以数字格式显示IP和Port
            - `-e`：扩展格式
            - `-p`：显示相关的进程及PID
        - 常用组合：
            - `-tan`：tcp的所有连接，LISTEN、ESTABLISHED
            - `-uan`：udp的监听状态
            - `-tnl`：tcp的所有监听的状态
            - `-unl`：udp监听的连接
            - `-tunlp`：所有监听的连接，包括进程
    - 显示接口的统计数据：
        - `netstat {--interfaces|-I|-i} [iface] [--all|-a] [--extend|-e] [--verbose|-v] [--program|-p] [--numeric|-n]`
            - 所有接口：`netstat -i`
            - 指定接口：`netstat -I<IFace>`

- ifup/ifdown命令：开启/禁用某个端口
    - 注意：通过配置文件`/etc/sysconfig/network-scripts/ifcfg-IFACE`来识别接口并完成配置
    
- 配置主机名：
    - hostname命令：
        - 查看：`hostname`
        - 配置：`hostname HOSTNAME`
        - 当前系统有效，重启后无效
    - hostnamectl命令（CentOS 7）：
        - `hostnamectl status`：显示当前主机名信息
        - `hostnamectl set-hostname HOSTNAME`：设定主机名，永久有效
    - 配置文件：`/etc/sysconfig/network`中添加：`HOSTNAME=<HOSTNAME>`
        - 注意：此方法的设置不会立即生效 但以后会一直有效

- 配置DNS服务器指向：
    - 配置文件：`/etc/resolv.conf`中：`nameserver DNS_SERVER_IP`，最多可以指定三台DNS服务器
    - 如何测试(host/nslookup/dig)：
        - `# dig  -t  A  FQDN`：FQDN --> IP
        - `# dig  -x  IP`：IP --> FQDN


## iproute

- ip命令：show / manipulate routing, devices, policy routing and tunnels
    - `ip [ OPTIONS ] OBJECT { COMMAND | help } ;OBJECT := { link | addr | addrlabel | route | netns }`
        - 注意： OBJECT可简写，各OBJECT的子命令也可简写
        - ip link： network device configuration
            - ip link set { DEVICE | group GROUP } { up | down | arp { on | off } |...} - change device attributes
                - dev NAME (default)：指明要管理的设备，dev关键字可省略
                - up和down：启用或禁用端口
                - multicast on或multicast off：启用或禁用多播功能
                - name NAME：重命名接口
                - mtu NUMBER：设置MTU的大小，默认为1500
                - netns PID：ns为namespace，用于将接口移动到指定的网络名称空间
            - ip link show  - display device attributes
            - ip link help -  显示简要使用帮助
        - ip netns：manage network namespaces.
            - ip netns list：列出所有的netns
            - ip netns add NAME：创建指定的netns
            - ip netns del NAME：删除指定的netns
            - ip netns exec NAME COMMAND：在指定的netns中运行命令
        - ip address - protocol address management.
            - ip address add - add new protocol address
                - `ip addr add IFADDR dev IFACE`
                    - [label NAME]：为额外添加的地址指明接口别名
                    - [broadcast ADDRESS]：广播地址会根据IP和NETMASK自动计算得到
                    - [scope SCOPE_VALUE]：
                        - global：全局可用
                        - link：接口可用
                        - host：仅本机可用
                        - site：IPv6专用，site local地址
            - ip address delete - delete protocol address
                - `ip addr delete IFADDR dev IFACE`
            - ip address show - look at protocol addresses
                - `ip addr list [IFACE]`：显示接口的地址
            - ip address flush - flush protocol addresses，清空接口所有的地址
                - `ip addr flush dev IFACE`
        - ip route - routing table management
            - ip route add - add new route
            - ip route change - change route
            - ip route replace - change or add new one
                - `ip route add TYPE PREFIX via GW [dev IFACE] [src SOURCE_IP]`
                - 示例：
                    ```
                        # ip route add 192.168.0.0/24 via 10.0.0.1 dev eth1 src 10.0.20.100
                        # ip route add default via GW
                    ```
            - ip route delete - delete route
                - `ip route del TYPE PRIFIX`
                - 示例：`# ip  route delete  192.168.1.0/24`
            - ip route show - list routes
            - ip route flush - flush routing tables
            - ip route get - get a single route
                - `ip route get TYPE PRIFIX`
                - 示例：`ip route get 192.168.0.0/24`

- ss命令：`ss [options] [FILTER]`
    - options
        - -t：TCP协议的相关连接
        - -u：UDP相关的连接
        - -w：raw socket相关的连接
        - -l：监听状态的连接
        - -a：所有状态的连接
        - -n：数字格式
        - -p：相关的程序及其PID
        - -e：扩展格式信息
        - -m：内存用量
        - -o：计时器信息
    - FILTER := [ state TCP-STATE ]  [ EXPRESSION ]
        - TCP的常见状态：TCP FSM：
            - LISTEN：监听
            - ESTABLISEHD：建立的连接
            - FIN_WAIT_1：断开连接等待回复
            - FIN_WAIT_2：断开连接确认
            - SYN_SENT：
            - SYN_RECV：
            - CLOSED：
    - EXPRESSION：
        - dport = 
        - sport = 
        - 示例：
            ```
                ~]# ss -tan '(  dport = :22 or sport = :22  )'
                ~]# ss -tan state ESTABLISHED
            ```

- nmcli命令：`nmcli  [ OPTIONS ] OBJECT { COMMAND | help }`
    - OBJECT := { general | networking | radio | connection | device | agent  }
        - device - show and manage network interfaces
            - COMMAND := { status | show | connect | disconnect | delete | wifi | wimax }
        - connection - start, stop, and manage network connections
            - COMMAND := { show | up | down | add | edit | modify | delete | reload | load }
                - modify [ id | uuid | path ] <ID> [+|-]<setting>.<property> <value>
                    - 如何修改IP地址等属性：
                        ```
                            # nmcli  conn  modify  IFACE  [+|-]setting.property  value
                                ipv4.address
                                ipv4.gateway
                                ipv4.dns1
                                ipv4.method
                                manual
                        ```


## 配置文件：

- IP/NETMASK/GW/DNS等属性的配置文件：`/etc/sysconfig/network-scripts/ifcfg-IFACE`，IFACE：接口名称

- 路由的相关配置文件：`/etc/sysconfig/network-scripts/route-IFACE`

- 配置文件`/etc/sysconfig/network-scripts/ifcfg-IFACE`通过大量参数来定义接口的属性其可通过vim等文本编辑器直接修改，也可以使用专用的命令的进行修改
    - CentOS 6：system-config-network, setup
    - CentOS 7: nmtui
    - 例如：
        ```
        network-scripts]# cat /etc/sysconfig/network-scripts/route-eth0
        172.17.0.0/16 via 192.168.56.11 dev eth0
        ```

- ifcfg-IFACE配置文件参数：
    - DEVICE：此配置文件对应的设备的名称
    - ONBOOT：在系统引导过程中，是否激活此接口
    - UUID：此设备的惟一标识
    - IPV6INIT：是否初始化IPv6
    - BOOTPROTO：激活此接口时使用什么协议来配置接口属性，常用的有dhcp、bootp、static、none
    - TYPE：接口类型，常见的有Ethernet, Bridge
    - DNS1：第一DNS服务器指向
    - DNS2：备用DNS服务器指向
    - DOMAIN：DNS搜索域
    - IPADDR： IP地址
    - NETMASK：子网掩码CentOS 7支持使用PREFIX以长度方式指明子网掩码
    - GATEWAY：默认网关
    - USERCTL：是否允许普通用户控制此设备
    - PEERDNS：如果BOOTPROTO的值为“dhcp”，是否允许dhcp server分配的dns服务器指向覆盖本地手动指定的DNS服务器指向默认为允许
    - HWADDR：设备的MAC地址
    - NM_CONTROLLED：是否使用NetworkManager服务来控制接口
    - 例如：
    ```
    DEVICE=eth0
    BOOTPROTO=static
    IPADDR=172.17.0.0
    NETMASK=255.255.255.0
    ONBOOT=yes
    TYPE=Ethernet
    NM_CONTROLLED=no
    ```

- 网络服务：network和NetworkManager
    - 管理网络服务：
        - CentOS 6: `service network {start|stop|restart|status}`
        - CentOS 7：`systemctl {start|stop|restart|status} network[.service]`

- 用到非默认网关路由：`/etc/sysconfig/network-scripts/route-IFACE`，支持两种配置方式，但不可混用
    - 1. 每行一个路由条目：`TARGET via GW`
    - 2. 每三行一个路由条目：
        ```
            ADDRESS#=TARGET
            NETMASK#=MASK
            GATEWAY#=NEXTHOP
        ```

- 默认路由修改：
    - `/etc/sysconfig/network`
    ```
    GATEWAY=10.0.0.1
    ```

- 给接口配置多个地址：ip addr之外，ifconfig或配置文件都可以
    - 1. `ifconfig IFACE_LABEL IPADDR/NETMASK`，`IFACE_LABEL： eth0:0, eth0:1, ...`
    - 2. 为接口名称的别名添加配置文件
        - DEVICE=IFACE_LABEL
        - BOOTPROTO：网上别名不支持动态获取地址，只能选择static, none


# comming soon

- nmap
- ncat
- tcpdump
