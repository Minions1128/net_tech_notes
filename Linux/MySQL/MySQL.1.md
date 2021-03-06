# MySQL

## 概述

- 数据模型：
    - 层次模型：它将数据组织成一对多关系的结构，层次结构采用关键字来访问其中每一层次的每一部分。例如：人员组织架构
    - 网状模型：它用连接指令或指针来确定数据间的显式连接关系，是具有多对多类型的数据组织方式。多对多。例如：选课
    - 关系模型：它以记录组或数据表的形式组织数据，以便于利用各种地理实体与属性之间的关系进行存储和变换，不分层也无指针，是建立空间数据和属性数据之间关系的一种非常有效的数据组织方法。例如：学生、课程、老师的关系。

- 数据分类，是对存储形式的一种数据类型分析
    - 结构化数据：可以存在excel中的数据
    - 半结构化数据：邮件、报表等
    - 非结构化数据：音频、视频等

- 数据库类型：
    - Relational DBMS
    - NoSQL：
        - Document
        - Key-value store
        - Wide column
        - Graph
    - Search engine：倒排索引
        - Solr
        - ElasticSerach
    - Time Series：监控系统中使用
        - InfluxDB

- SQL接口：Structured Query Language
    - 类似于OS的shell接口
    - 分为两类：
        - DDL，Data Definition Language：`CREATE, ALTER, DROP, SHOW`
        - DML，Data Manipulation Language：`INSERT DELETE UPDATE SELECT`
    - 代码类型：
        - 存储过程：procedure
        - 存储函数：function
        - 触发器：trigger
        - 时间调度器：event scheduler
    - 用户和权限：
        - 用户：认证
        - 权限：管理类、程序类、数据库、表、字段


## MySQL

- MySQL版本
    - 衍生版
        - MariaDB
        - Percona
        - AliDB
        - TiDB
    - 原生版
        - Community
        - Enterprise

- 安装和使用MariaDB：
    - 安装方式：
        1. rpm包：由OS的发行商、程序官方提供
        2. 源码包
        3. 通用二进制格式的程序包
    - 安装完成后，执行`mysql_secure_installation`来做安全配置向导
    - 参考：[CentOS 7下MySQL 5.7安装、配置与应用](https://www.linuxidc.com/Linux/2016-04/130414.htm "CentOS 7下MySQL 5.7安装、配置与应用")

- MariaDB程序的组成：
    - Clinet：client --> mysql protocol --> server
        - mysql：CLI交互式客户端程序
        - mysqldump：备份工具
        - mysqladmin：管理工具
        - mysqlbinlog：
    - Server：
        - mysqld
        - mysqld_safe：建议运行服务端程序
        - mysqld_multi：多实例
    - 非客户端类的管理程序：
        - myisamchk
        - myisampack

- 配置文件：ini风格，用一个文件为多个程序提供配置
    - [mysql]
    - [mysqld]
    - [mysqld_safe]
    - [server]
    - [client]
    - [mysqldump]
    - ...
    - mysql的各类程序启动都读取不只一个配置文件，按顺序读取，且最后读取的为最终生效，使用命令`my_print_defaults`查看：
        ```
            Default options are read from the following files in the given order:
            /etc/mysql/my.cnf /etc/my.cnf ~/.my.cnf
            /etc/my.cnf + /etc/my.cnf.d/*
        ```
    - 运行前常修改的参数：
        - `innodb_file_per_table=ON`
        - `skip_name_resolve=ON`

- 三类套接字地址：
    - IPv4 TCP 3306
    - IPv6 TCP 3306
    - Unix Socket：`/var/lib/mysql.sock`和`/tmp/mysql.sock`

- 常用命令：`mysql [OPINTIONS] [database]`
    - 帮助命令：
        - `man mysql`
        - `mysql --help --verbose`
    - 常用选项：
        - `-uUSERNAME, --user=name`：用户名，默认为root
        - `-hHost, --host=name`：mysql服务器，默认为localhost客户端连接服务端，服务器会反解客户的IP为主机名，关闭此功能`skip_name_resolve=ON`
        - `-pPASSWORD, --password[=PASSWORD]`：用户的密码，默认为空
        - `-P, --port=#`：mysql服务器监听的端口，默认为3306端口
        - `-S, --socket=name`：套接字文件路径
        - `-D, --database=name`：登录时，使用的默认库
        - `-e, --execute='CMD'`：登录数据库时，执行的命令
        - `--protocol={tcp|socket|pipe|memory`：
            - 本地通信：基于本地回环地址进行请求，将基于本地通信协议
                - Linux：SOCKET
                - Windows：PIPE, MEMORY
        - `-S, --socket=name`：The socket file to use for connection.
        - `-D, --database=name`：Database to use.
        - `-e, --execute=name`：Execute command and quit. (Disables --force and history file.)
        - `-E, --vertical`：Print the output of a query (rows) vertically.
    - 注意：
        - mysql的用户帐号由两部分组成：`'USERNAME'@'HOST'`其中HOST用于权限此用户可通过哪些远程主机链接当前的mysql服务
        - HOST的表示方式，支持使用通配符
            - `%`：匹配任意长度的任意字符，如：`172.16.%.% == 172.16.0.0/16`
            - `_`：匹配任意单个字符
    - 命令
        - 客户端命令
            - `use, (\u) Use another database. Takes database name as argument.`
            - `exit, (\q) Exit mysql. Same as quit.`
            - `delimiter（界定符）, (\d) Set statement delimiter.`
            - `go, (\g) Send command to mysql server.`
            - `ego, (\G) Send command to mysql server, display result vertically.`
            - `status, (\s) Get status information from the server.`
            - `clear, (\c) Clear the current input statement.`
            - `system, (\!) Execute a system shell command.`
            - `source, (\.) Execute an SQL script file. Takes a file name as an argument.`
        - 服务端命令
            - 获取帮助：`help contents`
            - Account Management
            - Administration
            - Data Definition
            - Data Manipulation
            - Data Types
    - sql脚本运行：
        - `mysql [options] [DATABASE] < /PATH/FROM/SOME_SQL_SCRIPT`
        - 参考：
            - [MySQL命令行下执行.sql脚本](https://blog.csdn.net/xulianboblog/article/details/51086529 "MySQL命令行下执行.sql脚本")
            - [如何书写优雅、漂亮的SQL脚本？](https://www.cnblogs.com/kerrycode/archive/2010/08/16/1800334.html "如何书写优雅、漂亮的SQL脚本？")

- mysqld服务器程序：工作特性的定义方式
    - 服务器参数、变量：
        - 查看配置文件参数：`SHOW [GLOBAL|SESSION] VARIABLES [like_or_where];`
        - 修改配置参数：`SET variable_assignment [, variable_assignment] ...`
            - variable_assignment:
                - `user_var_name = expr`
                - `[GLOBAL | SESSION] system_var_name = expr`
                - `[@@global. | @@session. | @@]system_var_name = exprSET SESSION []`
            - 仅能修改部分属性，例如：
                - `SET SESSION skip_name_resolve=ON;`
                - `SET @@SESSION.keip_name_resolve=ON;`
            - 其修改结果保存在内存中
    - 状态统计参数、变量：
        - `SHOW [GLOBAL | SESSION] STATUS [like_or_where]`

- 数据类型：
    - 查看数据类型：`HELP DATA TYPES;`
    - 字符型
        - 定长字符
            - CHAR(#)：不区分字符大小写
            - BINARY(#)：区分字符大小写
        - 变长字符：多占一个或两个字符空间
            - VARCHAR(#)
            - VARBINARY(#)
        - 对象存储
            - TEXT：检索时，不区分大小写
            - BLOB：Binary Large OBject，区分大小写
        - 内置类型：SET, ENUM
        - 注：字符集
            - `SHOW COLLATION;`：查看各个字符集下的排序规则
            - `SHOW CHARACTER SET;`：查看所有支持的字符集
    - 数值型
        - 精确数值
            - INT(TINIINT, SMALLINT, MEDIUMINT, INT, BIGINT)
            - DECIMAL
        - 近似数值
            - FLOAT
            - DOUBLE
    - 时间日期型
        - DATE
        - TIME
        - DATETIME
        - TIMESTAMP
        - YEAR(2), YEAR(4)

- 字段数据修饰符：
    - NOT NULL
    - NULL
    - AUTO_INCREMENT：自加
    - DEFAULT value
    - PRIMARY KEY：唯一、非空
    - UNIQUE KEY，可以为空

- DDL，Data Definition Language：`CREATE, ALTER, DROP, SHOW`
    - 数据库管理
        - CREATE：即在`/var/lib/mysql/`下的文件夹
            ```
                CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name;
                    [create_specification] ...

                create_specification:
                    [DEFAULT] CHARACTER SET [=] charset_name
                    | [DEFAULT] COLLATE [=] collation_name
            ```
        - ALTER：
            ```
                ALTER {DATABASE | SCHEMA} [db_name]
                    alter_specification ...
                alter_specification:
                    [DEFAULT] CHARACTER SET [=] charset_name
                  | [DEFAULT] COLLATE [=] collation_name
            ```
        - DROP：`DROP {DATABASE | SCHEMA} [IF EXISTS] db_name`
        - SHOW：`SHOW {DATABASES | SCHEMAS} [LIKE 'pattern' | WHERE expr]`
            - 查看数据库支持的所有存储引擎类型：`SHOW ENGINES;`
    - 表管理
        - CREATE：
            ```
                CREATE [TEMPORARY] TABLE [IF NOT EXISTS] [db_name.]tbl_name
                    (create_definition,...)
                    [table_options]
                create_definition:
                    字段：col_name data_type
                    键：
                        PRIMARY KEY [index_type] (index_col_name,...)
                        UNIQUE [INDEX|KEY] (index_col_name,...)
                        FOREIGN KEY (index_col_name,...)
                    索引：[INDEX|KEY] [index_name] (index_col_name,...)
                table_option:
                    ENGINE [=] engine_name
                    | [DEFAULT] CHARACTER SET [=] charset_name
                    | [DEFAULT] COLLATE [=] collation_name
                复制表结构：CREATE TABLE tbl_name LIKE db_name.old_tbl_name
                复制表数据：CREATE TABLE tbl_name select_statement
            ```
        - ALTER：
            ```
                ALTER [ONLINE | OFFLINE] [IGNORE] TABLE tbl_name
                    [alter_specification [, alter_specification] ...]
                    [partition_options]

                alter_specification:
                    字段：
                        添加：ADD [COLUMN] col_name column_definition [FIRST | AFTER col_name]
                        删除：DROP [COLUMN] col_name
                        修改：
                            CHANGE [COLUMN] old_col_name new_col_name column_definition [FIRST|AFTER col_name]
                            MODIFY [COLUMN] col_name column_definition [FIRST | AFTER col_name]
                    键：
                        添加：ADD [PRIMARY|UNIQUE|FOREIGN] KEY (index_col_name,...)
                        删除：DROP [PRIMARY KEY|FOREIGN KEY fk_symbol]
                    索引：
                        添加：ADD {INDEX|KEY} [index_name] (index_col_name,...)
                        删除：DROP {INDEX|KEY} index_name
                    表选项：ENGINE [=] engine_name
            ```
        - DROP：`DROP [TEMPORARY] TABLE [IF EXISTS] tbl_name [, tbl_name, [...]]`
        - SHOW：`SHOW [FULL] TABLES [{FROM | IN} db_name] [LIKE 'pattern' | WHERE expr]`
            - 查看某表的存储引擎类型：`SHOW TABLES STATUS [LIKE 'table_name']|[WHERE expr]`
            - 查看表上的索引信息：`SHOW INDEXES FROM table_name`
    - 索引
        - 创建索引：
            ```
                CREATE [ONLINE|OFFLINE] [UNIQUE|FULLTEXT|SPATIAL] INDEX index_name
                    [index_type] ON tbl_name (index_col_name,...)
                    [index_option]
                    [algorithm_option | lock_option] ...
            ```
        - 查看索引：
            ```
                SHOW {INDEX | INDEXES | KEYS} {FROM | IN} tbl_name
                    [{FROM | IN} db_name] [WHERE expr]
            ```
        - 删除索引：
            ```
                DROP INDEX [ONLINE|OFFLINE] index_name ON tbl_name
                    [algorithm_option | lock_option] ...
            ```

- DML，Data Manipulation Language：`INSERT DELETE UPDATE SELECT`
    - SELECT
        - 子语句：ORDER BY、GROUP、HAVING
        - SQL查询过程：请求 --> 查询缓存 --> 解析器 --> 预处理器 --> 优化器 --> 查询执行引擎 --> 存储引擎 --> 响应
        - SELECT语句执行流程：FROM, WHERE, GROUP BY, HAVING, ORDER BY, SELECT, LIMIT
        - 外连接：http://www.w3school.com.cn/sql/sql_join_left.asp
    - INSERT
    - UPDATE
    - DELETE


## 事务

- 并发控制，锁：Lock
    - 锁类型 ：
        - 读锁：共享锁，可被多个读操作共享
        - 写锁：排它锁，独占锁
    - 锁粒度：
        - 表锁：在表级别施加锁，并发性较低
        - 行锁：在行级别施加锁，并发性较高维持锁状态的成本较大
    - 锁策略：在锁粒度及数据安全性之间寻求一种平衡机制
        - 存储引擎：级别以及何时施加或释放锁由存储引擎自行决定
        - MySQL Server：表级别，可自行决定，也允许显式请求
    - 锁类别：
        - 显式锁：用户手动请求的锁；
        - 隐式锁：存储引擎自行根据需要施加的锁

- 显式锁的使用：
    1. LOCK TABLES
        - `LOCK TABLES tbl_name [read|write], tbl_name {read|write}, ...`
        - `UNLOCK TABLES`
    2. FLUSH TABLES：刷写所有表
        - `FLUSH TABLES tbl_name,... [WITH READ LOCK];` 备份整个数据库时使用
        - `UNLOCK TABLES;`
    3. SELECT cluase
        - `[FOR UPDATE | LOCK IN SHARE MODE]`

- 事务（Transaction）：组织多个操作为一个整体，要么全部都执行，要么全部都不执行；一组原子性的SQL查询、或者是一个或多个SQL语句组成的独立工作单元；
    - ACID，是指数据库管理系统（DBMS）在写入或更新数据过程中，為保證事务（transaction）是正確可靠的，所必須具備的四个特性：
        - 原子性（atomicity，或称不可分割性）整个事务中的所有操作要么全部成功执行，要么全部失败后回滚；
        - 一致性（consistency）数据库总是应该从一个一致性状态转为另一个一致性状态；
        - 隔离性（isolation，又称独立性）一个事务所做出的操作在提交之前，是否能为其它事务可见；出于保证并发操作之目的，隔离有多种级别；
        - 持久性（durability）事务一旦提交，其所做出的修改会永久保存；
    - [mysql - innodb事务日志详解](https://blog.csdn.net/donghaixiaolongwang/article/details/60961603 "mysql - innodb事务日志详解")
        - 查看：`SHOW GLOBAL VARIABLES;`
        - innodb_log_files_in_group：主备组
        - innodb_log_group_home_dir：事务日志的目录`/var/lib/mysql/`
        - innodb_log_file_size：
        - innodb_mirrored_log_groups：镜像日志组
    - 一些功能：
        - 单语句事务：
            - 查看：`SELECT @@autocommit;`
            - 修改：`SET @@session.autocommit=0;`、`SET autocommit=0`
            - [autocommit](https://blog.csdn.net/aitangyong/article/details/50481161 "autocommit")
        - 手动控制事务：
            - 启动：`START TRANSACTION`
            - 提交：`COMMIT`
            - 回滚：`ROLLBACK`
            - 事务支持savepoints：
                - `SAVEPOINT identifier`
                - `ROLLBACK [WORK] TO [SAVEPOINT] identifier`
                - `RELEASE SAVEPOINT identifier`
        - 事务隔离级别：
            - READ-UNCOMMITTED：读未提交 --> 脏读；
            - READ-COMMITTED：读提交 --> 不可重复读；
            - REPEATABLE-READ：可重复读 --> 幻读；
            - SERIALIZABLE：串行化；
            - 参考：[MySQL事务隔离级别](https://www.jianshu.com/p/4e3edbedb9a8 "MySQL事务隔离级别")


## 索引

- 索引：提取索引的创建在的表上字段中的数据，构建出一个独特的数据结构

- 作用：加速查询操作；
    - 副作用：降低写操作性能；
    - 表中数据子集：把表中某个或某些字段（WHERE子句中用到的字段）的数据提取出来另存为一个特定数据结构组织的数据；

- 索引类型：B+ TREE，HASH
    - B+ TREE：顺序存储，每一个叶子结点到根结点的距离相同；左前缀索引，适合于范围类型的数据查询； 
        - 适用于B+ TREE索引的查询类型：全键值、键值范围或键前缀；
            - 全值匹配：精确匹配某个值：`WHERE COLUMN = 'value';`
            - 匹配最左前缀：只精确起头的部分：`WEHRE COLUMN LIKE 'PREFIX%';`
            - 匹配范围值：
            - 精确匹配某一列，范围匹配另一列：精确匹配在最左列。
            - 只用访问索引的查询：覆盖索引；
                - `index(Name) SELECT Name FROM students WHERE Name LIKE 'L%';`
        - 不适用B+ TREE索引：
            - 如果查条件不是从最左侧列开始，索引无效；
                - `index(age,Fname), WHERE Fname='Jerry';`有效
                - `WHERE age>30 AND Fname='Smith';`无效
            - 不能跳过索引中的某列；
                - `index(name,age,gender) WHERE name='black' and age > 30;`或者`WHERE name='black' AND gender='F';`
        - 如果查询中的某个列是为范围查询，那么其右侧的列都无法再使用索引优化查询；`WHERE age>30 AND Fname='Smith';`
    - Hash索引：基于哈希表实现，特别适用于值的精确匹配查询；
        - 适用场景：只支持等值比较查询，例如`=`, `IN()`, `<=>`
        - 不用场景：所有非精确值查询；MySQL仅对memory存储引擎支持显式的hash索引；

- 索引优点：
    - 降低需要扫描的数据量，减少IO次数；
    - 可以帮助避免排序操作，避免使用临时表； 
    - 帮助将随机IO转为顺序IO；

- 高性能索引策略：
    - 在WHERE中独立使用列，尽量避免其参与运算；`WHERE age+2 > 32`优于`WHERE age > 30`
    - 左前缀索引：索引构建于字段的最左侧的多少个字符，要通过索引选择性来评估。索引选择性：不重复的索引值和数据表的记录总数的比值；
    - 多列索引： AND连接的多个查询条件更适合使用多列索引，而非多个单键索引；`index(gender, age)`优于`index(gender), index(age)`
    - 选择合适的索引列次序：选择性最高的放左侧；

- EXPLAIN来分析索引有效性：
    - 使用方式：
        ```
            EXPLAIN [explain_type] SELECT select_options
                explain_type: EXTENDED | PARTITIONS
        ```
    - 输出结果：
        ```
            id: 1
            select_type: SIMPLE
            table: students
            type: const
            possible_keys: PRIMARY
            key: PRIMARY
            key_len: 4
            ref: const
            rows: 1
            Extra: 
        ```
    - 说明：
        - id：当前查询语句中，第几个SELECT语句的编号；
        - select_type：查询类型：
            - 简单查询：SIMPLE
            - 复杂查询：
                - 简单子查询：SUBQUERY
                - 用于FROM中的子查询：DERIVED
                - 联合查询中的第一个查询：PRIMARY
                - 联合查询中的第一个查询之后的其它查询：UNION
                - 联合查询生成的临时表：UNION RESULT
        - table：查询针对的表；
        - type：关联类型，或称为访问类型，即MySQL如何去查询表中的行
            - ALL：全表扫描；
            - index：根据索引的顺序进行的全表扫描；但同时如果Extra列出现了"Using index”表示使用了覆盖索引；
            - range：有范围限制地根据索引实现范围扫描；扫描位置始于索引中的某一项，结束于另一项；
            - ref：根据索引返回的表中匹配到某单个值的所有行（匹配给定值的行不止一个）；
            - eq_ref：根据索引返回的表中匹配到某单个值的单一行，仅返回一个行，但需要与某个额外的参考值比较，而不是常数；
            - const，system：与某个常数比较，且只返回一行；
        - possiable_keys：查询中可能会用到的索引；
        - key：查询中使用的索引；
        - key_len：查询中用到的索引长度；
        - ref：在利用key字段所显示的索引完成查询操作时所引用的列或常量值；
        - rows：MySQL估计出的为找到所有的目标项而需要读取的行数；
        - Extra：额外信息
            - Using index：使用了覆盖索引进行的查询；
            - Using where：拿到数据后还要再次进行过滤；
            - Using temporary：使用了临时表以完成查询；
            - Using filesort：对结果使用了一个外部索引排序；


## 帐号权限管理

- 用户帐号格式：`'username'@'host'`
    - user：账户名称；
    - host：此账户可通过哪些客户端主机请求创建连接线程；
        - `%`：任意长度牟任意字符；
        - `_`：任意单个字符；

- 禁止主机名检查：
    ```
        my.cnf
        [mysqld]
        skip_name_resolve=ON
    ```

- 授权类别：
    - 库级别：CREATE，ALTER，DROP，INDEX，CREATE VIEW，SHOW VIEW，GRANT（能够把自己获得的权限生成一个副本转赠给其它用户），OPTION
    - 表级别：
        - CREATE，ALTER，DROP，INDEX，CREATE VIEW，SHOW VIEW，GRANT（能够把自己获得的权限生成一个副本转赠给其它用户），OPTION，
        - INSERT/DELETE/UPDATE/SELECT
    - 字段级别：INSERT/UPDATE/SELECT 
    - 管理类：CREATE USER、RELOAD、LOCK TABLES、REPLICATION CLIENT, REPLICATION SLAVE、SHUTDOWN、FILE、SHOW DATABASES、PROCESS、SUPER(root权限)
    - 程序类：FUNCTION，PROCEDURE，TRIGGER；操作：CREATE，ALTER，DROP，EXECUTE；可以组合成12个权限
    - 所有权限：ALL, ALL PRIVILEGES

- 元数据数据库（数据字典）：mysql
    - 授权：db, host, user
    - 存储的数据表为：tables_priv, column_priv, procs_priv, proxies_priv

- 具体操作：
    - 用户帐号相关：
        - 创建帐号：`CREATE USER 'username'@'host' [auth_option]`
            - 创建帐号时授权：`CREATE USER  'user'@'host' [IDENTIFIED BY [PASSWORD] 'password'] [,'user'@'host' [IDENTIFIED BY [PASSWORD] 'password']...]`
        - 重命名：`RENAME USER old_user TO new_user[, old_user TO new_user] ...`
        - 删除帐号：`DROP USER 'username'@'host' [, 'username1'@'host1']`
        - 修改用户名密码：
            - `> SET PASSWORD [FOR 'user'@'host'] = PASSWORD('cleartext password');`
            - `> UPDATE mysql.user SET Password=PASSWORD('cleartext password')  WHERE User='USERNAME' AND Host='HOST';`
            - `# mysqladmin -uUSERNAME -hHOST -p  password 'NEW_PASS'`
    - 授权相关
        - 用户授权：
        ```
            GRANT priv_type [(column_list)] [, priv_type [(column_list)]] ...
                ON [object_type] priv_level 
                TO 'username'@'host' [auth_option]
                [REQUIRE {NONE | ssl_option [[AND] ssl_option] ...}]
                [WITH with_option ...]

            priv_type: {
                ALL
                | UPDATE
                ...
            }

            object_type: {
                TABLE
              | FUNCTION
              | PROCEDURE
            }

            priv_level: {
                *
              | *.*
              | db_name.*
              | db_name.tbl_name
              | tbl_name
              | db_name.routine_name
            }

            auth_option: {
                IDENTIFIED BY 'auth_string'
              | IDENTIFIED BY PASSWORD 'hash_string'
              | IDENTIFIED WITH auth_plugin
              | IDENTIFIED WITH auth_plugin AS 'hash_string'
            }

            ssl_option: {
                SSL
                | X509
                | CIPHER 'cipher'
                | ISSUER 'issuer'
                | SUBJECT 'subject'
            }

            with_option: {
                GRANT OPTION
                | MAX_QUERIES_PER_HOUR count
                | MAX_UPDATES_PER_HOUR count
                | MAX_CONNECTIONS_PER_HOUR count
                | MAX_USER_CONNECTIONS count
            }

            e.g.. GRANT ALL ON db1.* TO 'shenzj'@'localhost' IDENTIFIED BY '123456';
        ```
        - 回收授权：`REVOKE priv_type [(column_list)] ON [object_type] priv_level FROM user [, user]`
            - 回收所有权限：`REVOKE ALL PRIVILEGES, GRANT OPTION FROM user [, user] ...`
        - 查看权限：`SHOW GRANTS [FOR 'user'@'host']`
    - 刷新：·`FLUSH PRIVILEGES;­`

- 忘记管理员密码的解决办法：
    - (1) 启动mysqld进程时，使用--skip-grant-tables和--skip-networking选项；
        - CentOS 7：/usr/lib/systemd/system/mariadb.service
        - CentOS 6：/etc/init.d/mysqld
    - (2) 通过UPDATE命令修改管理员密码；
    - (3) 以正常的方式启动mysqld进程；


## 查询缓存

- 缓存：k/v
    - key：查询语句的hash值
    - value：查询语句的执行结果

- 如何判断缓存是否命中：通过查询语句的哈希值判断

- 哈希值考虑的因素包括
    - 查询本身、要查询数据库、客户端使用的协议版本
        ```
            SELECT Name FROM students WHERE StuID=3;
            Select Name From students where StuID=3;
        ```

- 哪些查询可能不会被缓存？
    - 查询语句中包含UDF（用户定义的函数）
    - 存储函数
    - 用户自定义变量
    - 临时表
    - mysql系统表或者是包含列级别权限的查询
    - 有着不确定结果值的函数(now())；

- 缓存失效：当某个表正在写入数据，则这个表的缓存（命中缓存，缓存写入等）将会处于失效状态，在Innodb中，如果某个事务修改了这张表，则这个表的缓存在事务提交前都会处于失效状态，在这个事务提交前，这个表的相关查询都无法被缓存。

- 查询缓存相关的服务器变量：
    - 查看缓存相关服务器的变量：
        ```
            MariaDB [(none)]> show global variables like '%query_cache%';
            +------------------------------+---------+
            | Variable_name                | Value   |
            +------------------------------+---------+
            | have_query_cache             | YES     |
            | query_cache_limit            | 1048576 |  # 1M
            | query_cache_min_res_unit     | 4096    |
            | query_cache_size             | 0       |
            | query_cache_strip_comments   | OFF     |
            | query_cache_type             | ON      |
            | query_cache_wlock_invalidate | OFF     |
            +------------------------------+---------+
        ```
    - query_cache_limit：能够缓存的最大查询结果；（单语句结果集大小上限）有着较大结果集的语句，显式使用SQL_NO_CACHE，以避免先缓存再移出；
        - 修改：`SET GLOBAL query_cache_limit=1024*1024*2;`
    - query_cache_min_res_unit：内存块的最小分配单位；缓存过小的查询结果集会浪费内存空间；
        - 较小的值会减少空间浪费，但会导致更频繁地内存分配及回收操作；
        - 较大值的会带来空间浪费；
    - query_cache_size：查询缓存空间的总共可用的大小；单位是字节，必须是1024的整数倍；0为0字节
    - query_cache_strip_comments：
    - query_cache_type：缓存功能启用与否；
        - `ON`开启：SELECT SQL_NO_CACHE，不缓存，默认缓存
        - `OFF`：关闭
        - DEMAND：按需缓存，仅缓存SELECT语句中带SQL_CACHE的查询结果；
    - query_cache_wlock_invalidate：如果某表被其它连接锁定，是否仍然可以从查询缓存中返回查询结果；默认为OFF，表示可以；ON则表示不可以；

- 状态变量：
    ```
        mysql> SHOW GLOBAL STATUS LIKE 'Qcache%';
            +-------------------------+----------+
            | Variable_name           | Value    |
            +-------------------------+----------+
            | Qcache_free_blocks      | 1        |
            | Qcache_free_memory      | 16759688 |
            | Qcache_hits             | 0        |
            | Qcache_inserts          | 0        |
            | Qcache_lowmem_prunes    | 0        | # 由于缓存不够用，而启动清理算法的次数
            | Qcache_not_cached       | 0        |
            | Qcache_queries_in_cache | 0        | # 当前查询过程中，缓存下来的语句
            | Qcache_total_blocks     | 1        |
            +-------------------------+----------+
    ```

- 命中率：Qcache_hits/Com_select 


## 日志

- 日志类型：
    - 查询日志：general_log
    - 慢查询日志：log_slow_queries，查询时间超过指定时长的查询日志
    - 错误日志：log_error, log_warnings
    - 二进制日志：binlog
    - 中继日志：relay_log
    - 事务日志：innodb_log

- 查询日志
    - 记录查询语句，日志存储位置：文件(`/var/lib/mysql/*.log`)和表(`mysql.general_log`)
    - 参数：
        - general_log={ON|OFF}
        - general_log_file=HOSTNAME.log
        - log_output={FILE|TABLE|NONE}
    - 修改：`SET @@global.log_output='FILE,TABLE';`

- 慢查询日志
    - 慢查询：运行时间超出指定时长的查询；
        - 长查询时间：long_query_time
    - 存储位置：文件(`/var/lib/mysql/*.log`)和表(`mysql.slog_log`)
    - 参数：
        - log_slow_queries={ON|OFF}
        - slow_query_log={ON|OFF}
        - slow_query_log_file=
        - log_output={FILE|TABLE|NONE}
        - log_slow_filter=admin,filesort,filesort_on_disk,full_join,full_scan,query_cache,query_cache_miss,tmp_table,tmp_table_on_disk
        - log_slow_rate_limit
        - log_slow_verbosity

- 错误日志
    - 记录信息：
        - mysqld启动和关闭过程、输出的信息；
        - mysqld运行中产生的错误信息；
        - event scheduler运行时产生的信息；
        - 主从复制架构中，从服务器复制线程启动时产生的日志；
    - log_error= {/var/log/mariadb/mariadb.log|OFF}
    - log_warnings={ON|OFF}

- 二进制日志
    - 用于记录引起数据改变或存在引起数据改变的潜在可能性的语句（STATEMENT）或改变后的结果（ROW），也可能是二者混合；
    - 功用：“重放”
        - binlog_format={STATEMENT|ROW|MIXED}
            - STATEMENT：语句；
            - ROW：行；
            - MIXED：上述二者混合；
    - 查看二进制日志文件列表：SHOW MASTER|BINARY LOGS;
    - 查看当前正在使用的二进制日志文件：SHOW MASTER STATUS；
    - 查看二进制日志文件中的事件：SHOW BINLOG EVENTS [IN 'log_name'] [FROM pos] [LIMIT [offset,] row_count]
    - 服务器变量：
        - log_bin={/PATH/TO/BIN_LOG_FILE|OFF}，只读变量，设置二进制文件的位置，或者将二进制文件进行关闭；
            - 修改在mysql配置文件中[mysqld]下添加：`log_bin=LOG_FILE_NAME`，重启mysql
        - session.sql_log_bin={ON|OFF}，控制某会话中的“写”操作语句是否会被记录于日志文件中；
        - max_binlog_size=1073741824
        - sync_binlog={1|0}，是否同步二进制日志从缓冲区到磁盘文件中
    - mysqlbinlog：查看二进制日志的内容，相关参数：
        - `--start-datetime= & --stop-datetime=` YYYY-MM-DD hh:mm:ss
        - `-j, --start-position=# & --stop-position=#`：开始和结束位置
        - `-u, --user=name & -p, --password[=name] & -h, --host=name`：远程连接到其他服务器
    - 二进制日志事件格式：
        ```
            # at 553
            #160831 9:56:08 server id 1 end_log_pos 624 Query thread_id=2 exec_time=0 error_code=0
            SET TIMESTAMP=1472608568/*!*/;
            BEGIN
            /*!*/;
        ```
        - 事件的起始位置：# at 553
        - 事件发生的日期时间：#160831  9:56:08
        - 事件发生的服务器id：server id 1
        - 事件的结束位置：end_log_pos 624
        - 事件的类型：Query
        - 事件发生时所在服务器执行此事件的线程的ID： thread_id=2 
        - 语句的时间戳与将其写入二进制日志文件中的时间差：exec_time=0
        - 错误代码：error_code=0，0表示无错误
        - 事件内容：SET TIMESTAMP=1472608568/*!*/;

- 中继日志：从服务器上记录下来从主服务器的二进制日志文件同步过来的事件；

- 事务日志：
    - 事务型存储引擎innodb用于保证事务特性的日志文件：
        - redo log
        - undo log
