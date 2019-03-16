# DHCP

## 概述

- 服务端监听UDP67，客户端监听UDP68

- 将一个主机接入TCP/IP网络，要配置以下参数：
    - IP/mask
    - Gateway
    - DNS server
    - Wins Server, NTP server

- [DHCP 工作过程](https://www.zyops.com/dhcp-working-procedure/ "DHCP 工作过程")

- centos实现DHCP服务
    - dhcp
        - dhcpd：`dhcpd.service`
        - dhcrelay：`dhcrelay.service`
    - dnsmasq


## 配置步骤

1. 安装
```
apt install isc-dhcp-server # Ubuntu
yum install dhcp            # centos
```
2. 修改DHCP接口信息
```
# Ubuntu
# 文件：
/etc/default/isc-dhcp-server
INTERFACES="ens32"
```
3. 配置接口IP地址为固定IP地址
```
# Ubuntu
# 文件：
/etc/network/interfaces
auto ens32
iface ens32 inet static
pre-up ifconfig ens32 hw ether aa:aa:dd:dd:22:22
address 10.10.51.121
netmask 255.255.255.0
gateway 10.10.51.1

# Centos 6
# 文件：
/etc/sysconfig/network-scripts/ifcfg-eth0
```
4. 配置DHCP信息
```
#文件
/etc/dhcp/dhcpd.conf
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

## DHCP的维护

- 重启服务
```
service isc-dhcp-server restart # Ubuntu
service dhcpd restart # centos 6
systemctl restart dhcpd.service
/etc/init.d/dhcpd start
/etc/init.d/dhcpd stop
```

- 查看DHCP是否重启成功
```
netstat -panu | grep dhc*
ss -unl | grep 67
```

- DHCP绑定信息：`/var/lib/dhcp/dhcpd.leases`

- DHCP日志：`cat messages | grep dhcpd | grep "Mar 15" | grep "10.90.64"`
