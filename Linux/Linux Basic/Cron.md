# Linux任务计划、周期性任务执行

- 未来的某时间点执行一次某任务：at, batch
- 周期性运行某任务：crontab
    - 执行结果：会通过本地邮件发送给用户

## 未来的某时间点执行一次某任务

- at命令
    - `at [OPTION]... TIME`
    - at的作业有队列，用单个字母表示，默认都使用a队列；
    - TIME：
        - HH:MM [YYYY-mm-dd]
        - noon，midnight, teatime
        - tomorrow
        - now+#
            - UNIT：minutes, hours, days, OR weeks
    - 常用选项：
        - -l：查看作业队列，相当于atq
        - -f /PATH/FROM/SOMEFILE：从指定文件中读取作业任务，而不用再交互式输入；
        - -d：删除指定的作业，相当于atrm；
        - -c：查看指定作业的具体内容；
        - -q QUEUE：指明队列；
    - 注意：作业执行结果是以邮件发送给提交作业的用户；

- batch命令：
    - batch会让系统自行选择在系统资源较空闲的时间去执行指定的任务；

## 周期性任务计划cron


- 实现服务程序：
    - cronie：主程序包，提供了crond守护进程及相关辅助工具；
    - 确保crond守护进程(daemon)处于运行状态：`systemctl  status  crond.service`

- 向crond提交作业的方式不同于at，它需要使用专用的配置文件，此文件有固定格式，不建议使用文本编辑器直接编辑此文件；要使用crontab命令；

- cron任务分为两类：
    - 系统cron任务：主要用于实现系统自身的维护；
        - 手动编辑：/etc/crontab文件
    - 用户cron任务：
        - 命令：crontab命令

- 系统cron的配置格式：/etc/crontab
    ```sh
    SHELL=/bin/bash
    PATH=/sbin:/bin:/usr/sbin:/usr/bin
    MAILTO=root

    # For details see man 4 crontabs

    # Example of job definition:
    # .---------------- minute (0 - 59)
    # |  .------------- hour (0 - 23)
    # |  |  .---------- day of month (1 - 31)
    # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
    # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
    # |  |  |  |  |
    # *  *  *  *  * user-name  command to be executed
    ```
    - 注意：
        - (1) 每一行定义一个周期性任务，共7个字段；
            - *  *  *  *  * : 定义周期性时间
            - user-name : 运行任务的用户身份
            - command to be executed：任务
        - (2) 此处的环境变量不同于用户登录后获得的环境，因此，建议命令使用绝对路径，或者自定义PATH环境变量；
        - (3) 执行结果邮件发送给MAILTO指定的用户

- 用户cron的配置格式：/var/spool/cron/USERNAME
    ```sh
    SHELL=/bin/bash
    PATH=/sbin:/bin:/usr/sbin:/usr/bin
    MAILTO=root

    # For details see man 4 crontabs

    # Example of job definition:
    # .---------------- minute (0 - 59)
    # |  .------------- hour (0 - 23)
    # |  |  .---------- day of month (1 - 31)
    # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
    # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
    # |  |  |  |  |
    # *  *  *  *  *   command to be executed    
    ```
    - 注意：
        - (1) 每行定义一个cron任务，共6个字段；
        - (2) 此处的环境变量不同于用户登录后获得的环境，因此，建议命令使用绝对路径，或者自定义PATH环境变量；
        - (3) 邮件发送给当前用户；
            
- 时间表示法：
    - (1) 特定值：给定时间点有效取值范围内的值；（注意：day of week和day of month一般不同时使用；）
    - (2) `*`：给定时间点上有效取值范围内的所有值；表“每..”
    - (3) 离散取值：`,`, 在时间点上使用逗号分隔的多个值: #,#,#
    - (4) 连续取值：`-`, 在时间点上使用-连接开头和结束: #-#
    - (5) 在指定时间点上，定义步长: /#：#即步长；
    - 注意：
        - (1) 指定的时间点不能被步长整除时，其意义将不复存在；
        - (2) 最小时间单位为“分钟”，想完成“秒”级任务，得需要额外借助于其它机制；定义成每分钟任务：而在利用脚本实现在每分钟之内，循环执行多次；

- 示例：
```sh
    (1) 3 * * * *：每小时执行一次；每小时的第3分钟；
    (2) 3 4 * * 5：每周执行一次；每周5的4点3分；
    (3) 5 6 7 * *：每月执行一次；每月的7号的6点5分；
    (4) 7 8 9 10 *：每年执行一次；每年的10月9号8点7分；
    (5) 9 8 * * 3,7：每周三和周日；
    (6) 0 8,20 * * 3,7：
    (7) 0 9-18 * * 1-5：
    (8) */5 * * * *：每5分钟执行一次某任务；
    (9) */7
```

- crontab命令
    - `crontab [-u user] [-l | -r | -e] [-i] `
    - -e：编辑任务；
    - -l：列出所有任务；
    - -r：移除所有任务；即删除/var/spool/cron/USERNAME文件；
    - -i：在使用-r选项移除所有任务时提示用户确认；
    - -u user：root用户可为指定用户管理cron任务；                   
    - 注意：运行结果以邮件通知给当前用户；如果拒绝接收邮件：
        - (1) COMMAND > /dev/null
        - (2) COMMAND &> /dev/null
        - (3) 定义COMMAND时，如果命令需要用到%，需要对其转义；但放置于单引号中的%不用转义亦可；

- 思考：某任务在指定的时间因关机未能执行，下次开机会不会自动执行？
    - 不会！.
    - 如果期望某时间因故未能按时执行，下次开机后无论是否到了相应时间点都要执行一次，可使用anacron实现；

- 课外作业：anacron及其应用


## 本地电子邮件服务

- netstat -tnlp | grep 25
- ss -tnl | grep 25

- smtp：simple mail transmission protocol
- pop3：Post Office Procotol
- imap4：Internet Mail Access Procotol
        
- mail命令
    - mailx - send and receive Internet mail
    - MUA：Mail User Agent, 用户收发邮件的工具程序；
    - mailx  [-s 'SUBJECT']  username[@hostname]
        - 邮件正文的生成：
            - (1) 交互式输入；. 单独成行可以表示正文结束；Ctrl+d提交亦可；
            - (2) 通过输入重定向；
            - (3) 通过管道；

```
练习：
1、每12小时备份一次/etc目录至/backups目录中，保存文件 名称格式为“etc-yyyy-mm-dd-hh.tar.xz”
2、每周2、4、7备份/var/log/secure文件至/logs目录中，文件名格式为“secure-yyyymmdd”；
3、每两小时取出当前系统/proc/meminfo文件中以S或M开头的行信息追加至/tmp/meminfo.txt文件中；
```
