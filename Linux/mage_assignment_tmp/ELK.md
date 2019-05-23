# Elastic Stack

## 概述

- 搜索引擎：
    - 索引组件：获取数据-->建立文档-->文档分析-->文档索引（倒排索引）
    - 搜索组件：用户搜索接口-->建立查询（将用户键入的信息转换为可处理的查询对象）-->搜索查询-->展现结果
    - 索引组件：Lucene: Apache LuceneTM is a high-performance, full-featured text search engine library written entirely in Java. It is a technology suitable for nearly any application that requires full-text search, especially cross-platform.
    - 搜索组件：
        - Solr: SolrTM is a high performance search server built using Lucene Core, with XML/HTTP and JSON/Python/Ruby APIs, hit highlighting, faceted search, caching, replication, and a web admin interface.
        - ElasticSearch: Elasticsearch is a distributed, RESTful search and analytics engine capable of solving a growing number of use cases. As the heart of the Elastic Stack, it centrally stores your data so you can discover the expected and uncover the unexpected.

- Elastic Stack：Elasticsearch、Logstash、Kibana三个开源软件的组合,每个完成不同的功能，官方网站 www.elastic.co
    - ElasticSearch: 可实现数据的实时全文搜索搜索、支持分布式可实现高可用、提供API接口，可以处理大规模日志数据，比如Nginx、Tomcat、系统日志等。
    - Logstash： is an open source, server-side data processing pipeline that ingests data from a multitude of sources simultaneously, transforms it, and then sends it to your favorite “stash.” (Ours is Elasticsearch, naturally.) 通过插件实现日志收集，支持日志过滤，支持普通log、自定义json格式的日志解析。
        - input {} #input 插件收集日志
        - output {} #output 插件输出日志
    - Beats：
        - Filebeat：Log Files
        - Metricbeat：Metrics
        - Packetbeat：Network Data
        - Winlogbeat：Windows Event Logs
        - Heartbeat：Uptime Monitoring
    - Kibana：Kibana lets you visualize your Elasticsearch data and navigate the Elastic Stack, so you can do anything from learning why you're getting paged at 2:00 a.m. to understanding the impact rain might have on your quarterly numbers.调用elasticsearch的数据，并进行前端数据可视化的展现。

![elk.1](https://github.com/Minions1128/net_tech_notes/blob/master/img/elk.1.jpg)

- 





    ES的核心组件：
        物理组件：
            集群：
                状态：green, yellow, red
            节点：
            Shard：
        
        Lucene的核心组件：
            索引（index）：数据库
            类型（type）：表
            文档（Document）：行
            映射（Mapping）：
            
        域选项：来控制Lucene将文档添加进域索引后对该域执行的操作：
            Index.ANALYZED：切词和分析；
            Index.NOT_ANALYZED：做索引，但不做分析；
            Index.NO：不做索引；
            
    ElasticSearch 5的程序环境：
        配置文件：
            /etc/elasticsearch/elasticsearch.yml
            /etc/elasticsearch/jvm.options
            /etc/elasticsearch/log4j2.properties
        Unit File：elasticsearch.service
        程序文件：
            /usr/share/elasticsearch/bin/elasticsearch
            /usr/share/elasticsearch/bin/elasticsearch-keystore：
            /usr/share/elasticsearch/bin/elasticsearch-plugin：管理插件程序        
        
        搜索服务：
            9200/tcp
            
        集群服务：
            9300/tcp
        
    els集群的工作逻辑：
        多播、单播：9300/tcp
        关键因素：clustername
        
        所有节点选举一个主节点，负责管理整个集群的状态(green/yellow/red)，以及各shards的分布方式；
        
        插件：


