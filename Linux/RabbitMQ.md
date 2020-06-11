# RabbitMQ

## 概述

- 进程间通讯: rpc: 远程进程调用

- 中间件: 分布式系统中实现简化, 解耦的工具
    - 分类:
        - 消息中间件
        - 职能中间件: 知道即可
        - 内容型中间件: 生产者-消费者, 发布-订阅; 生产者一般是客户端, 生产者产生消息, 消费者处理生产者的消息, 消费者通常为服务端
    - 作用: 用于实现异步处理请求的者(客户端), 与处理者(服务端)的联系

- 实现: apache(qpid, activemq)
    - RabbitMQ: erlang语言研发
    - kafka
    - 0MQ, ZMQ, ZeroMQ: 基于库的调用, 没有中间件, 性能极好

- broker: 掮客
    - 定义进程间通讯标准: X/Open -> XATMI.Oracle -> tuxedo
    - 功能: 存储, 路由
        - 缓冲池: 缓存作用
        - 路由: 单播, 多播, 广播
        - 消息转换
    - OASIS, SIO: AMQP协议, 高级消息队列协议, 支持多种消息路由模型:
        - 点到点
        - fan-out
        - 发布-订阅
        - 请求-响应
    - 组件
        - 交换器
        - 消息队列
        - 绑定器(通过路由规则实现某类消息与队列的绑定)
    - 消息队列起到缓冲的效果

- rabbitmq-server有多个监听端口, rabbitmq_management监听于15672端口

## 配置安装

- 安装: (epel源) `yum install -y rabbitmq-server`

- 主要程序

```sh
/usr/sbin/rabbitmq-plugins
/usr/sbin/rabbitmq-server
/usr/sbin/rabbitmqctl
```

- `systemctl start rabbitmq-server`

- 插件: rabbitmq-plugins {enable|disable|list}
    - rabbitmq-plugins list
    - rabbitmq-plugins enable rabbitmq_management

- 配置方式:
    - 环境变量: 网络参数, 配置文件路径, 其路径为: `/etc/rabbitmq/rabbitmq-env.conf`
        - RABBITMQ_BASE: 数据库和日志文件;
        - RABBITMA_CONFIGFILE: 配置文件路径 /etc/rabbitmq/rabbitmq.config
        - RABBITMA_LOGS
        - RABBITMQ_NODE_IP_ADDRESS: 监听IP
        - RABBITMQ_NODE_PORT
        - RABBITMQ_PLUGIN_DIR
    - 配置文件: 服务器个组件访问权限, 资源限制, 插件以及集群
        - auth_mechanisms: 认机机制
        - default_user: guest
        - default_pass: guest
        - default_permission
        - disk_free_limit: 磁盘预留空间
        - heartbeat
        - hipe_compile
        - log_levels {none | error | waring | info}
        - tcp_listeners: 监听的地址和端口
        - ssl_listeners: 基于ssl通信协议鉴定的地址和端口
        - vm_memory_high_watermark
    - 运行时参数: `rabbitmqctl [-n <node>] [-q] <command> [<command options>]`
        - rabbitmqctl status: 查看服务状态
        - stop_app: 不指定则停止所有应用
        - start_app
        - 用户管理
        - 虚拟主机
        - 权限管理
        - 组件查看命令
        - `set_parameter [-p <vhostpath>] <component_name> <name> <value>`
        - `clear_parameter [-p <vhostpath>] <component_name> <key>`
        - `set_policy [-p <vhostpath>] [--priority <priority>] [--apply-to <apply-to>] <name> <pattern>  <definition>`
        - `clear_policy [-p <vhostpath>] <name>`
        - roker状态查看: status
        - 环境变量产看: environment
        - 执行erlang底层命令: `eval <expr>`
        - 关闭指定连接: `close_connection <connectionpid> <explanation>`
        - `set_vm_memory_high_watermark <fraction>`: 设定高水位标记

- 用户管理
    - `add_user <username> <password>`
    - `set_user_tags <username> <tags>`
    - `delete_user <username>`
    - `change_password <username> <newpassword>`
    - `clear_password <username>`
    - `set_user_tags <username> <tag> ...`
    - `list_users`

- 虚拟主机
    - `add_vhost <vhostpath>`
    - `delete_vhost <vhostpath>`
    - `list_vhosts [<vhostinfoitem> ...]`

- 权限管理
    - `set_permissions [-p <vhostpath>] <user> <conf> <write> <read>`
    - `clear_permissions [-p <vhostpath>] <username>`
    - `list_permissions [-p <vhostpath>]`: 指定虚拟主机, 不指定则显示根(以主机为中心)
    - `list_user_permissions <username>`: 以用户为中心的参数查询

- 组件查看命令
    - `list_queues [-p <vhostpath>] [<queueinfoitem> ...]`
    - `list_exchanges [-p <vhostpath>] [<exchangeinfoitem> ...]`
    - `list_bindings [-p <vhostpath>] [<bindinginfoitem> ...]`
    - `list_connections [<connectioninfoitem> ...]`
    - `list_channels [<channelinfoitem> ...]`
    - `list_consumers [-p <vhostpath>]`

## RabbitMQ Cluster

- (1)设置各节点主机名: `hostnamectl ste-hostname HOSTNAME` 确保对方的都能解析节点名称

- (2)将cookie复制到各节点, 保持cokkie一致

- (3)停止rabbitmq服务后手动启动
    ```sh
    service rabbitmq stop
    rabbitmq-server -detached
    ```
    - 可使用rabbitmq cluster_status查看集群状态

- (4)停止其中一个节点的应用
    ```sh
    rabbitmqctl stop_app # (如停止node2)
    rabbitmqctl join_cluster rabbit@NODE_NAME   # (在node2执行命令)
    ```

- 容易出现的错误: 集群名称需要和节点名一致, 负责将无法添加节点

## 基于haproxy的LB集群

```sh
listen rabbitmq:5672
    mod tcp
    status enable
    banlance roundrobin
    server rabbit01 IP:PORT check inter 5000
    server rabbit02 IP:PORT check inter 5000
```
