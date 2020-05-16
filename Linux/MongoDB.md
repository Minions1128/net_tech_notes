# MongoDB

## 概述

- 大数据问题: BigData
    - 并行数据库: 水平切分, 分区查询
    - NoSQL数据库: 非关系型, 分布式, 不支持ACID数据库设计范式
    - NewSQL: 针对OLTP(读-写)工作负载, 追求提供和NoSQL系统相同的扩展性能, 且仍然保持ACID和SQL等特性(scalable and ACID and (relational and/or sql -access)), Clusterix, GenieDB, ScaleBase, NimbusBD

- NoSQL特点:
    - 简单数据模型
    - 元数据和数据分离
    - 弱一致性
    - 高吞吐量
    - 高水平扩展能力和低端硬件集群
    - 没有标准化
    - 有限的查询功能(到目前为止)
    - 最终一致是不直观的程序

- CAP原则: 指的是在一个分布式系统中, 一致性(Consistency), 可用性(Availability), 分区容错性(Partition tolerance). CAP 原则指的是, 这三个要素最多只能同时实现两点, 不可能三者兼顾.

- BASE: Basically Available, Soft-state, Eventually Consistent, 是NoSQL数据库通常对可用性及一致性的弱要求原则:
    - Basically Availble -- 基本可用
    - Soft-state -- 软状态/柔性事务. "Soft state" 可以理解为"无连接"的, 而 "Hard state" 是"面向连接"的
    - Eventual Consistency -- 最终一致性, 也是是 ACID 的最终目的.
    - ACID: 强一致性, 隔离性, 采用悲观保守的方法, 难以变化;
    - BASE: 弱一致性, 可用性优先, 采用乐观的方法, 适应变化, 更简单, 跟快

- 数据存储类型:
    - 列式存储模型
        - 应用场景: 在分布式文件系统之上提供支持随机读写的分布式数据存储
        - 典型产品: HBase, Hypertable, Cassandra
        - 数据模型: 以"列"为中心进行存储, 将统一列式数据存储在一起
        - 优点: 快速查询, 高可扩展, 易于实现分布式扩展
    - 文档数据模型
        - 应用场景: 非强事务需求的web应用
        - 典型产品: MongoDB, ElasticSearch
        - 数据模型: 键值模型, 存储为文档
        - 优点: 数据模型无需事先定义
    - 键值数据模型
        - 应用场景: 内容缓存, 用于大量并行数据访问高负载场景
        - 典型产品: Redis
        - 数据模型: 基于hash表实现的key-value
        - 优点: 查询迅速
    - 图式数据模型
        - 应用场景: 社交网络, 推荐系统, 关系图谱
        - 典型产品: Neo4j, Infinite, Graph
        - 数据模型: 图式结构
        - 优点: 适用于图式计算场景

## MongoDB

- MongoDB
    - NoSQL
    - 文档存储
    - JSON
    - C++ 研发

- SQL vs. MongoDB
    - database: database, 数据库
    - table: collection, 数据库表/集合
    - row: document, 数据记录行/文档
    - column: field, 数据字段/域
    - index: index, 索引
    - table joins: 表连接,MongoDB不支持
    - primary key: primary key, MongoDB自动将_id字段设置为主键

### 安装运行

```sh
# 安装
curl -O https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.6.tgz
tar -zxvf mongodb-linux-x86_64-3.0.6.tgz

# 将解压包拷贝到指定目录
mv mongodb-linux-x86_64-3.0.6/ /usr/local/mongodb
# 添加到 PATH 路径中
export PATH=<mongodb-install-directory>/bin:$PATH

# 启动mongdb服务
mkdir -pv /mongodb/data/
./mongod --dbpath /mongodb/data/ &

# 启动JavaScript shell
./mongo
```

### 数据库

- 有一些数据库名是保留的, 可以直接访问这些有特殊作用的数据库
    - admin: 从权限的角度来看, 这是"root"数据库. 要是将一个用户添加到这个数据库, 这个用户自动继承所有数据库的权限. 一些特定的服务器端命令也只能从这个数据库运行, 比如列出所有的数据库或者关闭服务器.
    - local: 这个数据永远不会被复制, 可以用来存储限于本地单台服务器的任意集合
    - config: 当Mongo用于分片设置时, config数据库在内部使用, 用于保存分片的相关信息

### 元数据

- 数据库的信息是存储在集合中. 它们使用了系统的命名空间: `dbname.system.*`, 其包含多种系统信息的特殊集合:
    - dbname.system.namespaces: 列出所有名字空间
    - dbname.system.indexes: 列出所有索引
    - dbname.system.profile: 包含数据库概要(profile)信息
    - dbname.system.users: 列出所有可访问数据库的用户
    - dbname.local.sources: 包含复制对端(slave)的服务器信息和状态

- 对于修改系统集合中的对象有如下限制
    - 在{{system.indexes}}插入数据, 可以创建索引. 但除此之外该表信息是不可变的(特殊的drop index命令将自动更新相关信息)
    - {{system.users}}是可修改的
    - {{system.profile}}是可删除的

### 常用命令

```js
help
show dbs                    // show database names
show collections            // show collections in current database
db.help()
db.stats()                  // 数据库状态
db.serverStatus()           // MongoDB数据库服务状态
db.getCollectionNames()     // 得到当前db的所有聚集集合
db.version()
db.mycoll.help()
```

### 数据库操作, DDL

- 创建数据库: `use mycoll`

- 删除数据库:

```js
use mycoll
switched to db mycoll
db.dropDatabase()
```

- 创建集合(一般插入数据自动创建): `db.createCollection(name, options)`
    - name: 要创建的集合名称
    - options: 可选参数, 指定有关内存大小及索引的选项
        - capped: 布尔, 可选, 如果为 true，则创建固定集合. 固定集合是指有着固定大小的集合, 当达到最大值时, 它会自动覆盖最早的文档. 当该值为 true 时, 必须指定 size 参数
        - autoIndexId: 布尔, 可选, 如为 true，自动在 `_id` 字段创建索引. 默认为 false
        - size: 数值, 可选, 为固定集合指定一个最大值, 以KB计. 如果 capped 为 true, 也需要指定该字段
        - max: 数值, 可选, 指定固定集合中包含文档的最大数量

- **固定集合一旦创建不就不能删除此集合中的文档, 只能通过
`db.mycollection.drop()`命令删除并重新创建集合! 固定集合不能转为普通集合!**

- resize capped collection

```js
db.createCollection("new", {capped:true, size:1073741824}); /* size in bytes */
db.old.find().forEach(function (d) {db.new.insert(d)});
db.old.renameCollection("bak", true);
db.new.renameCollection("old", true);
```
- 删除集合: `db.mycoll.drop()`

### 文档操作, DML

#### 增

- `db.mycoll.insert(document)`: 若插入的数据主键已经存在, 则会抛 org.springframework.dao.DuplicateKeyException 异常, 提示主键重复, 不保存当前数据

```js
db.mycoll.insert({x: 9})
document=({
    x: 10
});
db.mycoll.insert(document)
{ "_id" : ObjectId("5ebeb739a2e109d6a480f33d"), "x" : 10 }
{ "_id" : ObjectId("5ebff949eefd2796f354f669"), "x" : 9 }
```

- `db.mycoll.save(document)`: 如果 `_id` 主键存在则更新数据, 如果不存在就插入数据. 该方法新版本中**已废弃**, 可以使用 `db.mycoll.insertOne()` 或 `db.mycoll.replaceOne()` 来代替

- `db.mycoll.insertOne()`: 用于向集合插入一个新文档, 3.2 版本之后新增, 语法格式如下:

```js
db.mycoll.insertOne(
   <document>,
   {
      writeConcern: <document>
   }
)
```

- `db.mycoll.insertMany()`: 用于向集合插入一个多个文档, 3.2 版本之后新增, 语法格式如下:

```js
db.mycoll.insertMany(
   [ <document 1> , <document 2>, ... ],
   {
      writeConcern: <document>,
      ordered: <boolean>
   }
)
```

- 参数说明
    - document: 要写入的文档
    - writeConcern: 写入策略, 默认为 1, 即要求确认写操作, 0 是不要求
    - ordered: 指定是否按顺序写入, 默认 true, 按顺序写入

#### 删

```js
db.collection.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>
   }
)
```

- 参数说明
    - query: 可选, 删除的文档的条件
    - justOne: 可选, 如果设为 true, 则只删除一个文档, 默认值 false, 则删除所有匹配条件的文档
    - writeConcern: 可选, 抛出异常的级别

#### 查

- `db.mycoll.find(query, projection)`
    - query: 可选, 使用查询操作符指定查询条件
    - projection: 可选, 使用投影操作符指定返回的键. 查询时返回文档中所有键值, 只需省略该参数即可(默认省略)

- `db.mycoll.find().pretty()`: 以易读的方式来读取数据

- `db.mycoll.findOne()`: 只返回一个返回值

- 与SQL的对比
    - 等于: `{key:<value>} - db.mycoll.find({"x":10}) - where x = 10`
    - 小于: `{key:{$lt:<value>}} - db.mycoll.find({"likes":{$lt:50}}) - where likes < 50`
    - 小于或等于: `{key:{$lte:<value>}} - db.mycoll.find({"likes":{$lte:50}}) - where likes <= 50`
    - 大于: `{key:{$gt:<value>}} - db.mycoll.find({"likes":{$gt:50}}) - where likes > 50`
    - 大于或等于: `{key:{$gte:<value>}} - db.mycoll.find({"likes":{$gte:50}}) - where likes >= 50`
    - 不等于: `{key:{$ne:<value>}} - db.mycoll.find({"likes":{$ne:50}}).pretty() - where likes != 50`

- 条件运算
    - $or: `{$or: [{key1: value1}, {key2:value2}]}`
    - $and: `{key1:value1, key2:value2}`
    - 复合: `db.mycoll.find({key1: {$gt:value1}, $or: [{key2: value2},{key3: value3}]})`
    - $not
    - $nor: 逻辑or的取反
    - $exists: 存在逻辑, `{key: {$exists: true}}`
    - $type: 查询键的数据类型, `{key: {$type: <BSON type number> | <String alias>}}`. 参考: https://www.runoob.com/mongodb/mongodb-operators-type.html

#### 改

```js
db.mycoll.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
```
- 参数说明
    - query: update的查询条件, 和查询条件类似
    - update: update的对象和一些更新的操作符(如$,$inc...)
        - $set: `{$set: {key: new_value}}`
        - $unset: 删除指定字段
        - $rename: 更改字段名
    - upsert: 可选, 指如果不存在update的记录, 是否插入新字段. true为插入, 默认是false不插入
    - multi: 可选, 默认是false, 只更新找到的第一条记录, 如果这个参数为true, 就把按条件查出来多条记录全部更新
    - writeConcern: 可选, 抛出异常的级别
