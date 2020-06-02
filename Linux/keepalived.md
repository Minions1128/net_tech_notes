# Keepalived

## HA Cluster 概述

- 集群类型: LB (lvs/nginx (http/upstream, stream/upstream) ) , HA, HP

- SPoF: Single Point of Failure

- 系统故障:
    - 硬件故障: 设计缺陷, wear out, 自然灾害
    - 软件故障: 设计缺陷

- 提升系统高用性的解决方案之降低MTTR (Mean time to repair) :
    - 手段: 冗余 (redundant)
        - active/passive (主备) : active --> HEARTBEAT --> passive
        - active/active (双主) : active <--> HEARTBEAT <--> active
    - 高可用的是 "服务" :
        - HA nginx service:
            - vip/nginx process[/shared storage]
            - 资源: 组成一个高可用服务的 "组件" ;
                - (1) passive node的数量
                - (2) 资源切换
        - shared storage:
            - NAS: 文件共享服务器;
            - SAN: 存储区域网络, 块级别的共享;
        - Network partition: 网络分区
            - 隔离设备:
                - node: STONITH = Shooting The Other Node In The Head
                - 资源: fence
            - quorum:
                - with quorum:  > total/2
                - without quorum: <= total/2
            - TWO nodes Cluster: 辅助设备: ping node, quorum disk;
    - Failover: 故障切换, 即某资源的主节点故障时, 将资源转移至其它节点的操作;
    - Failback: 故障移回, 即某资源的主节点故障后重新修改上线后, 将转移至其它节点的资源重新切回的过程;

- HA Cluster实现方案:
    - vrrp协议的实现: keepalived
    - ais: 完备HA集群
        - RHCS (cman)
        - ~~heartbeat~~
        - corosync

- vrrp协议: Virtual Redundant Routing Protocol
    - 术语:
        - 虚拟路由器: Virtual Router
        - 虚拟路由器标识: VRID (0-255)
        - 物理路由器:
            - master: 主设备
            - backup: 备用设备
            - priority: 优先级
        - VIP: Virtual IP
        - VMAC: Virutal MAC  (00-00-5e-00-01-VRID)
            - GraciousARP
        - 通告: 心跳, 优先级等; 周期性;
        - 抢占式, 非抢占式;
    - 安全工作, 认证:
        - 无认证
        - 简单字符认证
        - MD5
    - 工作模式:
        - 主/备: 单虚拟路径器;
        - 主/主: 主/备 (虚拟路径器1) , 备/主 (虚拟路径器2)

- HA Cluster的配置前提:
    - (1) 各节点时间必须同步; ntp, chrony
    - (2) 确保iptables及selinux不会成为阻碍;
    - (3) 各节点之间可通过主机名互相通信 (对KA并非必须) ; 建议使用/etc/hosts文件实现;
    - (4) 确保各节点的用于集群服务的接口支持MULTICAST通信;

## keepalived

- keepalived: vrrp协议的软件实现, 原生设计的目的为了高可用ipvs服务:
    - 基于vrrp协议完成地址流动;
    - 为vip地址所在的节点生成ipvs规则 (在配置文件中预先定义) ;
    - 为ipvs集群的各RS做健康状态检测;
    - 基于脚本调用接口通过执行脚本完成脚本中定义的功能, 进而影响集群事务;

- keepalived组件:
    - 核心组件:
        - vrrp stack
        - ipvs wrapper
        - checkers
    - 控制组件: 配置文件分析器
    - IO复用器
    - 内存管理组件

### 安装配置

- CentOS 6.4+ 随base仓库提供;

- 程序环境:
    - 主配置文件: /etc/keepalived/keepalived.conf
    - 主程序文件: /usr/sbin/keepalived
    - nit File: keepalived.service
    - nit File的环境配置文件: /etc/sysconfig/keepalived

- 配置文件组件部分: TOP HIERACHY
    - GLOBAL CONFIGURATION
        - Global definitions
        - Static routes/addresses
    - VRRPD CONFIGURATION
        - VRRP synchronization group (s) : vrrp同步组;
        - VRRP instance (s) : 每个vrrp instance即一个vrrp路由器;
    - LVS CONFIGURATION
        - Virtual server group (s)
        - Virtual server (s) : ipvs集群的vs和rs;

- 单主配置示例:

```
! Configuration File for keepalived
global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id node1.zhejian.com
    vrrp_mcast_group4 224.0.100.19
}
vrrp_instance VIR_1 {
    state BACKUP
    interface eth0
    virtual_router_id 14
    priority 98
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456_psd
    }
    virtual_ipaddress {
        10.1.0.91/16 dev eth0
    }
}
```

- 配置语法:
    - 配置虚拟路由器:
        ```
        vrrp_instance <STRING> {
            ....
        }
        ```
    - 专用参数:
        - state MASTER|BACKUP: 当前节点在此虚拟路由器上的初始状态; 只能有一个是MASTER, 余下的都应该为BACKUP;
        - interface IFACE_NAME: 绑定为当前虚拟路由器使用的物理接口;
        - virtual_router_id VRID: 当前虚拟路由器的惟一标识, 范围是0-255;
        - priority 100: 当前主机在此虚拟路径器中的优先级; 范围1-254;
        - advert_int 1: vrrp通告的时间间隔;
        - authentication, virtual_ipaddress
            ```
            authentication {
                auth_type AH|PASS
                auth_pass <PASSWORD>
            }
            virtual_ipaddress {
                <IPADDR>/<MASK> brd <IPADDR> dev <STRING> scope <SCOPE> label <LABEL>
                192.168.200.17/24 dev eth1
                192.168.200.18/24 dev eth2 label eth2:1
            }
            ```
        - track_interface: 配置要监控的网络接口, 一旦接口出现故障, 则转为FAULT状态;
            ```
             track_interface {
                eth0
                eth1
                ...
            }
            ```
        - nopreempt: 定义工作模式为非抢占模式;
        - preempt_delay 300: 抢占式模式下, 节点上线后触发新选举操作的延迟时长;

- 定义通知脚本:
    - notify_master <STRING>|<QUOTED-STRING>: 当前节点成为主节点时触发的脚本;
    - notify_backup <STRING>|<QUOTED-STRING>: 当前节点转为备节点时触发的脚本;
    - notify_fault <STRING>|<QUOTED-STRING>: 当前节点转为 "失败" 状态时触发的脚本;
    - notify <STRING>|<QUOTED-STRING>: 通用格式的通知触发机制, 一个脚本可完成以上三种状态的转换时的通知;

- 双主模型示例:

```
! Configuration File for keepalived
global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id node1.zhejian.com
    vrrp_mcast_group4 224.0.100.19
}
vrrp_instance VIR_1 {
    state MASTER
    interface eth0
    virtual_router_id 14
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456_psd
    }
    virtual_ipaddress {
        10.1.0.91/16 dev eth0
    }
}
vrrp_instance VIR_2 {
    state BACKUP
    interface eth0
    virtual_router_id 15
    priority 98
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 578f07b2
    }
    virtual_ipaddress {
        10.1.0.92/16 dev eth0
    }
}
```

- 通知脚本的使用方式:

```sh
#!/bin/bash
#
contact='root@localhost'

notify() {
    local mailsubject="$(hostname) to be $1, vip floating"
    local mailbody="$(date +'%F %T'): vrrp transition, $(hostname) changed to be $1"
    echo "$mailbody" | mail -s "$mailsubject" $contact
}

case $1 in
master)
    notify master
    ;;
backup)
    notify backup
    ;;
fault)
    notify fault
    ;;
*)
    echo "Usage: $(basename $0) {master|backup|fault}"
    exit 1
    ;;
esac
```

- 脚本的调用方法:
    - notify_master "/etc/keepalived/notify.sh master"
    - notify_backup "/etc/keepalived/notify.sh backup"
    - notify_fault "/etc/keepalived/notify.sh fault"

- `man keepalived.conf`

- 虚拟服务器:
    - 配置参数:
        ```
        virtual_server IP port |
        virtual_server fwmark int
        {
            ...
            real_server {
                ...
            }
            ...
        }
        ```
    - 常用参数:
        - `delay_loop <INT>`: 服务轮询的时间间隔;
        - `lb_algo rr|wrr|lc|wlc|lblc|sh|dh`: 定义调度方法;
        - `lb_kind NAT|DR|TUN`: 集群的类型;
        - `persistence_timeout <INT>`: 持久连接时长;
        - `protocol TCP`: 服务协议, 仅支持TCP;
        - `sorry_server <IPADDR> <PORT>`: 备用服务器地址;
        - `real_server`
            ```
            real_server <IPADDR> <PORT>
            {
                weight <INT>
                notify_up <STRING>|<QUOTED-STRING>
                notify_down <STRING>|<QUOTED-STRING>
                HTTP_GET|SSL_GET|TCP_CHECK|SMTP_CHECK|MISC_CHECK { ... }: 定义当前主机的健康状态检测方法;
                # HTTP_GET|SSL_GET: 应用层检测
                # TCP_CHECK
                HTTP_GET|SSL_GET {
                url {
                    path <URL_PATH>: 定义要监控的URL;
                    status_code <INT>: 判断上述检测机制为健康状态的响应码;
                    digest <STRING>: 判断上述检测机制为健康状态的响应的内容的校验码;
                }
                nb_get_retry <INT>: 重试次数;
                delay_before_retry <INT>: 重试之前的延迟时长;
                connect_ip <IP ADDRESS>: 向当前RS的哪个IP地址发起健康状态检测请求
                connect_port <PORT>: 向当前RS的哪个PORT发起健康状态检测请求
                bindto <IP ADDRESS>: 发出健康状态检测请求时使用的源地址;
                bind_port <PORT>: 发出健康状态检测请求时使用的源端口;
                connect_timeout <INTEGER>: 连接请求的超时时长;
                TCP_CHECK {
                   connect_ip <IP ADDRESS>: 向当前RS的哪个IP地址发起健康状态检测请求
                   connect_port <PORT>: 向当前RS的哪个PORT发起健康状态检测请求
                   bindto <IP ADDRESS>: 发出健康状态检测请求时使用的源地址;
                   bind_port <PORT>: 发出健康状态检测请求时使用的源端口;
                   connect_timeout <INTEGER>: 连接请求的超时时长;
               }
            }
            ```

- 高可用的ipvs集群示例:

```
! Configuration File for keepalived
global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id node1.zhejian.com
    vrrp_mcast_group4 224.0.100.19
}
vrrp_instance VIR_1 {
    state MASTER
    interface eth0
    virtual_router_id 14
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456_psd
    }
    virtual_ipaddress {
        10.1.0.93/16 dev eth0
    }
    notify_master "/etc/keepalived/notify.sh master"
    notify_backup "/etc/keepalived/notify.sh backup"
    notify_fault "/etc/keepalived/notify.sh fault"
}
virtual_server 10.1.0.93 80 {
    delay_loop 3
    lb_algo rr
    lb_kind DR
    protocol TCP
    sorry_server 127.0.0.1 80
    real_server 10.1.0.69 80 {
        weight 1
        HTTP_GET {
        url {
            path /
            status_code 200
        }
        connect_timeout 1
        nb_get_retry 3
        delay_before_retry 1
        }
    }
    real_server 10.1.0.71 80 {
        weight 1
        HTTP_GET {
        url {
            path /
            status_code 200
        }
        connect_timeout 1
        nb_get_retry 3
        delay_before_retry 1
        }
    }
}
```

- TCP_CHECK使用示例:

```
TCP_CHECK {
    nb_get_retry 3
    delay_before_retry 2
    connect_timeout 3
}
```

-  双主模式的lvs集群, 拓扑, 实现过程; 配置示例 (一个节点) :

```
! Configuration File for keepalived
global_defs {
notification_email {
root@localhost
}
notification_email_from kaadmin@localhost
smtp_server 127.0.0.1
smtp_connect_timeout 30
router_id node1.zhejian.com
vrrp_mcast_group4 224.0.100.67
}
vrrp_instance VIR_1 {
state MASTER
interface eth0
virtual_router_id 44
priority 100
advert_int 1
authentication {
    auth_type PASS
    auth_pass f1bf7fde
}
virtual_ipaddress {
    172.16.0.80/16 dev eth0 label eth0:0
}
track_interface {
    eth0
}
notify_master "/etc/keepalived/notify.sh master"
notify_backup "/etc/keepalived/notify.sh backup"
notify_fault "/etc/keepalived/notify.sh fault"
}
vrrp_instance VIR_2 {
state BACKUP
interface eth0
virtual_router_id 45
priority 98
advert_int 1
authentication {
    auth_type PASS
    auth_pass f2bf7ade
}
virtual_ipaddress {
    172.16.0.90/16 dev eth0 label eth0:1
}
track_interface {
    eth0
}
notify_master "/etc/keepalived/notify.sh master"
notify_backup "/etc/keepalived/notify.sh backup"
notify_fault "/etc/keepalived/notify.sh fault"
}
virtual_server fwmark 3 {
delay_loop 2
lb_algo rr
lb_kind DR
nat_mask 255.255.0.0
protocol TCP
sorry_server 127.0.0.1 80
real_server 172.16.0.69 80 {
    weight 1
    HTTP_GET {
    url {
        path /
        status_code 200
    }
    connect_timeout 2
    nb_get_retry 3
    delay_before_retry 3
    }
}
real_server 172.16.0.6 80 {
    weight 1
    HTTP_GET {
        url {
            path /
            status_code 200
        }
        connect_timeout 2
        nb_get_retry 3
        delay_before_retry 3
        }
    }
}
```

- keepalived调用外部的辅助脚本进行资源监控, 并根据监控的结果状态能实现优先动态调整; 分两步:
    - (1) 先定义一个脚本;
    - (2)  调用此脚本;
    ```
     vrrp_script <SCRIPT_NAME> {
         script ""
         interval INT
         weight -INT
     }

     track_script {
         SCRIPT_NAME_1
         SCRIPT_NAME_2
         ...
     }
     ```

- 示例: 高可用nginx服务

```
! Configuration File for keepalived
global_defs {
    notification_email {
        root@localhost
    }
    notification_email_from keepalived@localhost
    smtp_server 127.0.0.1
    smtp_connect_timeout 30
    router_id node1.zhejian.com
    vrrp_mcast_group4 224.0.100.19
}
vrrp_script chk_down {
    script "[[ -f /etc/keepalived/down ]] && exit 1 || exit 0"
    interval 1
    weight -5
}
vrrp_script chk_nginx {
    script "killall -0 nginx && exit 0 || exit 1"
    interval 1
    weight -5
    fall 2
    rise 1
}
vrrp_instance VIR_1 {
    state MASTER
    interface eth0
    virtual_router_id 14
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456_psd
    }
    virtual_ipaddress {
        10.1.0.93/16 dev eth0
    }
    track_script {
        chk_down
        chk_nginx
    }
    notify_master "/etc/keepalived/notify.sh master"
    notify_backup "/etc/keepalived/notify.sh backup"
    notify_fault "/etc/keepalived/notify.sh fault"
}
```
