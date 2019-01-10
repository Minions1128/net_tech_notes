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
- 事务（Transaction）：组织多个操作为一个整体，要么全部都执行，要么全部都不执行；
    - ACID，是指数据库管理系统（DBMS）在写入或更新数据过程中，為保證事务（transaction）是正確可靠的，所必須具備的四个特性：
        - 原子性（atomicity，或稱不可分割性）
        - 一致性（consistency）
        - 隔离性（isolation，又称独立性）
        - 持久性（durability）
22.2 0：0
22.2 60：0
# END
