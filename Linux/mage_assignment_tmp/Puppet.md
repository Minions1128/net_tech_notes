# Puppet

## 概述

- 运维的工作：发布、变更、故障处理

- Provisioning Activity
    - OS Provision：
        - bare metal：pxe, cobbler
        - virutal machine：image file template
    - Configuration：
        - ansible(agentless)
        - puppet(master/agent)（ruby）
        - saltstack（python）
    - Command and Control：
        - ansible(playbook)
        - fabric(fab)
        - func

## Puppet

- puppet的工作模型：
    - 单机模型：手动应用清单；
        - 配置文件：/etc/puppet/puppet.conf
        - 主程序：/usr/bin/puppet
    - master/agent：由agent周期性地向Master请求清单并自动应用于本地；

- puppet程序：Usage: `puppet <subcommand> [options] <action> [options]`
    - help              Display Puppet help.
    - apply             Apply Puppet manifests locally
    - describe       Display help about resource types
    - agent            The puppet agent daemon
    - master          The puppet master daemon
    - module        Creates, installs and searches for modules on the Puppet Forge
    - `'puppet help <subcommand>' for help on a specific subcommand.`
    - `'puppet help <subcommand> <action>' for help on a specific subcommand action.`

- puppet apply：Applies a standalone Puppet manifest to the local system.
    - `puppet apply  [-d|--debug] [-v|--verbose] [-e|--execute] [--noop] <file>`

### Puppet 资源

- 资源抽象的纬度（RAL如何抽象资源的？）：
    - 类型：具有类似属性的组件，例如package、service、file；
    - 将资源的属性或状态与其实现方式分离；
    - 仅描述资源的目标状态，也即期望其实现的结果状态，而不是具体过程； 
    - RAL由“类型”和提供者(provider)；

- puppet describe：
    - Prints help about Puppet resource types, providers, and metaparameters.
    - `puppet describe [-h|--help] [-s|--short] [-p|--providers] [-l|--list] [-m|--meta] [type]`
        - -l：列出所有资源类型；
        - -s：显示指定类型的简要帮助信息；
        - -m：显示指定类型的元参数，一般与-s一同使用；

- 资源定义：向资源类型的属性赋值来实现，可称为资源类型实例化；
    - 定义了资源实例的文件即清单，manifest；
    - 定义资源的语法：
        ```
        type {'title':
            attribute1  => value1,
            atrribute2  => value2,
            ……
        }
        ```
    - 注意：type必须使用小写字符；title是一个字符串，在同一类型中必须惟一；

- 资源属性中的三个特殊属性：
    - namevar， 可简称为name；
    - ensure：资源的目标状态； 
    - provider：指明资源的管理接口；

- 资源类型：
    - group：Manage groups. 属性包括：
        - name：组名；
        - gid：GID；
        - system：是否为系统组，true OR false；
        - ensure：目标状态，present/absent；
        - members：成员用户；
    - user：Manage users.
        - name：用户名；
        - uid: UID;
        - gid：基本组ID；
        - groups：附加组，不能包含基本组；
        - comment：注释； 
        - expiry：过期时间 ；
        - home：家目录； 
        - shell：默认shell类型；
        - system：是否为系统用户 ；
        - ensure：present/absent；
        - password：加密后的密码串； 

    关系元参数：before/require
        A before B: B依赖于A，定义在A资源中；
            {
                ...
                before  => Type['B'],
                ...
            }
        B require A： B依赖于A，定义在B资源中；
            {
                ...
                require => Type['A'],
                ...
            }
            
    package：
        Manage packages.
        
        属性：
            ensure：installed, present, latest, absent
            name：包名；
            source：程序包来源，仅对不会自动下载相关程序包的provider有用，例如rpm或dpkg；
            

                service：
                    Manage running services.
                    
                    属性：
                        ensure：Whether a service should be running. Valid values are `stopped` (also called `false`), `running` (also called `true`).
                        enable：Whether a service should be enabled to start at boot. Valid values are `true`, `false`, `manual`.
                        name：
                        path：The search path for finding init scripts.  Multiple values should be separated by colons or provided as an array. 脚本的搜索路径，默认为/etc/init.d/；
                        hasrestart：
                        hasstatus：
                        start：手动定义启动命令；
                        stop:
                        status：
                        restart：Specify a *restart* command manually.  If left unspecified, the service will be stopped and then started. 通常用于定义reload操作；
                        
                资源引用：
                    Type['title']
                    
                    类型的首字母必须大写；
                    
                资源有特殊属性：
                    名称变量(namevar)：
                        name可省略，此时将由title表示；
                    ensure：
                        定义资源的目标状态；
                    元参数：metaparameters
                        依赖关系：
                            before
                            require
                        通知关系：通知相关的其它资源进行“刷新”操作；
                            notify
                                A notify B：B依赖于A，且A发生改变后会通知B；
                                    {
                                        ...
                                        notify => Type['B'],
                                        ...
                                    }
                            subscribe
                                B subscribe A：B依赖于A，且B监控A资源的变化产生的事件；
                                    {
                                        ...
                                        subscribe => Type['A'],
                                        ...
                                    }

                file：
                    Manages files, including their content, ownership, and permissions.
                    
                    ensure：Whether the file should exist, and if so what kind of file it should be. Possible values are `present`, `absent`, `file`, `directory`, and `link`.
                        file：类型为普通文件，其内容由content属性生成或复制由source属性指向的文件路径来创建；
                        link：类型为符号链接文件，必须由target属性指明其链接的目标文件；
                        directory：类型为目录，可通过source指向的路径复制生成，recurse属性指明是否递归复制；
                    path：文件路径；
                    source：源文件；
                    content：文件内容；
                    target：符号链接的目标文件； 
                    owner：属主
                    group：属组
                    mode：权限；
                    atime/ctime/mtime：时间戳；
            
                通知元参数：
                    A notify B：B依赖于A，接受由A触发refresh；
                    B subscribe A：B依赖于A，接受由A触发refresh；
                    
                    示例1：
                        file{'test.txt':
                            path    => '/tmp/test.txt',
                            ensure  => file,
                            source  => '/etc/fstab',
                        }

                        file{'test.symlink':
                            path    => '/tmp/test.symlink',
                            ensure  => link,
                            target  => '/tmp/test.txt',
                            require => File['test.txt'],
                        }

                        file{'test.dir':
                            path    => '/tmp/test.dir',
                            ensure  => directory,
                            source  => '/etc/yum.repos.d/',
                            recurse => true,
                        }
                    
            示例2：
                service{'httpd':
                    ensure  => running,
                    enable  => true,
                    restart => 'systemctl restart httpd.service',
                #       subscribe       => File['httpd.conf'],
                }

                package{'httpd':
                    ensure  => installed,
                }

                file{'httpd.conf':
                    path    => '/etc/httpd/conf/httpd.conf',
                    source  => '/root/manifests/httpd.conf',
                    ensure  => file,
                    notify  => Service['httpd'],
                }

                Package['httpd'] -> File['httpd.conf'] -> Service['httpd']                          


回顾：
    Bootstraping，Configuration, Command and Control；
    
    puppet：Configuration
        apply：standalone
        master/agent：
        
    manifest：
        resource 
        node
        
    资源：resource 
        type{'title':
            atrribute => value,
            ...
        }
        
        关系元参数：before/require, notify/subscribe
        特殊参数：NameVar
        目标状态：ensure
        
    资源类型：group, user, package, service, file；exec, cron, notify, ...
        puppet describe 



Puppet(2) 

    资源类型：
        exec：
            Executes external commands. Any command in an `exec` resource **must** be able to run multiple times without causing harm --- that is, it must be *idempotent*.
            
            **command** (*namevar*)：要运行的命令；
            cwd：The directory from which to run the command.
            **creates**：文件路径，仅此路径表示的文件不存在时，command方才执行；
            user/group：运行命令的用户身份；
            path：The search path used for command execution. Commands must be fully qualified if no path is specified.
            onlyif：此属性指定一个命令，此命令正常（退出码为0）运行时，当前command才会运行；
            unless：此属性指定一个命令，此命令非正常（退出码为非0）运行时，当前command才会运行；
            refresh：重新执行当前command的替代命令；
            refreshonly：仅接收到订阅的资源的通知时方才运行；
            
        cron：
            Installs and manages cron jobs.  Every cron resource created by Puppet requires a command and at least one periodic attribute (hour, minute, month, monthday, weekday, or special).
            
            command：要执行的任务；
            ensure：present/absent；
            hour：
            minute:
            monthday:
            month:
            weekday：
            user：以哪个用户的身份运行命令
            target：添加为哪个用户的任务
            name：cron job的名称；
            
            示例：
                cron{'timesync':
                    command => '/usr/sbin/ntpdate 10.1.0.1 &> /dev/null',
                    ensure  => present,
                    minute  => '*/3',
                    user    => 'root',
                }           
            
        notify：
            Sends an arbitrary message to the agent run-time log.
            
            属性：
                message：信息内容
                name：信息名称；

        核心类型：
            group: 组
            user：用户
            packge：程序包 
            service：服务
            file：文件
            exec：执行自定义命令，要求幂等
            cron：周期性任务计划
            notify：通知
            
    puppet variable：
    
        $variable_name=value
        
        数据类型：
            字符型：引号可有可无；但单引号为强引用，双引号为弱引用；
            数值型：默认均识别为字符串，仅在数值上下文才以数值对待；
            数组：[]中以逗号分隔元素列表；
            布尔型值：true, false；
            hash：{}中以逗号分隔k/v数据列表； 键为字符型，值为任意puppet支持的类型；{ 'mon' => 'Monday', 'tue' => 'Tuesday', }；
            undef：未定义 ；
            
        正则表达式：
            (?<ENABLED OPTION>:<PATTERN>)
            (?-<DISABLED OPTION>:<PATTERN>)
            
                OPTIONS：
                    i：忽略字符大小写；
                    m：把.当换行符；
                    x：忽略<PATTERN>中的空白字符
                    
                (?i-mx:PATTERN）
                    
            不能赋值给变量 ，仅能用在接受=~或!~操作符的位置；
            
        puppet的变量类型：
            
            facts：
                由facter提供；top scope；
            内建变量：
                master端变量 
                agent端变量 
                parser变量
            用户自定义变量：
            
            变量有作用域，称为Scope；
                top scope：   $::var_name
                node scope
                class scope
                            
                
        puppet流程控制语句：
            if语句：
                if  CONDITION {
                    ...
                } else {
                    ...
                }
            
                CONDITION的给定方式：
                    (1) 变量
                    (2) 比较表达式 
                    (3) 有返回值的函数
                    
                
                    if $osfamily =~ /(?i-mx:debian)/ {
                        $webserver = 'apache2'
                    } else {
                        $webserver = 'httpd'
                    }

                    package{"$webserver":
                        ensure  => installed,
                        before  => [ File['httpd.conf'], Service['httpd'] ],
                    }

                    file{'httpd.conf':
                        path    => '/etc/httpd/conf/httpd.conf',
                        source  => '/root/manifests/httpd.conf',
                        ensure  => file,
                    }

                    service{'httpd':
                        ensure  => running,
                        enable  => true,
                        restart => 'systemctl restart httpd.service',
                        subscribe => File['httpd.conf'],
                    }           
                
                
            case语句：
                case CONTROL_EXPRESSION {
                    case1: { ... }
                    case2: { ... }
                    case3: { ... }
                    ...
                    default: { ... }
                }
                
                 CONTROL_EXPRESSION:
                    (1) 变量
                    (2) 表达式 
                    (3) 有返回值的函数
                    
                各case的给定方式：
                    (1) 直接字串；
                    (2) 变量 
                    (3) 有返回值的函数
                    (4) 正则表达式模式；
                    (5) default 

                    case $osfamily {
                        "RedHat": { $webserver='httpd' }
                        /(?i-mx:debian)/: { $webserver='apache2' }
                        default: { $webserver='httpd' }
                    }

                    package{"$webserver":
                        ensure  => installed,
                        before  => [ File['httpd.conf'], Service['httpd'] ],
                    }

                    file{'httpd.conf':
                        path    => '/etc/httpd/conf/httpd.conf',
                        source  => '/root/manifests/httpd.conf',
                        ensure  => file,
                    }

                    service{'httpd':
                        ensure  => running,
                        enable  => true,
                        restart => 'systemctl restart httpd.service',
                        subscribe => File['httpd.conf'],
                    }                   
                                        
            selector语句：
                CONTROL_VARIABLE ? {
                    case1 => value1,
                    case2 => value2,
                    ...
                    default => valueN,
                }
                
                CONTROL_VARIABLE的给定方法：
                    (1) 变量
                    (2) 有返回值的函数
                    
                各case的给定方式：
                    (1) 直接字串；
                    (2) 变量 
                    (3) 有返回值的函数
                    (4) 正则表达式模式；
                    (5) default 
                    
                    注意：不能使用列表格式；但可以是其它的selecor；
                    
                    $pkgname = $operatingsystem ? {
                        /(?i-mx:(ubuntu|debian))/       => 'apache2',
                        /(?i-mx:(redhat|fedora|centos))/        => 'httpd',
                        default => 'httpd',
                    }

                    package{"$pkgname":
                        ensure  => installed,
                    }           

                    示例2：
                    $webserver = $osfamily ? {
                        "Redhat" => 'httpd',
                        /(?i-mx:debian)/ => 'apache2',
                        default => 'httpd',
                    }


                    package{"$webserver":
                        ensure  => installed,
                        before  => [ File['httpd.conf'], Service['httpd'] ],
                    }

                    file{'httpd.conf':
                        path    => '/etc/httpd/conf/httpd.conf',
                        source  => '/root/manifests/httpd.conf',
                        ensure  => file,
                    }

                    service{'httpd':
                        ensure  => running,
                        enable  => true,
                        restart => 'systemctl restart httpd.service',
                        subscribe => File['httpd.conf'],
                    }                   
                    
    puppet的类：
        类：puppet中命名的代码模块，常用于定义一组通用目标的资源，可在puppet全局调用；
            类可以被继承，也可以包含子类；
            
        语法格式：
            class NAME {
                ...puppet code...
            }
            
            class NAME(parameter1, parameter2) {
                ...puppet code...
            }
            
        类代码只有声明后才会执行，调用方式：
            (1) include CLASS_NAME1, CLASS_NAME2, ...
            (2) class{'CLASS_NAME':
                attribute => value,
                 }
              
            示例1：
                class apache2 {
                    $webpkg = $operatingsystem ? {
                        /(?i-mx:(centos|redhat|fedora))/        => 'httpd',
                        /(?i-mx:(ubuntu|debian))/       => 'apache2',
                        default => 'httpd',
                    }

                    package{"$webpkg":
                        ensure  => installed,
                    }

                    file{'/etc/httpd/conf/httpd.conf':
                        ensure  => file,
                        owner   => root,
                        group   => root,
                        source  => '/tmp/httpd.conf',
                        require => Package["$webpkg"],
                        notify  => Service['httpd'],
                    }

                    service{'httpd':
                        ensure  => running,
                        enable  => true,
                    }
                }

                include apache2     
                
            示例2：
                class dbserver($pkgname) {
                    package{"$pkgname":
                        ensure  => latest,
                    }

                    service{"$pkgname":
                        ensure  => running,
                        enable  => true,
                    }
                }

                #include dbserver


                if $operatingsystem == "CentOS" {
                    $dbpkg = $operatingsystemmajrelease ? {
                        7 => 'mariadb-server',
                        default => 'mysqld-server',
                    }
                }

                class{'dbserver':
                    pkgname => $dbpkg,
                }
                
            类继承的方式：
                class SUB_CLASS_NAME inherits PARENT_CLASS_NAME {
                    ...puppet code...
                }
                
                示例：
                class nginx {
                    package{'nginx':
                        ensure  => installed,
                    }

                    service{'nginx':
                        ensure  => running,
                        enable  => true,
                        restart => '/usr/sbin/nginx -s reload',
                    }
                }

                class nginx::web inherits nginx {
                    Service['nginx'] {
                        subscribe => File['ngx-web.conf'],
                    }

                    file{'ngx-web.conf':
                        path    => '/etc/nginx/conf.d/ngx-web.conf',
                        ensure  => file,
                        source  => '/root/manifests/ngx-web.conf',
                    }
                }

                class nginx::proxy inherits nginx {
                    Service['nginx'] {
                        subscribe => File['ngx-proxy.conf'],
                    }

                    file{'ngx-proxy.conf':
                        path    => '/etc/nginx/conf.d/ngx-proxy.conf',
                        ensure  => file,
                        source  => '/root/manifests/ngx-proxy.conf',
                    }
                }

                include nginx::proxy    
                
            在子类中为父类的资源新增属性或覆盖指定的属性的值：
                Type['title'] {
                    attribute1 => value,
                    ...
                }
                
            在子类中为父类的资源的某属性增加新值：
                Type['title'] {
                    attribute1 +> value,
                    ...
                }           
                
    puppet模板：
        
        erb：模板语言，embedded ruby；
        
        puppet兼容的erb语法：
            https://docs.puppet.com/puppet/latest/reference/lang_template_erb.html
            
        file{'title':
            ensure  => file,
            content => template('/PATH/TO/ERB_FILE'),
        }
        
        文本文件中内嵌变量替换机制：
            <%= @VARIABLE_NAME %>
            
        示例：
            class nginx {
                package{'nginx':
                    ensure  => installed,
                }

                service{'nginx':
                    ensure  => running,
                    enable  => true,
                    require => Package['nginx'],
                }
            }

            class nginx::web inherits nginx {
                file{'ngx-web.conf':
                    path    => '/etc/nginx/conf.d/ngx-web.conf',
                    ensure  => file,
                    require => Package['nginx'],
                    source  => '/root/manifests/nginx/ngx-web.conf',
                }

                file{'nginx.conf':
                    path    => '/etc/nginx/nginx.conf',
                    ensure  => file,
                    content => template('/root/manifests/nginx.conf.erb'),
                    require => Package['nginx'],
                }

                Service['nginx'] {
                    subscribe => [ File['ngx-web.conf'], File['nginx.conf'] ],
                }
            }

            include nginx::web      
            
    puppet模块：
        模块就是一个按约定的、预定义的结构存放了多个文件或子目录的目录，目录里的这些文件或子目录必须遵循一定格式的命名规范； 
        puppet会在配置的路径下查找所需要的模块；
            
            MODULES_NAME：
                manifests/
                    init.pp
                files/
                templates/
                lib/
                spec/
                tests/
                
            模块名只能以小写字母开头，可以包含小写字母、数字和下划线；但不能使用”main"和"settings“；
                
                manifests/
                    init.pp：必须一个类定义，类名称必须与模块名称相同；
                files/：静态文件；
                    puppet URL: 
                        puppet:///modules/MODULE_NAME/FILE_NAME
                templates/：
                    tempate('MOD_NAME/TEMPLATE_FILE_NAME')
                lib/：插件目录，常用于存储自定义的facts以及自定义类型；
                spec/：类似于tests目录，存储lib/目录下插件的使用帮助和范例；
                tests/：当前模块的使用帮助或使用范例文件；
                
            注意：
                1、puppet 3.8及以后的版本中，资源清单文件的文件名要与文件听类名保持一致，例如某子类名为“base_class::child_class”，其文件名应该为child_class.pp；
                2、无需再资源清单文件中使用import语句；
                3、manifests目录下可存在多个清单文件，每个清单文件包含一个类，其文件名同类名；
                
                
        puppet config命令：
            获取或设定puppet配置参数；
                puppet config print [argument]
                
                puppet查找模块文件的路径：modulepath
                
            mariadb模块中的清单文件示例：
                class mariadb($datadir='/var/lib/mysql') {
                    package{'mariadb-server':
                        ensure  => installed,
                    }

                    file{"$datadir":
                        ensure  => directory,
                        owner   => mysql,
                        group   => mysql,
                        require => [ Package['mariadb-server'], Exec['createdir'], ],
                    }

                    exec{'createdir':
                        command => "mkdir -pv $datadir",
                        require => Package['mariadb-server'],
                        path => '/bin:/sbin:/usr/bin:/usr/sbin',
                        creates => “$datadir",
                    }

                    file{'my.cnf':
                        path    => '/etc/my.cnf',
                        content => template('mariadb/my.cnf.erb'),
                        require => Package['mariadb-server'],
                        notify  => Service['mariadb'],
                    }

                    service{'mariadb':
                        ensure  => running,
                        enable  => true,
                        require => [ Exec['createdir'], File["$datadir"], ],
                    }
                }
                
        实践作业：
            开发模块：
                memcached
                nginx（反代动态请求至httpd，work_process的值随主机CPU数量而变化）
                jdk（输出JAVA_HOME环境变量）
                tomcat
                mariadb 
                httpd(反代请求至tomcat，ajp连接器；mpm允许用户通过参数指定)



回顾：
    puppet核心资源类型：group, user, file, package, service, exec, cron, notify
        puppet describe [-l] [type]
    
    资源清单：manifests, *.pp
        type{'title':
            attribute => value,
            ...
        }
        
        引用：Type['title']
        
        元参数：
            before/require
            notify/subscribe
            ->, ~>
        
        数据类型：字符串、数值、布尔型、数组、hash、undef
        
        正则表达式：(?<enable_flag>-<disable_flag>:<PATTERN>)
            flag: i, m, x
            
    变量：$variable,
        FQN:    $::scope1::scope2::variable
                     $variable
        
    编程元素：
        流程控制：
            if, case, selector, unless
            
        类：
            class class_name[($parameter1[=value1], $parameter2)] {
                ...puppet code...
            }
            
            class sub_class_name inherits class_name {
                ... puppet code ...
            }
            
                sub_class_name：
                    base_class::sub_class_name
            
            子类中引用父类的资源：
                Type['title'] {
                    attribute => value,
                    atrribute +> value,
                }
                
            声明类：
                include class_name
                class{'class_name':
                    attribute => value,
                }
                
    模板：
        erb：Embedded RuBy
            <%= erb code %>
            <% erb code %>
            <%# erb code %>
            
        file类型的资源
            content => template('/PATH/TO/ERB_FILE')
            
    模块：
        modulepath配置参数指定的目录路径下(puppet config print modulepath)；
            manifests/
                init.pp (至少得存在一个与模块名同名的类)
                sub_class_name.pp
            files/
                puppet:///modules/MOD_NAME/FILE_NAME
            templates/
                template('MOD_NAME/ERB_FILE')
            lib/
            tests/
            spec/
            
        standalone: 
            puppet  apply -e 'include CLASS_NAME'



puppet(3)

    standalone：puppet apply
    master/agent：agent每隔30分钟到master端请求与自己相关的catalog
        master: site manifest
            node 'node_name' {
                ...puppet code...
            }
            
        node_name
        
        程序包下载路径：
            https://yum.puppetlabs.com/
            
        官方文档：
            https://docs.puppet.com/puppet/3/reference/
            
        内建函数：
            https://docs.puppet.com/puppet/3/reference/function.html
            
        配置参数列表：
            https://docs.puppet.com/puppet/3/reference/configuration.html
            
    部署master：
        安装程序包：facter, puppet, puppet-server 
        
        初始化master：
            puppet master --no-daemonize --verbose 
            
        生成一个完整的配置参数列表：
            puppet master --genconfig 
            puppet agent --genconfig 
            ...
            
        打印基于默认配置生效的各配置参数列表：
            puppet config <action> [--section SECTION_NAME]
            
            puppet  config  print 
            
        基于命令行设定某参数的值：
            puppet config set 
            
            
    master端管理证书签署：
        puppet cert <action> [--all] [<host>]   
            action：
                list
                sign
                revoke
                clean：吊销指定的客户端的证书，并删除与其相关的所有文件；
                
            
    站点清单的定义：
        主机名定义：
            主机名(主机角色)#-机架-机房-运营商-区域.域名
                www1-rack1-yz-unicom-bj.magedu.com 

            
        /etc/puppet/manifests/site.pp
            node 'base' {
                include ntp 
            }
        
            node 'HOSTNAME' {
                ...puppet code...
            }
            
            node /PATTERN/ {
                ...puppet code...
            }
            
                node /node[0-9]+\.magedu\.com/
            
            节点定义的继承：
                node NODE inherits PAR_NODE_DEF {
                    ...puppet code...
                }
                
                nodes/
            
            清单配置信息可模块化组织：
                databases.d/
                tomcatservers.d/
                nodes.d/：可通过多个pp文件分别定义各类站点的清单；而后统一导入site.pp，方法如下：
                
                site.pp文件使用中如下配置：   
                    import 'nodes/*.pp'
                
    多环境配置：
        默认环境是production；
        
        environmentpath =
        
        puppet 3.4 之前的版本配置多环境的方法： 
            
            各环境配置：
                /etc/puppet/environments/{production,development,testing}
                
            master支持多环境：puppet.conf
                [master]
                # modulepath=
                # manifest=
                environments = production, development, testing
                
                [production]
                modulepath=/etc/puppet/environments/production/modules/
                manifest=/etc/puppet/environments/production/manifests/site.pp
                
                [development]
                modulepath=/etc/puppet/environments/development/modules/
                manifest=/etc/puppet/environments/development/manifests/site.pp 
                
                [testing]
                modulepath=/etc/puppet/environments/testing/modules/
                manifest=/etc/puppet/environments/testing/manifests/site.pp 
                
        puppet 3.6之后的版本配置多环境的方法：
            master支持多环境：
                (1) 配置文件puppet.conf
                [master]
                environmentpath = $confdir/environments
                
                (2) 在多环境配置目录下为每个环境准备一个子目录
                ENVIRONMENT_NAME/
                    manifests/
                        site.pp
                    modules/
                                                
        agent端：
            [agent]
            environment = { production|development | testing }
            
    额外配置文件：
        文件系统：fileserver.conf
        认证（URL）：auth.conf
        
    puppet kick：
        agent：
            puppet.conf
            [agent]
            listen = true
            
            auth.conf
            path /run
            method save 
            auth any 
            allow master.magedu.com 
            
            path /
            auth any
            
        master端：
            puppet kick 
                puppet kick [--host <HOST>] [--all]
                
    GUI：
        dashboard
        foreman：
        
    项目实践：
        haproxy(keepalived)
            cache --> varnish
            imgs--> nginx server
            app --> httpd+tomcat
                --> mariadb-server
                
            zabbix -->
                zabbix-server 
                zabbix-agent
                
        
        
        
        生产环境案例：haproxy.pp

        class haproxy {
          # init haproxy
          class init {
            file { '/etc/init.d/haproxy': 
              ensure        => present,
              source        => "puppet:///modules/haproxy/haproxy/init.d/haproxy.init",
              group         => "root",
              owner         => "root",
              mode          => "0755",
            }
            exec { 'init_haproxy_service':
              subscribe     => File['/etc/init.d/haproxy'],
              refreshonly   => true, 
              command       => "/sbin/chkconfig --add haproxy; /sbin/chkconfig --level 235 haproxy off;",
            }
            service { 'haproxy':
              ensure      => running,
              enable      => true, 
              hasrestart  => true, 
              hasstatus   => true, 
        #       restart     => true,
            }
          }

          # init haproxy.cfg
          class conf {
        #     file { '/usr/local/haproxy','/usr/local/haproxy/etc': 
            file { ['/usr/local/haproxy','/usr/local/haproxy/etc']: 
              ensure        => directory,
              before        => File['/usr/local/haproxy/etc/haproxy.cfg'],
              group         => "root",
              owner         => "root",
              mode          => "0755",
            }

            class piccenter {
              file { '/usr/local/haproxy/etc/haproxy.cfg': 
                ensure        => present,
                source        => "puppet:///modules/haproxy/haproxy/conf/haproxy_piccenter.cfg",
                group         => "root",
                owner         => "root",
                mode          => "0644",
              }
            }
          }
        }






        keepalived.pp

        class keepalived {
          # init haproxy
          class init {
            file { '/etc/init.d/keepalived': 
              ensure        => present,
              source        => "puppet:///modules/haproxy/keepalived/init.d/keepalived.init",
              group         => "root",
              owner         => "root",
              mode          => "0755",
            }
            exec { 'init_keepalived_service':
              subscribe     => File['/etc/init.d/keepalived'],
              refreshonly   => true, 
              command       => "/sbin/chkconfig --add keepalived; /sbin/chkconfig --level 235 keepalived off;",
            }
            service { 'keepalived':
              ensure      => running,
              enable      => true, 
              hasrestart  => true, 
              hasstatus   => true, 
              restart     => true,
            }
          }
        }
