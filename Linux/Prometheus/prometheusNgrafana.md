# 基于 docker 搭建 Prometheus & Grafana

- 参考: http://www.ywnds.com/?p=9656

## 0. 基本环境准备

```sh
# 镜像下载
docker pull prom/prometheus
docker pull prom/node-exporter
docker pull grafana/grafana
docker pull prom/alertmanager

# 确定网络接口名称
itf=en0
```

## 1. 启动 node-exporter

```sh
sudo docker run -d \
    -p 9100:9100 \
    -v "/proc:/host/proc:ro" \
    -v "/sys:/host/sys:ro" \
    -v "/:/rootfs:ro" \
    --name=prom-node1 \
    prom/node-exporter

# check 端口
netstat -tan|egrep 9100
```

- 访问 url: http://localhost:9100/metrics

## 2. 启动 prometheus

```sh
# 编辑配置文件
# 确定网络接口名称
itf=en0
mkdir -pv ~/Data/prometheus
cat << EOF > ~/Data/prometheus/prometheus.yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ["localhost:9090"]
        labels:
          instance: prometheus

  - job_name: linux
    static_configs:
      - targets: ["$(ip a show dev $itf|egrep -w inet|awk '{print$2}'|awk -F/ '{print$1}'):9100"]
        labels:
          instance: localhost
EOF

# 启动 promethus
docker run -d \
    -p 9090:9090 \
    -v ~/Data/prometheus:/etc/prometheus \
    --name=prometheus1 \
    prom/prometheus

# check 端口
netstat -tan|egrep 9090
```

- 访问 url
    - http://localhost:9090/graph
    - http://localhost:9090/targets

## 3. 启动 grafana

```sh
# 新建储存数据文件夹
mkdir -pv ~/Data/grafana-storage
chmod -R 777 ~/Data/grafana-storage

# 启动 grafana
docker run -d \
    -p 3000:3000 \
    -v ~/Data/grafana-storage:/var/lib/grafana \
    --name=grafana1 \
    grafana/grafana

# check 端口
netstat -tan|egrep 3000
```

- 访问 url: http://localhost:3000/

- 配置数据源

## 4. alertmanager

- alertmanager 启动:

```sh
mkdir -pv ~/Data/alertmanager
cat << EOF > ~/Data/alertmanager/config.yml
global:
  smtp_smarthost: 'smtp.163.com:25'
  smtp_from: 'zhejian_shen@163.com'
  smtp_auth_username: 'zhejian_shen@163.com'
  smtp_auth_password: '123456789'
  smtp_require_tls: false

route:
  group_interval: 1m
  repeat_interval: 1m
  receiver: 'noc'
  routes:
  - match:
      team: noc
      receiver: 'noc'
  - match_re:
       team: "^ops$"
       receiver: 'ops'

receivers:
  - name: 'noc'
    email_configs:
    - to: 'zhejian_shen@163.com'
  - name: 'ops'
    email_configs:
    - to: 'shenzhejian@vip.qq.com'
EOF
docker run -d -p 9093:9093 \
    -v ~/Data/alertmanager/:/etc/alertmanager/ \
    --name=alertmanager1 \
    prom/alertmanager \
    --config.file=/etc/alertmanager/config.yml
```

- 修改 prometheus 配置, 并重新启动

```sh
cat << EOF > ~/Data/prometheus/rules/alert.yml
groups:
  - name: test-rule
    rules:
      - alert: NetworkMore2K
        # 告警名称
        expr: sum(rate(node_network_transmit_bytes_total[1m])) + sum(rate(node_network_receive_bytes_total[1m])) > 2048
        # 表达式
        for: 60s
        # 表达式为 true 后, 进入 pending 状态; 持续 for 定义的时间(60s)后开始报警, 此时状态为 firing; 表达式为 false 后, 进入 inactive 状态
        labels:
          team: noc
          # 告警规则被激活后, 相关时间序列上的所有标签都会添加到生成告警实例之上, label 允许用户在告警上附加其他自定义标签, 该标签支持模版化;
          # 告警的名称及其label即为告警标识
        annotations:
          summary: "{{\$labels.instance}}: NetworkMore2K"
          description: "{{ \$labels.instance }}: NetworkMore2K (current value is: {{ \$value }})"
          # 在报警添加的注释
      - alert: NetworkMore1M
        expr: sum(rate(node_network_transmit_bytes_total[1m])) + sum(rate(node_network_receive_bytes_total[1m])) > 1048576
        for: 60s
        labels:
          team: ops
        annotations:
          summary: "{{\$labels.instance}}: NetworkMore1M"
          description: "{{ \$labels.instance }}: NetworkMore1M (current value is: {{ \$value }})"
EOF
itf=en0
cat << EOF >> ~/Data/prometheus/prometheus.yml

# rule file
rule_files:
  - "rules/*.yml"

# Alertmanager configuration
alerting:
  alertmanagers:
  - scheme: http
  - static_configs:
    - targets: ["$(ip a show dev $itf|egrep -w inet|awk '{print$2}'|awk -F/ '{print$1}'):9093"]

# 此处也可以基于文件的添加方式, 使用 file_sd_configs
EOF
docker restart prometheus1
```
