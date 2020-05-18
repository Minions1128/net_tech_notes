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
    - 配置文件: `/etc/php.ini`, `/etc/php.d/*.ini`
        - ini:
            ```ini
            [foo]: Section Header
            directive = value

            注释符: 较新的版本中, 已经完全使用; 进行注释;
            #: 纯粹的注释信息
            ;: 用于注释可启用的directive
            ```
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
