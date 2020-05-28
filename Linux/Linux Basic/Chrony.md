# Chrony

## Chrony

- Chrony is a versatile implementation of the Network Time Protocol (NTP). It can synchronize the system clock with NTP servers, reference clocks (e.g. GPS receiver), and manual input using wristwatch and keyboard. It can also operate as an NTPv4 (RFC 5905) server and peer to provide a time service to other computers in the network.

- Typical accuracy between two machines synchronised over the Internet is within a few milliseconds; on a LAN, accuracy is typically in tens of microseconds. With hardware timestamping, or a hardware reference clock, sub-microsecond accuracy may be possible.

- Two programs are included in chrony, chronyd is a daemon that can be started at boot time and chronyc is a command-line interface program which can be used to monitor chronyd’s performance and to change various operating parameters whilst it is running.

- 程序环境:
    - 监听端口: 323
    - 配置文件: /etc/chrony.conf
    - 主程序文件: chronyd
    - 工具程序: chronyc
        - `sources [-v]`: Display information about current sources
        - `sourcestats [-v]`: Display statistics about collected measurements
    - unit file: chronyd.service

- 配置文件: chrony.conf
    - server: 指明时间服务器地址;
    - allow NETADD/NETMASK
    - allow all: 允许所有客户端主机;
    - deny NETADDR/NETMASK
    - deny all: 拒绝所有客户端;
    - bindcmdaddress: 命令管理接口监听的地址;
    - local stratum 10: 即使自己未能通过网络时间服务器同步到时间, 也允许将本地时间作为标准时间授时给其它客户端;
