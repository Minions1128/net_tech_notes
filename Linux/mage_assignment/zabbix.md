# ZABBIX
- 一个开源的监控软件，其他类似的软件还有：cacti，nagios，ganglia

## 监控
- 监控指标：硬件(CPU、内存、终端次数)、软件、业务
- 被监控的对象：主机、交换机、路由器、UPS等
- 监控的几个功能
    - 采样：使用传感器（sensor）采样，周期性地获取某个关注指标的数据
        - 采集数据的通道：
            - SSH/telnet
            - agent/master
            - IPMI
            - SNMP
            - JMX
    - 存储：数据（历史数据、趋势数据）
        - 存储系统
            - 关系型数据库：MySQL，PGSQL，Oracle，
            - RRD：
            - NoSQL：redis/mongo/时间序列数据库
    - 展示：图形化展示
    - 报警：通知管理员。途径有：邮件、短信、脚本

## zabbix系统架构
![zabbix_arch](https://github.com/Minions1128/net_tech_notes/blob/master/img/zabbix_arch.png)
