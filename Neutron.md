# Neutron

## 概述

- Neutron的设计目标是实现“网络即服务(Networking as a Service)”。为了达到这一目标，在设计上遵循了基于 SDN 实现网络虚拟化的原则，在实现上充分利用了 Linux 系统上的各种网络相关的技术。

### 功能

- Neutron为整个OpenStack环境提供网络支持，Neutron提供了一个灵活的框架，通过配置，无论是开源还是商业软件都可以被用来实现这些功能。包括：
    - Switching: Nova 的 Instance 是通过虚拟交换机连接到虚拟二层网络的。
        - 支持多种虚拟交换机，包括Linux原生的 Linux Bridge 和 Open vSwitch。
        - 利用 Linux Bridge 和 OVS，可以创建 VLAN、基于隧道技术的 Overlay 网络，比如 VxLAN 和 GRE(Linux Bridge 目前只支持 VxLAN)。
    - Routing: Instance 可以配置不同网段的 IP，Neutron 的 router（虚拟路由器）实现 instance 跨网段通信。router 通过 IP forwarding，iptables 等技术来实现路由和 NAT。
    - Load Balancing: 通过 Load-Balancing-as-a-Service（LBaaS），提供了将负载分发到多个 instance 的能力。LBaaS 支持多种负载均衡产品和方案，不同的实现以 Plugin 的形式集成到 Neutron，目前默认的 Plugin 是 HAProxy。
    - 防火墙: 通过iptables实现，通过下面两种方式来保障 instance 和网络的安全性。
        - Security Group: 限制进出 instance 的网络包。
        - Firewall-as-a-Service: 限制进出虚拟路由器的网络包。

### 基本概念

- network: 一个隔离的二层广播域
    - Neutron 支持以下网络：
        - local网络: 一个 instance 只能与位于同一节点上同一网络的 instance 通信，local 网络主要用于单机测试。
        - flat网络: 无 vlan tagging 的网络。flat 网络中的 instance 能与位于同一网络的 instance 通信，并且可以跨多个节点。
        - vlan 网络是具有 802.1q tagging 的网络。vlan 是一个二层的广播域，同一 vlan 中的 instance 可以通信，不同 vlan 只能通过 router 通信。vlan 网络可以跨节点，是应用最广泛的网络类型。
        - vxlan: 是基于隧道技术的 overlay 网络。vxlan 网络通过唯一的 segmentation ID（也叫 VNI）与其他 vxlan 网络区分。vxlan 中数据包会通过 VNI 封装成 UPD 包进行传输。因为二层的包通过封装在三层传输，能够克服 vlan 和物理网络基础设施的限制。
        - gre 是与 vxlan 类似的一种 overlay 网络。主要区别在于使用 IP 包而非 UDP 进行封装。
    - 不同 network 之间在二层上是隔离的: 以 vlan 网络为例，network A 和 network B 会分配不同的 VLAN ID，这样就保证了 network A 中的广播包不会跑到 network B 中。当然，这里的隔离是指二层上的隔离，借助路由器不同 network 是可能在三层上通信的。
    - network 必须属于某个 Project（ Tenant 租户），Project 中可以创建多个 network。

- subnet: 一个 IPv4 或者 IPv6 地址段。instance 的 IP 从 subnet 中分配。每个 subnet 需要定义 IP 地址的范围和掩码。
    - subnet 与 network 是 1对多 关系。一个 network 可以有多个 subnet，这些 subnet 可以是不同的 IP 段，但不能重叠。
        - 下面的配置是有效的：
            ```
            network A    subnet A-a: 10.10.1.0/24
                            {"start": "10.10.1.1", "end": "10.10.1.50"}
                         subnet A-b: 10.10.2.0/24
                            {"start": "10.10.2.1", "end": "10.10.2.50"}
            ```
        - 但下面的配置则无效，因为 subnet 有重叠(这里不是判断 IP 是否有重叠，而是 subnet 的 CIDR 重叠)
            ```
            networkA    subnet A-a: 10.10.1.0/24
                            {"start": "10.10.1.1", "end": "10.10.1.50"}
                        subnet A-b: 10.10.1.0/24
                            {"start": "10.10.1.51", "end": "10.10.1.100"}
            ```
        - subnet 在不同的 network 中，CIDR 和 IP 都是可以重叠的
            ```
            network A    subnet A-a: 10.10.1.0/24
                            {"start": "10.10.1.1", "end": "10.10.1.50"}
            network B    subnet B-a: 10.10.1.0/24
                            {"start": "10.10.1.1", "end": "10.10.1.50"}
            ```
    - Neutron 的 router 是通过 Linux network namespace 实现的。network namespace 是一种网络的隔离机制。通过它，每个 router 有自己独立的路由表。

- port: 可以看做虚拟交换机上的一个端口。
    - port 上定义了 MAC 地址和 IP 地址，当 instance 的虚拟网卡 VIF（Virtual Interface） 绑定到 port 时，port 会将 MAC 和 IP 分配给 VIF。
    - port 与 subnet 是 1对多 关系。

- 小节: Project，Network，Subnet，Port 和 VIF 之间关系如下：
    `Project 1:m Network 1:m Subnet 1:m Port 1:1 VIF m:1 Instance`

## Neutron框架

Neutron 也是采用分布式架构，由多个组件（子服务）共同对外提供网络服务。

![neutron.arch](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.arch.jpg "neutron.arch")

- Neutron Server: 对外提供 OpenStack 网络 API，接收请求，并调用 Plugin 处理请求。
- Plugin: 处理 Neutron Server 发来的请求，维护 OpenStack 逻辑网络的状态， 并调用 Agent 处理请求。
- Agent: 处理 Plugin 的请求，负责在 network provider 上真正实现各种网络功能。
- network provider: 提供网络服务的虚拟或物理网络设备，例如 Linux Bridge，Open vSwitch 或者其他支持 Neutron 的物理交换机。
- Queue: Neutron Server，Plugin 和 Agent 之间通过 Messaging Queue 通信和调用。
- Database: 存放 OpenStack 的网络状态信息，包括 Network, Subnet, Port, Router 等。

- 举个例子：以创建一个 VLAN100 的 network 为例，假设 network provider 是 linux bridge， 流程如下：
    - Neutron Server 接收到创建 network 的请求，通过 Message Queue（RabbitMQ）通知已注册的 Linux Bridge Plugin。
    - Plugin 将要创建的 network 的信息（例如名称、VLAN ID等）保存到数据库中，并通过 Message Queue 通知运行在各节点上的 Agent。
    - Agent 收到消息后会在节点上的物理网卡（比如 eth2）上创建 VLAN 设备（比如 eth2.100），并创建 bridge （比如 brqXXX） 桥接 VLAN 设备。

- 这里进行几点说明：
    1. plugin 解决的是 What 的问题，即网络要配置成什么样子？而至于如何配置 How 的工作则交由 agent 完成。
    2. plugin，agent 和 network provider 是配套使用的，比如上例中 network provider 是 linux bridge，那么就得使用 linux bridge 的 plungin 和 agent；如果 network provider 换成了 OVS 或者物理交换机，plugin 和 agent 也得替换。
    3. plugin 的一个主要的职责是在数据库中维护 Neutron 网络的状态信息，这就造成一个问题：所有 network provider 的 plugin 都要编写一套非常类似的数据库访问代码。为了解决这个问题，Neutron 在 Havana 版本实现了一个 ML2（Modular Layer 2）plugin，对 plgin 的功能进行抽象和封装。有了 ML2 plugin，各种 network provider 无需开发自己的 plugin，只需要针对 ML2 开发相应的 driver 就可以了，工作量和难度都大大减少。ML2 会在后面详细讨论。
    4. plugin 按照功能分为两类： core plugin 和 service plugin。
        - core plugin 维护 Neutron 的 netowrk, subnet 和 port 相关资源的信息，与 core plugin 对应的 agent 包括 linux bridge, OVS 等；
        - service plugin 提供 routing, firewall, load balance 等服务，也有相应的 agent。后面也会分别详细讨论。

### Neutron Server

![neutron.srv.arch](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.srv.arch.jpg "neutron.srv.arch")

- Core API: 对外提供管理 network, subnet 和 port 的 RESTful API。
- Extension API: 对外提供管理 router, load balance, firewall 等资源 的 RESTful API。
- Commnon Service: 认证和校验 API 请求。
- Neutron Core: Neutron server 的核心处理程序，通过调用相应的 Plugin 处理请求。
- Core Plugin API: 定义了 Core Plgin 的抽象功能集合，Neutron Core 通过该 API 调用相应的 Core Plgin。
- Extension Plugin API: 定义了 Service Plgin 的抽象功能集合，Neutron Core 通过该 API 调用相应的 Service Plgin。
- Core Plugin: 实现了 Core Plugin API，在数据库中维护 network, subnet 和 port 的状态，并负责调用相应的 agent 在 network provider 上执行相关操作，比如创建 network。
- Service Plugin: 实现了 Extension Plugin API，在数据库中维护 router, load balance, security group 等资源的状态，并负责调用相应的 agent 在 network provider 上执行相关操作，比如创建 router。
- Neutron Server = API + Plugins

### Network Provider

Neutron 的架构是非常开放的，只要遵循一定的设计原则和规范，可以支持多种 network provider。可以通过开发不同的 plugin 和 agent 支持不同的网络技术。例如Linux Bridge和Open vSwitch等其他厂商

### Moduler Layer 2(ML2) Core Plugin

- Neutron 在 Havana 版本实现的一个新的 core plugin，用于替代原有的 linux bridge plugin 和 open vswitch plugin。解决以下问题
    - 只能在 OpenStack 中使用一种 core plugin，多种 network provider 无法共存。
    - 不同 plugin 之间存在大量重复代码，开发新的 plugin 工作量大。

- ML2 对二层网络进行抽象和建模，引入了 type driver 和 mechansim driver。这两类 driver 解耦了 Neutron 所支持的网络类型（type）与访问这些网络类型的机制（mechanism），其结果就是使得 ML2 具有非常好的弹性，易于扩展，能够灵活支持多种 type 和 mechanism。
    - Type Driver: Neutron 支持的每一种网络类型都有一个对应的 ML2 type driver。 type driver 负责维护网络类型的状态，执行验证，创建网络等。 ML2 支持的网络类型包括 local, flat, vlan, vxlan 和 gre。 我们将在后面章节详细讨论每种 type。
    - Mechansim Driver: Neutron 支持的每一种网络机制都有一个对应的 ML2 mechansim driver。 mechanism driver 负责获取由 type driver 维护的网络状态，并确保在相应的网络设备（物理或虚拟）上正确实现这些状态。
        - 有三种类型：
            - Agent-based: 包括 linux bridge, open vswitch, L2 population 等。
            - Controller-based: 包括 OpenDaylight, VMWare NSX 等。
            - 基于物理交换机: 包括 Cisco Nexus, Arista, Mellanox 等。
        - 例如：type driver 为 vlan，mechansim driver 为 linux bridge，我们要完成的操作是创建 network vlan100，那么：
            - vlan type driver 会确保将 vlan100 的信息保存到 Neutron 数据库中，包括 network 的名称，vlan ID 等。
            - linux bridge mechanism driver 会确保各节点上的 linux brige agent 在物理网卡上创建 ID 为 100 的 vlan 设备 和 brige 设备，并将两者进行桥接。

### Service Plugin/Agent

- DHCP: dhcp agent 通过 dnsmasq 为 instance 提供 dhcp 服务。
- Routing: l3 agent 可以为 project（租户）创建 router，提供 Neutron subnet 之间的路由服务。路由功能默认通过 IPtables 实现。
- Firewall: l3 agent 可以在 router 上配置防火墙策略，提供网络安全防护。
- Load Balance: Neutron 默认通过 HAProxy 为 project 中的多个 instance 提供 load balance 服务。

### Architecture Summary

![neutron.arch.sum](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.arch.sum.jpg "neutron.arch.sum")

- Neutron 通过 plugin 和 agent 提供的网络服务。
- plugin 位于 Neutron server，包括 core plugin 和 service plugin。
- agent 位于各个节点，负责实现网络服务。
- core plugin 提供 L2 功能，ML2 是推荐的 plugin。
- 使用最广泛的 L2 agent 是 linux bridage 和 open vswitch。
- service plugin 和 agent 提供扩展功能，包括 dhcp, routing, load balance, firewall, vpn 等。

## Linux Bridge实现Neutron网络

### Warming Up

- 初始化网络状态

| 控制节点 | 计算节点 |
| :------------: | :------------: |
| ![neutron.ini.net.ctrl](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ini.net.ctrl.jpg "neutron.ini.net.ctrl") | ![neutron.ini.net.nova](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ini.net.nova.jpg "neutron.ini.net.nova") |

- linux bridge 环境中的各种网络设备
    - tap interface: 命名为 tapN (N 为 0, 1, 2, 3......)
    - linux bridge: 命名为 brqXXXX。
    - vlan interface: 命名为 ethX.Y（X 为 interface 的序号，Y 为 vlan id）
    - vxlan interface: 命名为 vxlan-Z（z 是 VNI）
    - 物理 interface: 命名为 ethX（X 为 interface 的序号）

### Local network

- local network 的特点是不会与宿主机的任何物理网卡相连，也不关联任何的 VLAN ID

![neutron.local.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.local.net.png "neutron.local.net")

- 两个 local network，分别对应两个网桥 brqXXXX 和 brqYYYY。
- VM0 和 VM1 通过 tap0 和 tap1 连接到 brqXXXX。
- VM2 通过 tap0 和 tap2 连接到 brqYYYY。
- VM0 与 VM1 在同一个 local network中，它们之间可以通信。
- VM2 位于另一个 local network，由于 brqXXXX 和 brqYYYY 没有联通，所以 VM2 无法与 VM0 和 VM1 通信。

### Flat network

- flat network 是不带 tag 的网络，要求宿主机的物理网卡直接与 linux bridge 连接，也就是说每个 flat network 都会独占一个物理网卡。

![neutron.flat.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.flat.net.jpg "neutron.flat.net")

- 两个flat network，分别对应两个网桥 brqXXXX 和 brqYYYY。
- VM0 和 VM1 通过 tap0 和 tap1 连接到 brqXXXX。
- VM2 通过 tap0 和 tap2 连接到 brqYYYY。
- VM0 与 VM1 在同一个 flat network中，它们之间可以通信。
- VM2 位于另一个 flat network，VM2 可以与 VM0 和 VM1 通过路由器进行通信。

![neutron.flat.net1](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.flat.net1.jpg "neutron.flat.net1")

### DHCP Network

- DHCP agent
    - Neutron 提供 DHCP 服务的组件
    - 默认通过 dnsmasq 实现 DHCP 功能。
    - 其会为每个 network 创建一个目录 /opt/stack/data/neutron/dhcp/，用于存放该 network 的 dnsmasq 配置文件。

- Linux Network Namespace
    - 租户之间的网络隔离，是通过 Linux Network Namespace 实现的。
    - 每个 dnsmasq 进程都位于独立的 namespace, 命名为`qdhcp-<network id>`
    - 宿主机本身也有一个 namespace，叫 root namespace，拥有所有物理和虚拟 interface device。物理 interface 只能位于 root namespace。
    - 新创建的 namespace 默认只有一个 loopback device。管理员可以将虚拟 interface，例如 bridge，tap 等设备添加到某个 namespace。
    - veth pair 是一种成对出现的特殊网络设备，它们象一根虚拟的网线，可用于连接两个 namespace。向 veth pair 一端输入数据，在另一端就能读到此数据。例如：`tap19a0ed3d-fe` 与 `ns-19a0ed3d-fe` 就是一对 veth pair，它们将 `qdhcp-f153b42f-c3a1-4b6c-8865-c09b5b2aa274` 连接到 `brqf153b42f-c3`。如下图所示：

![neutron.dhcp](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.dhcp.jpg "neutron.dhcp")

### VLAN

- 这种网络中，多个network可以连接到一个物理网卡，需要将不通的网络标记不同的tag。该物理网卡与上层交换机相连是用trunk.

![neutron.vlan](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.vlan.jpg "neutron.vlan")

### Routing

- Neutron的路由功能是由L3 agent提供的，也就是由iptables提供的。
- 创建router时，要添加需要被路由的VLAN network，这时两个VLAN network的bridge上会多一个tap设备。

![neutron.route.1](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.route.1.png "neutron.route.1")

- Router在被创建出来时，会有相应的namespace，通过veth pair与tap相连，然后将 Gateway IP 配置在位于 namespace 里面的 veth interface 上.
- 目的：解决网路的重叠性。

![neutron.route.2](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.route.2.png "neutron.route.2")

#### External Access

- ext_net属于flat网络的一种，创建好后，将其添加到router中。这时，会多出一个tap设备，并且用过veth pair与router连接。instance在访问外网的时候，报文到达router时会进行source NAT。

![neutron.ext](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ext.jpg "neutron.ext")

#### floating IP

- 从外网直接访问 instance，则可以利用 floating IP。
    - 1. floating IP 提供静态 NAT 功能，建立外网 IP 与 instance 租户网络 IP 的一对一映射。
    - 2. floating IP 是配置在 router 提供网关的外网 interface 上的，而非 instance 中。
    - 3. router 会根据通信的方向修改数据包的源或者目的地址。

### VxLAN

#### Linux实现VxLAN的方式

- Linux vxlan 创建一个 UDP Socket，默认在 8472 端口监听。
- Linux vxlan 在 UDP socket 上接收到 vxlan 包后，解包，然后根据其中的 vxlan ID 将它转给某个 vxlan interface，然后再通过它所连接的 linux bridge 转给虚机。
- Linux vxlan 在收到虚机发来的数据包后，将其封装为多播 UDP 包，从网卡发出。

![neutron.vxlan.p](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.vxlan.p.jpg "neutron.vxlan.p")

#### 创建过程

1. 创建vxlan100 对应的网桥 brq1762d312-d4
2. 创建vxlan interface vxlan-100
3. 创建dhcp 的 tap 设备 tap4df76d0e-59（图中未给出，创建原理参考DHCP）
4. vxlan-100 和 tap4df76d0e-59 已经连接到 brq1762d312-d4，vxlan100 的二层网络就绪。
5. vm2类似

![neutron.vxlan.t](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.vxlan.t.jpg "neutron.vxlan.t")

#### L2 Population

- 用来提高VxLAN的扩展性。
- 原理：利用ProxyARP提供VM IP与MAC的对应关系，以及VM与VTEP的对应关系。
    - Neutron 知道每一个 port 的状态和信息； port 保存了 IP，MAC 相关数据。
    - instance 启动时，其 port 状态变化过程为：down -> build -> active。
    - 每当 port 状态发生变化时，Neutron 都会通过 RPC 消息通知各节点上的 Neutron agent，使得 VTEP 能够更新 VM 和 port 的相关信息。
    - VTEP 可以根据这些信息判断出其他 Host 上都有哪些 VM，以及它们的 MAC 地址，这样就能直接与之通信，从而避免了不必要的隧道连接和广播。

### 安全相关

#### Security Group

1. 通过宿主机上 iptables 规则控制进出 instance 的流量。
2. 安全组作用在 instance 的 port 上。
3. 安全组的规则都是 allow，不能定义 deny 的规则。
4. instance 可应用多个安全组叠加使用这些安全组中的规则。

#### FWaaS(FireWall as a Service)

- Neutron 的一个高级服务。在 subnet 的边界上对 layer 3 和 layer 4 的流量进行过滤。其部署在虚拟 router 上，控制进出租户网络的数据。

- 三个重要概念
    - Firewall：租户能够创建和管理的逻辑防火墙资源。Firewall 必须关联某个 Policy，因此必须先创建 Policy。
    - Firewall Policy：Rule 的集合，Firewall 会按顺序应用 Policy 中的每一条 Rule。
    - Firewall Rule：访问控制的规则，由源与目的子网 IP、源与目的端口、协议、allow 或 deny 动作组成。例如，我们可以创建一条 Rule，允许外部网络通过 ssh 访问租户网络中的 instance，端口为 22。

- 与Security Group的区别：
    - 安全组：
        - 保护对象是instance
        - 其应用对象是虚拟网卡
        - 由 L2 Agent 实现，比如 neutron_openvswitch_agent 和 neutron_linuxbridge_agent。会在计算节点上通过 iptables 规则来控制进出 instance 虚拟网卡的流量。
        - 只能定义 allow 规则。
也就是说：安全组保护的是 instance。
    - FWaaS:
        - 保护对象是subnet
        - 应用对象是router
        - 可以在安全组之前控制外部过来的流量，但是对于同一个 subnet 内的流量不作限制。
        - 可以定义 allow 或者 deny 规则

### LBaaS(Load Balance as a Service)

- Neutron 提供的一项高级网络服务。LBaaS 允许租户在自己的网络中创建和管理 load balancer。目前默认通过 HAProxy 软件来实现。

- 三个主要的概念
    - Pool Member： Layer 4 的实体，拥有 IP 地址并通过监听端口对外提供服务。
    - Pool：由一组（通常提供同一类服务）的 Pool Member 组成。
    - Virtual IP，VIP，是定义在 load balancer 上的 IP 地址，对外服务的地址。
    - 例如：Pool Member为一个web server，可以是10.0.0.11:80，或者10.0.0.12:80；两台Pool Member组成Pool，对外提供HTTP服务，其VIP是10.0.0.10:80

- load balancer 负责监听外部的连接，并将连接分发到 pool member。外部 client 只知道 VIP，不知道也不需要关心是否有 pool 或者有多少个 pool member。

- HAProxy实现LB的方式

![neutron.lb.p](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.lb.p.jpg "neutron.lb.p")

- 左图是 client 发送请求到 web server 的数据流：
    - 1. Client 10.10.10.4 通过浏览器访问服务器的外网 IP 10.10.10.7。
    - 2. 请求首先到达路由器，将目的地址设置为服务器的内网 VIP 172.16.100.11
    - 3. VIP 设置在 load balancer 上，load balancer 收到请求后选择 pool member WEB1，将数据包的目的 IP 设为 WEB1 的地址 172.16.100.9。
    - 4. 在将数据包转发给 WEB1 之前，load balancer 将数据包的源 IP 修改为自己的 VIP 地址 172.16.100.11，其目的是保证 WEB1 能够将应答数据发送回 load balancer。
    - 5. WEB1 收到请求数据包。

- 右图是 web server 应答的数据流：
    - 1. WEB1 将数据包发送给 load balancer。
    - 2. load balancer 收到 WEB1 发回的数据后，将目的 IP 修改为 Client 的地址 10.10.10.4。同时也将数据包的源 IP 修改为 VIP 地址 172.16.100.11，保证 Client 能够将后续的数据发送给自己。
    - 3. load balancer 将数据发送给路由器。
    - 4. 路由器将数据包的原地址恢复成服务器的外网 IP 10.10.10.7，然后发送给 Client。
    - 5. Client 收到应答数据。

- LBaaS支持多种方法：ROUND ROUBIN、LEAST CONNECTIONS和SOURCE IP。
    - ROUND_ROUBIN：轮巡算法，其会按照顺序从pool中选择member。
        - 缺点：无法检测到member是否负载过重，不适合资源分配不合理的member的pool。
    - LEAST_CONNECTIONS：最少连接算法，其会选择连接数最少的pool member。
        - 该算法为动态算法，需要实时监控每个member的连接数和状态。
    - SOURCE_IP：该算法会将相同源IP的连接分到同一个pool member，这种需要保留应用状态的应用，如购物车。

- Session Persistence：是保证让同一个server来处理某个client的请求，而不会导致session丢失。
    - SOURCE_IP：这种方法和load balancer的效果一样。
    - HTTP_COOKIE：client第一次请求时，HAProxy从pool中取一个member，HAProxy会在该的应答报文中添加标识”SRV”的cookie，随后client每次请求都会发送该SRV的给HAProxy，HAProxy会分析，然后分配给同一member。
    - APP_COOKIE：这种cookie是在服务器中保存，app通过session来区分不同的client，HAProxy会将带有同一种app cookie的请求发送到同一member上。


## Open vSwitch实现Neutron网络

### Warming Up

- OvS环境中的各种网络设备
    - tap interface：命名为 tapXXXX
    - linux bridge：命名为 qbrXXXX
    - veth pair：命名为 qvbXXXX, qvoXXXX
    - OVS integration bridge：命名为 br-int
    - OVS patch ports：命名为 int-br-ethX 和 phy-br-ethX（X 为 interface 的序号）
    - OVS provider bridge：命名为 br-ethX（X 为 interface 的序号）
    - 物理 interface：命名为 ethX（X 为 interface 的序号）
    - OVS tunnel bridge：命名为 br-tun

### Local network

- 创建过程和Linux Bridge类似

![neutron.ovs.local.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ovs.local.net.png "neutron.ovs.local.net")

- 创建vm1之后，要将其加入到local network中，需要通过veth pair(`qvbfc1c6ebb-71`和`qvofc1c6ebb-71`)，之所以不将`tapfc1c6ebb-71`直接连接到br-int是由于，OvS不支持将 iptables 规则放在与它直接相连的 tap 设备上。

- Open vSwitch 的每个网桥都可以看作一个真正的交换机，可以支持 VLAN，这里的 tag 就是 VLAN ID。 br-int 中标记 tag 1 的 port 和 标记 tag 2 的 port 分别属于不同的 VLAN，它们之间是隔离的。

- Open vSwitch 中的 tag 是内部 VLAN，用于隔离网桥中的 port，与物理网络中的 VLAN 没有关系。

### Flat network

- flat network 是不带 tag 的网络，宿主机的物理网卡通过网桥与 flat network 连接，每个 flat network 都会占用一个物理网卡：`br-ethX`

- 两个br之间要连接，OvS使用patch port连接：
    - 1. 连接两个 ovs bridge，优先使用 patch port。技术上veth pair 也能实现，但性能不如 patch port。
    - 2. 连接 ovs bridge 和 linux bridge，只能使用 veth pair。
    - 3. 连接两个 linux bridge，只能使用 veth pair。

- 如下为连接拓扑图

![neutron.ovs.flat.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ovs.flat.net.jpg "neutron.ovs.flat.net")

### VLAN

![neutron.ovs.vlan.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ovs.vlan.net.jpg "neutron.ovs.vlan.net")

- 连接方式如flat网络类似，vlan隔离的实现方式flow rule（流规则）
    - 重要的属性：
        - priority：rule 的优先级，值越大优先级越高。Open vSwitch 会按照优先级从高到低应用规则。
        - in_port：inbound 端口编号，每个 port 在 Open vSwitch 中会有一个内部的编号。可以通过命令 `ovs-ofctl show <bridge>`查看 port 编号。
        - dl_vlan：数据包原始的 VLAN ID。
        - actions：对数据包进行的操作。
    - 当数据进出 br-int 时，flow rule 可以修改、添加或者剥掉数据包的 VLAN tag，Neutron 负责创建这些 flow rule 并将它们配置到 br-int，br-eth1 等 Open vSwitch 上。

### Routing

- 网络架构如下图所示

![neutron.ovs.route.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ovs.route.net.jpg "neutron.ovs.route.net")

#### External Access

![neutron.ovs.ext.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ovs.ext.net.jpg "neutron.ovs.ext.net")

#### floating IP

- Open vSwitch driver 环境中 floating IP 的实现与 Linux Bridge driver 完全一样

### VxLAN

- 创建过程：br-int 与 br-tun 通过 patch port “patch-tun” 和 “br-tun” 连接

![neutron.ovs.vxlan.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ovs.vxlan.net.jpg "neutron.ovs.vxlan.net")

- Flow Table

![neutron.ovs.flowtable.net](https://github.com/Minions1128/net_tech_notes/blob/master/img/neutron/neutron.ovs.flowtable.net.jpg "neutron.ovs.flowtable.net")
