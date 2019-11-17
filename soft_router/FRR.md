# FRR

- FRRouting (FRR) is an IP routing protocol suite for Linux and Unix platforms which includes protocol daemons for BGP, IS-IS, LDP, OSPF, PIM, and RIP.
- https://github.com/FRRouting/frr

## Installation(el7)

- `base_path=$(pwd)`

- Download
    - frr: `git clone https://github.com/FRRouting/frr.git`
    - libyang: `https://github.com/CESNET/libyang.git`

- Install required packages：
    - Yum install required packages
        ```
        yum -y install git autoconf automake libtool make \
            readline-devel texinfo net-snmp-devel groff pkgconfig \
            json-c-devel pam-devel bison flex pytest c-ares-devel \
            python-devel systemd-devel python-sphinx cmake
        ```
    - make install libyang
        ```
        cd libyang
        mkdir build; cd build
        cmake -DENABLE_LYD_PRIV=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr \
              -DCMAKE_BUILD_TYPE:String="Release" \
              -DENABLE_CACHE=OFF ..
        make
        make install
        ```

- Create user and groups
    ```
    groupadd -g 92 frr
    groupadd -r -g 85 frrvty
    useradd \
        -u 92 \
        -g 92 \
        -M -r \
        -G frrvty \
        -s /sbin/nologin \
        -c "FRR FRRouting suite" \
        -d /var/run/frr frr
    ```

- Make install frr
    ```
    cd "$base_path"/frr/frr
    ./bootstrap.sh
    ./configure \
        --bindir=/usr/bin \
        --sbindir=/usr/lib/frr \
        --sysconfdir=/etc/frr \
        --libdir=/usr/lib/frr \
        --libexecdir=/usr/lib/frr \
        --localstatedir=/var/run/frr \
        --with-moduledir=/usr/lib/frr/modules \
        --enable-snmp=agentx \
        --enable-multipath=64 \
        --enable-user=frr \
        --enable-group=frr \
        --enable-vty-group=frrvty \
        --enable-systemd=yes \
        --disable-exampledir \
        --disable-ldpd \
        --enable-fpm \
        --with-pkg-git-version \
        --with-pkg-extra-version=-MyOwnFRRVersion
    make
    make check
    make install
    ```

- Create empty FRR configuration files
    ```
    mkdir /var/log/frr
    mkdir /etc/frr
    touch /etc/frr/zebra.conf
    touch /etc/frr/bgpd.conf
    touch /etc/frr/ospfd.conf
    touch /etc/frr/ospf6d.conf
    touch /etc/frr/isisd.conf
    touch /etc/frr/ripd.conf
    touch /etc/frr/ripngd.conf
    touch /etc/frr/pimd.conf
    touch /etc/frr/nhrpd.conf
    touch /etc/frr/eigrpd.conf
    touch /etc/frr/babeld.conf
    chown -R frr:frr /etc/frr/
    touch /etc/frr/vtysh.conf
    chown frr:frrvty /etc/frr/vtysh.conf
    chmod 640 /etc/frr/*.conf
    ```

- Install daemon config file
    ```
    # find $base_path -name "daemons"
    install -p -m 644 $base_path/frr/frr/tools/etc/frr/daemons /etc/frr/
    chown frr:frr /etc/frr/daemons

    # enable bgpd, ospfd, ospf6d for example
    sed -i 's/bgpd=no/bgpd=yes/g'  /etc/frr/daemons
    sed -i 's/ospfd=no/ospfd=yes/g'  /etc/frr/daemons
    sed -i 's/ospf6d=no/ospf6d=yes/g'  /etc/frr/daemons
    ```

- Enable IP & IPv6 forwarding
    ```
    echo "net.ipv4.conf.all.forwarding=1" >  /etc/sysctl.d/90-routing-sysctl.conf
    echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.d/90-routing-sysctl.conf
    sysctl -p /etc/sysctl.d/90-routing-sysctl.conf
    ```

- Install frr Service and redhat init files
    ```
    # find $base_path -name "frr.service"
    # find $base_path -name "frr.init.in"
    install -p -m 644 $base_path/frr/frr/tools/frr.service /usr/lib/systemd/system/frr.service
    install -p -m 755 $base_path/frr/frr/solaris/frr.init.in /usr/lib/frr/frr.init
    ```

- Register the systemd files
    ```
    systemctl preset frr.service
    systemctl enable frr
    systemctl start frr
    cd $base_path/..
    ```

- Example configuration for vtysh
    ```
    # Enter vtysh
    ]# vtysh

    # conf t
    # password Ospf.1234
    # enable password Abcd.1234
    # !
    # interface eth4
    #  ip address 10.80.80.139/24
    #  ip ospf message-digest-key 1 md5 ifeng888
    # !
    # interface lo
    #  ip address 10.85.2.2/32
    # !
    # router ospf
    #  ospf router-id 10.80.80.139
    #  network 10.80.80.0/24 area 12
    #  network 10.85.2.2/32 area 12
    #  area 12 authentication message-digest
    # end
    # wr
    # sh run
    # sh ip ospf nei
    # sh ip route
    # exit
    # ip r
    ```
