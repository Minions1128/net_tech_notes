# MySQL

## 数据的备份

- 时间点恢复：binary logs; 
        
- 备份类型：
    - 备份的数据集的范围：完全备份和部分备份
        - 完全备份：整个数据集；
        - 部分备份：数据集的一部分，比如部分表；
    - 全量备份、增量备份、差异备份：
        - 完全备份
        - 增量备份：仅备份自上一次完全备份或增量备份以来变量的那部数据；
        - 差异备份：仅备份自上一次完全备份以来变量的那部数据；
    - 物理备份、逻辑备份：
        - 物理备份：复制数据文件进行的备份；
        - 逻辑备份：从数据库导出数据另存在一个或多个文件中；
    - 根据数据服务是否在线：
        - 热备：读写操作均可进行的状态下所做的备份；
        - 温备：可读但不可写状态下进行的备份；
        - 冷备：读写操作均不可进行的状态下所做的备份；

- 备份需要考虑因素：
    - 锁定资源多长时间？
    - 备份过程的时长？
    - 备份时的服务器负载？
    - 恢复过程的时长？

- 备份策略：
    - 全量+差异 + binlogs
    - 全量+增量 + binlogs
    - 完全+binlog：mysqldump
    - 备份手段：物理、逻辑
            
- 备份什么？
    - 数据
    - 二进制日志、InnoDB的事务日志；
    - 代码（存储过程、存储函数、触发器、事件调度器）
    - 服务器的配置文件

- 备份工具：
    - mysqldump：mysql服务自带的备份工具；逻辑备份工具；
        - 完全、部分备份；
        - InnoDB：热备；
        - MyISAM：温备；
    - cp/tar
        - lvm2：快照（请求一个全局锁），之后立即释放锁，达到几乎热备的效果；物理备份；
        - 注意：不能仅备份数据文件；要同时备份事务日志；要求数据文件和事务日志位于同一个逻辑卷；
    - xtrabackup：由Percona提供，开源工具，支持对InnoDB做热备，物理备份工具；
        - 完全备份、部分备份；
        - 完全备份、增量备份；
        - 完全备份、差异备份；
    - mysqlhotcopy
    - select：
        - 备份：SELECT cluase INTO OUTFILE 'FILENAME';
        - 恢复：CREATE TABLE
        - 导入：LOAD DATA

- mysqldump：
    - 二次封装工具：mydumper和phpMyAdmin
    - 用法：
        ```
            mysqldump [OPTIONS] database [tables]
                OR     mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]
                OR     mysqldump [OPTIONS] --all-databases [OPTIONS]

            mysqldump mydb：表级别备份
            mysqldump --databases mydb：库级别备份
            e.g.. mysqldump -uUSERNAME -pPASSWORD --single-transaction DB_NAME > FILENAME.sql
        ```
    - MyISAM存储引擎：支持温备，备份时要锁定表；
        - -x, --lock-all-tables：锁定所有库的所有表，读锁；
        - -l, --lock-tables：锁定指定库所有表；
    - InnoDB存储引擎：支持温备和热备；
        - --single-transaction：创建一个事务，基于此快照执行备份；
    - 其它选项：
        - -R, --routines：存储过程和存储函数；
        - --triggers：备份触发器
        - -E, --events：事件调度器
        - --master-data[=#]
            1：记录为CHANGE MASTER TO语句，此语句不被注释；
            2：记录为CHANGE MASTER TO语句，此语句被注释；
        - --flush-logs：锁定表完成后，即进行日志刷新操作；

- 基于lvm2的备份：
    - 0.要求数据文件和事务日志位于同一个逻辑卷；
    - 1.请求锁定所有表：`mysql> FLUSH TABLES WITH READ LOCK;`
    - 2.记录二进制文件事件位置：
        ```
            mysql> FLUSH LOGS;
            mysql> SHOW MASTER STATUS;
            mysql  -e  'SHOW MASTER STATUS;' >> /PATH/TO/SOME_POS_FILE
        ```
    - 3.创建快照卷：`lvcreate  -L # -s -p r - SNAM-NAME /dev/VG-NAME/LV-NAME `
    - 4.释放锁：`mysql> UNLOCK TABLES`
    - 5.挂载快照卷，并执行备份，备份完成后删除快照卷；
    - 6.周期性备份二进制日志； 

- Xtrabackup：
    - [xtrabackup命令用法实战](https://blog.csdn.net/wfs1994/article/details/80399408 "xtrabackup命令用法实战")
    - [innobackupex命令用法实战](https://blog.csdn.net/wfs1994/article/details/80398234 "innobackupex命令用法实战")
