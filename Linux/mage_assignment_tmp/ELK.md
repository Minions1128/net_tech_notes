# Elastic Stack

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
    - Beats：收集组件
        - Filebeat：Log Files
        - Metricbeat：Metrics
        - Packetbeat：Network Data
        - Winlogbeat：Windows Event Logs
        - Heartbeat：Uptime Monitoring
    - Kibana：Kibana lets you visualize your Elasticsearch data and navigate the Elastic Stack, so you can do anything from learning why you're getting paged at 2:00 a.m. to understanding the impact rain might have on your quarterly numbers.调用elasticsearch的数据，并进行前端数据可视化的展现。

![elk.1](https://github.com/Minions1128/net_tech_notes/blob/master/img/elk.1.jpg)

## ElasticSearch

![elk.es.arch](https://github.com/Minions1128/net_tech_notes/blob/master/img/elk.es.arch.png)

- ES的核心组件：
    - 物理组件：
        - 集群：有状态：green, yellow, red
        - 节点：
        - Shard：
    - Lucene的核心组件：
        - 索引（index）：数据库
        - 类型（type）：表
        - 文档（Document）：行
        - 映射（Mapping）：
    - 域选项：来控制Lucene将文档添加进域索引后对该域执行的操作：
        - Index.ANALYZED：切词和分析；
        - Index.NOT_ANALYZED：做索引，但不做分析；
        - Index.NO：不做索引；
    - ElasticSearch 5的程序环境：
        - 配置文件：
            - /etc/elasticsearch/elasticsearch.yml
            - /etc/elasticsearch/jvm.options
            - /etc/elasticsearch/log4j2.properties
        - Unit File：elasticsearch.service
        - 程序文件：
            - /usr/share/elasticsearch/bin/elasticsearch
            - /usr/share/elasticsearch/bin/elasticsearch-keystore：
            - /usr/share/elasticsearch/bin/elasticsearch-plugin：管理插件程序
        - port：
            - 搜索服务：9200/tcp
            - 集群服务：9300/tcp

- els集群的工作逻辑：
    - 多播、单播：9300/tcp
    - 关键因素：clustername
    - 所有节点选举一个主节点，负责管理整个集群的状态(green/yellow/red)，以及各shards的分布方式；

- elasticsearch.yml配置文件：
    ```
    cluster.name: myels
    node.name: node1
    path.data: /data/els/data   # 可以单独放在一个磁盘分区
    path.logs: /data/els/logs   # 可以单独放在一个磁盘分区
    network.host: 0.0.0.0
    http.port: 9200
    discovery.zen.ping.unicast.hosts: ["node1", "node2", "node3"]
    discovery.zen.minimum_master_nodes: 2
    ```

- RESTful API:
    - RESTful API基本测试命令：`curl -X<VERB> '<PROTOCOL>://<HOST>:<PORT>/<PATH>?<QUERY_STRING>' -d '<BODY>'`
        - `<BODY>`: json格式的请求主体；
        - `<VERB>`: GET，POST，PUT，DELETE, 特殊：`/_cat`, `/_search`, `/_cluster`
        - `<PATH>`: /index_name/type/Document_ID/
    - 举例：
        - `curl -XGET 'http://10.1.0.67:9200/_cluster/health?pretty=true'    # 集群健康状态`
        - `curl -XGET 'http://10.1.0.67:9200/_cluster/stats?pretty=true'`
        - `curl -XGET 'http://10.1.0.67:9200/_cat/nodes?pretty'              # 有几个主节点`
        - `curl -XGET 'http://10.1.0.67:9200/_cat/health?pretty'`
    - 创建文档：`curl  -XPUT`
    - 文档：`{"key1": "value1", "key2": value, ...}`

- ELS：分布式、开源、RESTful、近乎实时
    - 集群：一个或多个节点的集合；
    - 节点：运行的单个els实例；
    - 索引：切成多个独立的shard；（以Lucene的视角，每个shard即为一个独立而完整的索引）
        - primary shard：r/w
        - replica shard: r

![elk.query](https://github.com/Minions1128/net_tech_notes/blob/master/img/elk.query.png)

- 查询：
    - `curl -X GET '<SCHEME://<HOST>:<PORT>/[INDEX/TYPE/]_search?q=KEYWORD&sort=DOMAIN:[asc|desc]&from=#&size=#&_source=DOMAIN_LIST'`
        - `/_search`：搜索所有的索引和类型；
        - `/INDEX_NAME/_search`：搜索指定的单个索引；
        - `/INDEX1,INDEX2/_search`：搜索指定的多个索引；
        - `/s*/_search`：通配符方式（搜索所有以s开头的索引）；
        - `/INDEX_NAME/TYPE_NAME/_search`：搜索指定的单个索引的指定类型；
    - 简单字符串的语法格式：http://lucene.apache.org/core/6_6_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#package.description
    - 查询类型：
        - Query DSL
        - 简单字符串；
    - 文本匹配的查询条件：
        - (1) `q=KEYWORD`, 相当于`q=_all:KEYWORD`
        - (2) `q=DOMAIN:KEYWORD`
            ```
            {
                "name" : "Docker in Action",
                "publisher" : "wrox",
                "datatime" : "2015-12-01",
                "author" : "Blair"
            }
            _all: "Docker in Action Wrox 2015-12-01 Blair"
            ```
    - 修改默认查询域：df属性
    - 查询修饰符：https://www.elastic.co/guide/en/elasticsearch/reference/current/search-uri-request.html
    - 自定义分析器(切词器)：analyzer=
    - 默认操作符：OR/AND： default_operator, 默认值为OR
    - 返回字段：fields=
        - 注：5.X不支持；
    - 结果排序：sort=DOMAIN:[asc|desc]
    - 搜索超时：timeout=
    - 查询结果窗口：
        - from=，默认为0；
        - size=, 默认为10；
    - Lucene的查询语法：
        - q=
            - KEYWORD
            - DOMAIN:KEYWORD
        - +DOMAIN:KEYWORD -DOMAIN:KEYWORD 
    - els支持从多类型的查询：Full text queries

       
ELK：
        E: elasticsearch
        L: logstash，日志收集工具；
            ELK Beats Platform：
                PacketBeat：网络报文分析工具，统计收集报文信息；
                Filebeat：是logstash forwarder的替换者，因此是一个日志收集工具；
                Topbeat：用来收集系统基础数据，如cpu、内存、io等相关的统计信息；
                Winlogbeat
                Metricbeat
                用户自定义beat：
        
                
        input {
            ...
        }
        
        filter{
            ...
        }
        
        output {
            ...
        }
                
        
        grok：
            %{SYNTAX:SEMANTIC}
                SYNTAX：预定义的模式名称；
                SEMANTIC：给模式匹配到的文本所定义的键名；
                
                1.2.3.4 GET /logo.jpg  203 0.12
                %{IP:clientip} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}
                
                { clientip: 1.2.3.4, method: GET, request: /logo.jpg, bytes: 203, duration: 0.12}
                
                
                %{IPORHOST:client_ip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "(?:%{WORD:verb} %{NOTSPACE:request}(?: HTTP/%{NUMBER:http_version})?|-)" %{HOST:domain} %{NUMBER:response} (?:%{NUMBER:bytes}|-) %{QS:referrer} %{QS:agent} "(%{WORD:x_forword}|-)" (%{URIHOST:upstream_host}|-) %{NUMBER:upstream_response} (%{WORD:upstream_cache_status}|-) %{QS:upstream_content_type} (%{BASE16FLOAT:upstream_response_time}) > (%{BASE16FLOAT:request_time})
                
                 "message" => "%{IPORHOST:clientip} \[%{HTTPDATE:time}\] \"%{WORD:verb} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}\" %{NUMBER:http_status_code} %{NUMBER:bytes} \"(?<http_referer>\S+)\" \"(?<http_user_agent>\S+)\" \"(?<http_x_forwarded_for>\S+)\""
                 
                 filter {
                    grok {
                        match => {
                            "message" => "%{IPORHOST:clientip} \[%{HTTPDATE:time}\] \"%{WORD:verb} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion}\" %{NUMBER:http_status_code} %{NUMBER:bytes} \"(?<http_referer>\S+)\" \"(?<http_user_agent>\S+)\" \"(?<http_x_forwarded_for>\S+)\""
                        }
                        remote_field: message
                    }   
                }
                
                nginx.remote.ip
                [nginx][remote][ip] 
                
                
                filter {
                    grok {
                        match => { "message" => ["%{IPORHOST:[nginx][access][remote_ip]} - %{DATA:[nginx][access][user_name]} \[%{HTTPDATE:[nginx
                        ][access][time]}\] \"%{WORD:[nginx][access][method]} %{DATA:[nginx][access][url]} HTTP/%{NUMBER:[nginx][access][http_version]}\
                        " %{NUMBER:[nginx][access][response_code]} %{NUMBER:[nginx][access][body_sent][bytes]} \"%{DATA:[nginx][access][referrer]}\" \"
                        %{DATA:[nginx][access][agent]}\""] }
                        remove_field => "message"
                    }  
                    date {
                        match => [ "[nginx][access][time]", "dd/MMM/YYYY:H:m:s Z" ]
                        remove_field => "[nginx][access][time]"
                    }  
                    useragent {
                        source => "[nginx][access][agent]"
                        target => "[nginx][access][user_agent]"
                        remove_field => "[nginx][access][agent]"
                    }  
                    geoip {
                        source => "[nginx][access][remote_ip]"
                        target => "geoip"
                        database => "/etc/logstash/GeoLite2-City.mmdb"
                    }  
                                                                    
                }   
                
                output {                                                                                                     
                    elasticsearch {                                                                                      
                        hosts => ["node1:9200","node2:9200","node3:9200"]                                            
                        index => "logstash-ngxaccesslog-%{+YYYY.MM.dd}"                                              
                    }                                                                                                    
                }
                
                注意：
                    1、输出的日志文件名必须以“logstash-”开头，方可将geoip.location的type自动设定为"geo_point"；
                    2、target => "geoip"
                
        除了使用grok filter plugin实现日志输出json化之外，还可以直接配置服务输出为json格式；
