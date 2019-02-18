# DHCP

`发行版为Ubuntu`

配置步骤：
1. 安装
```
apt install isc-dhcp-server
```
2. 修改DHCP接口信息
```
# Ubuntu
vim /etc/default/isc-dhcp-server
INTERFACES="ens32"

# Centos 6
vim /etc/sysconfig/network-scripts/ifcfg-eth0
```
3. 配置接口IP地址为固定IP地址
```
vim /etc/network/interfaces
auto ens32
iface ens32 inet static
pre-up ifconfig ens32 hw ether aa:aa:dd:dd:22:22
address 10.10.51.121
netmask 255.255.255.0
gateway 10.10.51.1
```
4. 配置DHCP信息
```
vim /etc/dhcp/dhcpd.conf
# 全局信息
option domain-name "example.com";
option domain-name-servers ns1.example.com, ns2.example.com;
default-lease-time 3600; 
max-lease-time 7200;
authoritative;
option voip-cfg code 242 = string;  # 自定义option

# 配置一个DHCP池
subnet 10.10.51.0 netmask 255.255.255.0 {
    option routers              10.10.51.1;
    option subnet-mask          255.255.255.0;
    option domain-search        "example.com";
    option domain-name-servers  10.10.51.121;
    option voip-cfg             "MCIPADD=10.0.0.1,HTTPSRVR=10.0.0.2";
    range   10.10.51.10    10.10.51.20;
}

# 为单个主机分配地址
host szj-node {
  hardware ethernet 00:f0:m4:6y:89:0g;
  fixed-address 10.10.51.101;
}
```
5. 重启服务
```
Ubuntu: 
service isc-dhcp-server restart
```

Centos 6

|  | 启用 | 停止  |
| :------------ | :------------ | :------------ |
| 第一种 | `# /etc/init.d/dhcpd start` | `# /etc/init.d/dhcpd stop` |
| 第二种 | `# service dhcpd start` | `# service dhcpd stop` |

查看DHCP是否重启成功

`netstat -panu | grep dhc*`

5. 查看信息
```
/var/lib/dhcp/dhcpd.leases
```
