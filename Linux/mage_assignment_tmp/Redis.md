# Redis

## 分布式部分概念

- CAP：
    - C：多个数据节点上的数据一致；
    - A：用户发出请求后的有限时间范围内返回结果；
    - P：network partition，网络发生分区后，服务是否依然可用；
    - CAP理论：一个分布式系统不可能同时满足C、A、P三个特性，最多可同时满足其中两者；对于分布式系统满足分区容错性几乎是必须的。     
        - AP: C：弱一致性；
        - CP:

- BASE：BA，S，E，基于CAP演化而来
    - BA：Basically Available，基本可用；
    - S：Soft state，软状态/柔性事务，即状态可以在一个时间窗口内是不同步的；
    - E：Eventually consistency，最终一致性；

## NoSQL

- 特性：数据量大、数据变化非常快（数据增长快、流量分布变化大、数据间耦合结构变化快）、数据源很多；

- NoSQL：Not Only SQL
    - http://www.nosql-databases.org/
    - Key Value / Tuple Store：DynamoDB, redis 
    - column Family：列式数据库, hbase
    - Document Store：文档数据库，mongodb, elastic
    - Graph Databases：图式数据库，Neo4j
    - Multimodel Databases：
    - Time Series / Streaming Databases：时间序列存储

## Redis

- Redis (REmote DIctionary Server) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker. 
    - 开源、内存存储、数据结构存储；
    - 可用作：数据库、缓存、消息队列；

- It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs and geospatial indexes with radius queries.
    - 数据结构：字符串、列表（数组）、hashes（关联数组）、集合、有序集合、bitmaps、hyperloglogs、空间索引；

- Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.
    - 内建的复制、Lua scripting、LRU、事务、持久存储、高可用（Sentinel，Redis Cluster）

- 单进程：CPU并非瓶颈；

- 持久化：
    - snapshotting
    - AOF: append only file

- Replication：主/从
    - 主：rw
    - 从：read-only

### Redis Cluster

- 程序环境：
    - 配置文件：/etc/redis.conf
    - 主程序：/usr/bin/redis-server (6379/tcp)
    - 客户端：/usr/bin/redis-cli
    - Unit File:/usr/lib/systemd/system/redis.service
    - 数据目录：/var/lib/redis

- redis：k/v
    - key：直接ASCII字符串；
    - value：strings, lists, hashes, sets, sorted sets, bitmaps, hyperloglogs

- 获取帮助：
    ```
    To get help about Redis commands type:
        "help @<group>" to get a list of commands in <group>
        "help <command>" for help on <command>
        "help <tab>" to get a list of possible help topics
        "quit" to exit      
    ```

### 简单命令

- @string
    - SET
    - GET
    - EXISTS
    - INCR
    - DECR
    - SETNX
    - SETEX
    - INCRBYFLOAT
    - MGET
    - MSET

- @list，栈、队列
    - LPUSH
    - RPUSH
    - LPOP
    - RPOP
    - LPUSHX, RPUSHX，仅在list存在，才追加值
    - LRANGE
    - LINDEX
    - LSET

- @set 
    - SADD
    - SPOP： 随机弹出一个元素
    - SREM：删除
    - SRANDMEMBER：获取指定键的所有元素
    - SINTER：交集
    - SUNION：并集
    - SDIFF：差集

- @sorted_set：有序集合
    - ZADD
    - ZCARD
    - ZCOUNT
    - ZRANK

- @hash: python中的字典
    - HSET
    - HMSET
    - HGET
    - HMGET
    - HKEYS
    - HVALS
    - HDEL
    - HGETALL

- @pubsub
    - PUBLISH
    - SUBSCRIBE
    - UNSUBSCRIBE
    - PSUBSCRIBE
    - PUNSUBSCRIBE

### 配置Redis

- 配置项
    - 基本配置项
    - 网络配置项
    - 持久化相关配置
    - 复制相关的配置
    - 安全相关配置
    - Limit相关的配置
    - SlowLog相关的配置
    - INCLUDES
    - Advanced配置

- 通用配置项：
    - daemonize, supervised, loglevel, pidfile, logfile, 
    - databases：设定数据库数量，默认为16个，每个数据库的名字均为整数，从0开始编号，默认操作的数据库为0；
    - 切换数据库的方法：`SELECT <dbid>`

- 网络配置项：
    - bind IP
    - port PORT
    - protected-mode
    - tcp-backlog
    - unixsocket
    - timeout：连接的空闲超时时长；

- 安全配置：
    - `requirepass <PASSWORD>`
    - `rename-command <COMMAND> <NEW_CMND_NAME>`
        - 在AOF或Replication环境中，不推荐使用；

- Limits相关的配置：
    - maxclients
    - maxmemory <bytes>
    - maxmemory-policy noeviction
        - 淘汰策略：volatile-lru, allkeys-lru, volatile-random, allkeys-random, volatile-ttl, noeviction
    - maxmemory-samples 5
        - 淘汰算法运行时的采样样本数；

- SlowLog相关的配置:
    - `slowlog-log-slower-than 10000`，单位是微秒；
    - `slowlog-max-len 128`，SlowLog记录的日志最大条目；

- ADVANCED配置：
    - hash-max-ziplist-entries 512
    - hash-max-ziplist-value 64，设置ziplist的键数量最大值，每个值的最大空间； 
    - client-output-buffer-limit normal 0 0 0
    - client-output-buffer-limit slave 256mb 64mb 60
    - client-output-buffer-limit pubsub 32mb 8mb 60
        - <hard-limit>
        - <soft-limit>
        - <soft-limit seconds>

### redis-cli命令

- Usage: redis-cli [OPTIONS] [cmd [arg [arg ...]]]
    - -h HOST
    - -p PORT
    - -a PASSWORD
    - -n DBID

- 与Connection相关命令：
    - help @connection
    - AUTH <password> 
    - ECHO <message>
    - PING 
    - QUIT
    - SELECT dbid

- 清空数据库：
    - FLUSHDB：Remove all keys from the current database，清空当前数据库；
    - FLUSHALL：Remove all keys from all databases，清空所有数据库；

- Server相关的命令：
    - CLIENT GETNAME
    - CLIENT KILL [ip:port] [ID client-id] [TYPE normal|master|slave|pubsub] [ADDR ip:port] [SKIPME yes/no]
    - CLIENT LIST
    - CLIENT PAUSE
        - CLIENT PAUSE timeout
    - CLIENT REPLY               
    - CLIENT SETNAME：Set the current connection name
    - SHUTDOWN [NOSAVE|SAVE]
    - 配置参数可运行时修改：
        - CONFIG GET
        - CONFIG RESETSTAT
        - CONFIG REWRITE，利用内存中的设置重写到配置文件中
        - CONFIG SET
        - INFO：服务器状态信息查看；分为多个secion；
            - INFO [section]
             
- Redis的持久化:
    - RDB：snapshotting
        - 二进制格式；
        - 按事先定制的策略，周期性地将数据从内存同步至磁盘；
        - 数据文件默认为dump.rdb；
        - 客户端显式使用SAVE或BGSAVE命令来手动启动快照保存机制；
            - SAVE：同步，即在主线程中保存快照，此时会阻塞所有客户端请求；
            - BGSAVE：异步；
    - AOF：Append Only File, fsync
        - 记录每次写操作至指定的文件尾部实现的持久化；
        - 当redis重启时，可通过重新执行文件中的命令在内存中重建出数据库；
        - BGREWRITEAOF：AOF文件重写；不会读取正在使用AOF文件，而是通过将内存中的数据以命令的方式保存至临时文件中，完成之后替换原来的AOF文件； 

- RDB相关的配置：
    - `save <seconds> <changes>`
        - save 900 1
        - save 300 10
        - save 60 10000
        - 表示：三个策略满足其中任意一个均会触发SNAPSHOTTING操作；900s内至少有一个key有变化，300s内至少有10个key有变化，60s内至少有1W个key发生变化；
    - `stop-writes-on-bgsave-error yes`： dump操作出现错误时，是否禁止新的写入操作请求；
    - rdbcompression yes: 是否压缩
    - rdbchecksum yes: 是否校验
    - dbfilename dump.rdb：指定rdb文件名
        - `dir /var/lib/redis`：rdb文件的存储路径

- AOF相关的配置
    - appendonly no
    - appendfilename "appendonly.aof"
    - appendfsync: Redis supports three different modes:
        - no：redis不执行主动同步操作，而是OS进行；
        - everysec：每秒一次；
        - always：每语句一次；
    - no-appendfsync-on-rewrite no: 是否在后台执行aof重写期间不调用fsync，默认为no，表示调用；
    - `auto-aof-rewrite-percentage 100`和`auto-aof-rewrite-min-size 64mb`: 这两个条件同时满足时，方会触发重写AOF；与上次aof文件大小相比，其增长量超过100%，且大小不少于64MB; 
    - aof-load-truncated yes
    - 注意：持久机制本身不能取代备份；应该制订备份策略，对redis库定期备份；
        
- 建议RDB和AOF不要同时启用，如果RDB与AOF同时启用： 
    - (1) BGSAVE和BGREWRITEAOF不会同时进行；
    - (2) Redis服务器启动时用持久化的数据文件恢复数据，会优先使用AOF；
            
- 主从复制：
    - 特点：
        - 一个Master可以有多个slave主机，支持链式复制；
        - Master以非阻塞方式同步数据至slave主机；
    - 配置slave节点：
        - redis-cli> SLAVEOF <MASTER_IP> <MASTER_PORT>
        - redis-cli> CONFIG SET masterauth <PASSWORD>
    - 配置参数：
        - `*slaveof`
        - `*masterauth`
        - slave-serve-stale-data yes
        - slave-read-only yes
        - `*repl-diskless-sync no`
            - no
            - Disk-backend：主节点新创建快照文件于磁盘中，而后将其发送给从节点；
            - Diskless：主节占新创建快照后直接通过网络套接字文件发送给从节点；为了实现并行复制，通常需要在复制启动前延迟一个时间段；
            - 新的从节点或某较长时间未能与主节点进行同步的从节点重新与主节点通信，需要做“full synchronization"，此时其同步方式有两种style：
        - repl-diskless-sync-delay 5
        - repl-ping-slave-period 10
        - `*repl-timeout 60`
        - repl-disable-tcp-nodelay no
        - repl-backlog-size 1mb
        - `*slave-priority 100`: 复制集群中，主节点故障时，sentinel应用场景中的主节点选举时使用的优先级；数字越小优先级越高，但0表示不参与选举； 
        - min-slaves-to-write 3：主节点仅允许其能够通信的从节点数量大于等于此处的值时接受写操作；
        - min-slaves-max-lag 10：从节点延迟时长超出此处指定的时长时，主节点会拒绝写入操作；

- sentinel：
    - 主要完成三个功能：监控、通知、自动故障转移
    - 选举：流言协议、投票协议
    - 配置项：
        - port 26379
        - sentinel monitor <master-name> <ip> <redis-port> <quorum>
        - sentinel auth-pass <master-name> <password>
            - <quorum>表示sentinel集群的quorum机制，即至少有quorum个sentinel节点同时判定主节点故障时，才认为其真的故障；
                - s_down: subjectively down
                - o_down: objectively down
        - sentinel down-after-milliseconds <master-name> <milliseconds>: 监控到指定的集群的主节点异常状态持续多久方才将标记为“故障”；
        - sentinel parallel-syncs <master-name> <numslaves>: 指在failover过程中，能够被sentinel并行配置的从节点的数量；
        - sentinel failover-timeout <master-name> <milliseconds>: sentinel必须在此指定的时长内完成故障转移操作，否则，将视为故障转移操作失败；
        - sentinel notification-script <master-name> <script-path>: 通知脚本，此脚本被自动传递多个参数；
    - redis-cli -h SENTINEL_HOST -p SENTINEL_PORT
        - redis-cli> 
        - SENTINEL masters
        - SENTINEL slaves <MASTER_NAME>
        - SENTINEL failover <MASTER_NAME>
        - SENTINEL get-master-addr-by-name <MASTER_NAME>

- redis的集群技术：
    - 豌豆荚：codis
    - twitter：twemproxy
    - redis cluster

# Read more

- [Redis 3.2集群环境搭建和测试](https://blog.frognew.com/2017/03/redis-3.2-cluster-install-and-test.html "Redis 3.2集群环境搭建和测试")

# Comming soon

- codis的测试和应用；
