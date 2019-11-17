# BIRD

`BIRD` is actually an acronym standing for `BIRD Internet Routing Daemon'

## 安装

- 依赖安装
    ```
    yum -y install \
        readline-devel \
        ncurses-devel
    ```

- git初始化：`git init`

- make安装
    ```
    ./configure
    make
    make install
    vi /usr/local/etc/bird.conf
    bird
    ```

## 配置举例：
```
log "/var/log/bird.log" { debug, trace, info, remote, warning, error, auth, fatal, bug };
router id 10.211.1.213;
protocol device {
}
protocol direct {
    disabled;                   # Disable by default
    ipv4;                       # Connect to default IPv4 table
    ipv6;                       # ... and to default IPv6 table
}
protocol kernel {
    ipv4 {                      # Connect protocol to IPv4 table by channel
        export all;             # Export to protocol. default is export none
    };
}
protocol kernel {
    ipv6 { export all; };
}
protocol static {
    ipv4;                       # Again, IPv4 channel with default options
}
 protocol ospf v3 {
    ipv6 {
        import all;
        export where source = RTS_STATIC;
    };
    area 0 {
        interface "eth0" {
            type broadcast;     # Detected by default
            cost 1600;          # Interface metric
            hello 3;            # Default hello perid 10 is too long
            dead 9;
        };
        interface "eth1" {
            type broadcast;     # Detected by default
            cost 1600;          # Interface metric
            hello 3;            # Default hello perid 10 is too long
            dead 9;
        };
        interface "lo" {
            stub;               # Stub interface, just propagate it
        };
    };
}
```
