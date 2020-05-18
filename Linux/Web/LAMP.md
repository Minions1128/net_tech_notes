# LAMP

- LAPM
    - Linux
    - Apache
    - Mysql, Mariadb
    - PHP, Perl, Python

- WEB资源类型:
    - 静态资源: 原始形式与响应内容一致;
    - 动态资源: 原始形式通常为程序文件, 需要在服务器端执行之后, 将执行结果返回给客户端;

- PHP, Personal Home Page, Hypertext Preprocessor, 脚本语言解释器
    - php环境配置文件: `/etc/php.ini`, `/etc/php.d/*.ini`
        - ini:
            ```ini
            [foo]: Section Header
            directive = value

            注释符: 较新的版本中, 已经完全使用; 进行注释;
            #: 纯粹的注释信息
            ;: 用于注释可启用的directive
            ```
        - 连接池
            ```ini
            pm = static|dynamic
                static: 固定数量的子进程; pm.max_children;
                dynamic: 子进程数据以动态模式管理;
                    pm.start_servers
                    pm.min_spare_servers
                    pm.max_spare_servers
                    ;pm.max_requests = 500
            ```
    - 服务配置文件: `/etc/php-fpm.conf`, `/etc/php-fpm.d/*.conf`
    - 配置文件在php解释器启动时被读取, 因此, 对配置文件的修改如何生效?
        - Modules: 重启httpd服务;
        - FastCGI: 重启php-fpm服务
    - php.ini的核心配置选项文档: http://php.net/manual/zh/ini.core.php
    - php.ini配置选项列表: http://php.net/manual/zh/ini.list.php

- php测试代码

```php
<php?
    phpinfo();
?>
```

- php连接mysql的测试代码

```php
<?php
    $conn = mysql_connect('172.16.100.67','testuser','testpass');
    if ($conn)
        echo "OK";
    else
        echo "Failure";
?>
```

- 安装lamp:
    - 程序包:
        - Modules: httpd, php, php-mysql, mariadb-server, (mysql-server)
        - FastCGI: httpd, php-fpm, php-mysql, mariadb-server, (mysql-server)
    - 服务
        - service httpd  tart
        - service mysqld start
        - systemctl start mariadb.service

- php-fpm:
    - CentOS 6:
        - PHP-5.3.2-: 默认不支持fpm机制; 需要自行打补丁并编译安装;
        - httpd-2.2: 默认不支持fcgi协议, 需要自行编译此模块;
        - 解决方案: 编译安装httpd-2.4, php-5.3.3+;
    - CentOS 7:
        - httpd-2.4: rpm包默认编译支持了fcgi模块;
        - php-fpm包: 专用于将php运行于fpm模式;

- 创建session目录, 并确保运行php-fpm进程的用户对此目录有读写权限;

```sh
mkdir /var/lib/php/session
chown apache.apache /var/lib/php/session
```

- (1) 配置httpd, 添加/etc/httpd/conf.d/fcgi.conf配置文件, 内容类似:

```ini
DirectoryIndex index.php
ProxyRequests Off
ProxyPassMatch ^/(.*\.php)$  fcgi://127.0.0.1:9000/var/www/html/$1
```

- (2) 虚拟主机配置

```ini
DirectoryIndex index.php

<VirtualHost *:80>
    ServerName www.b.net
    DocumentRoot /apps/vhosts/b.net
    ProxyRequests Off
    ProxyPassMatch ^/(.*\.php)$  fcgi://127.0.0.1:9000/apps/vhosts/b.net/$1

    <Directory "/apps/vhosts/b.net">
        Options None
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
```

- 编译安装lamp:
    - httpd: 编译安装, httpd-2.4
        ```sh
        yum install pcre-devel apr-devel apr-util-devel openssl-devel
        ./configure --prefix=/usr/local/apache24 --sysconfdir=/etc/httpd24 \
            --enable-so --enable-ssl --enable-rewrite --with-zlib --with-pcre \
            --with-apr=/usr --with-apr-util=/usr --enable-modules=most \
            --enable-mpms-shared=all --with-mpm=prefork
        make -j 4 && make install
        ```
    - php5: 编译安装, php-5.4
        ```sh
        yum install libxml2-devel libmcrypt-devel
        ./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql \
            --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config \
            --enable-mbstring --with-png-dir --with-jpeg-dir \
            --with-freetype-dir --with-zlib --with-libxml-dir=/usr \
            --enable-xml --enable-sockets \
            --with-apxs2=/usr/local/apache24/bin/apxs --with-mcrypt \
            --with-config-file-path=/etc \
            --with-config-file-scan-dir=/etc/php.d --with-bz2
            make -j 4 && make install
        ```
    - mairadb: 通用二进制格式, mariadb-5.5
    - 注意: 任何一个程序包被编译操作依赖到时, 需要安装此程序包的“开发”组件, 其包名一般类似于name-devel-VERSION;

- xcache:
    - epel源中: php-xcache
    - 编译安装xache的方法:
        ```sh
        yum install php-devel
        cd  xcache-3.2.0
        phpize
        ./configure --enable-xcache  --with-php-config=/usr/bin/php-config
        make && make install
        cp  xcache.ini  /etc/php.d/
        ```
