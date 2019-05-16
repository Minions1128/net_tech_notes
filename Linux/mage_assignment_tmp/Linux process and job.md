# Linux进程及作业管理

- 内核的功用：进程管理、文件系统、网络功能、内存管理、驱动程序、安全功能

- Process: 运行中的程序的一个副本，存在生命周期

- Linux内核存储进程信息的固定格式：task struct, 多个任务的task struct组件的链表：task list

- 进程创建：
    - init
        - 父子关系
        - 进程：都由其父进程创建: fork(), clone()
    - 进程优先级： 0-139：数字越小，优先级越高；
        - 1-99：实时优先级；
        - 100-139：静态优先级；
        - Nice值：-20(100), 19(139)
    - 进程内存：
        - Page Frame: 页框，用存储页面数据
            - 存储Page
            - MMU: Memory Management Unit
    - IPC: Inter Process Communication
        - 同一主机上：
            - signal
            - shm: shared memory
            - semaphore
        - 不同主机上：
            - rpc: remote procecure call
            - socket:

- Linux内核：
    - 抢占式多任务
    - 进程类型：
        - 守护进程: 在系统引导过程中启动的进程，跟终端无关的进程；
        - 前台进程：跟终端相关，通过终端启动的进程
            - 注意：也可把在前台启动的进程送往后台，以守护模式运行；
    - 进程状态：
        - 运行态：running
        - 就绪态：ready
        - 睡眠态：
            - 可中断：interruptable
            - 不可中断：uninterruptable
        - 停止态：暂停于内存中，但不会被调度，除非手动启动之；stopped
        - 僵死态：zombie
    - 进程的分类：
        - CPU-Bound
        - IO-Bound

## Linux系统上的进程查看及管理工具

- init: /sbin/init
    - CentOS 5:  SysV init
    - CentOS 6：upstart
    - CentOS 7：systemd

- pstree: display a tree of processes

- ps: report a snapshot of the current processes.
    - /proc/：内核中的状态信息；
        - 内核参数：模拟成文件系统类型；
            - 可设置其值从而调整内核运行特性的参数；/proc/sys/
            - 状态变量：其用于输出内核中统计信息或状态信息，仅用于查看；
    - 进程：
        - /proc/#：`#`为PID 
    - ps [options]：
        - 选项有三种风格：
            - 1 UNIX options, which may be grouped and must be preceded by a dash.
            - 2 BSD options, which may be grouped and must not be used with a dash.
            - 3 GNU long options, which are preceded by two dashes.
        - 启动进程的方式：
            - 系统启动过程中自动启动：与终端无关的进程；
            - 用户通过终端启动：与终端相关的进程；
        - 选项：
            - a：所有与终端相关的进程；
            - x：所有与终端无关的进程；
            - u：以用户为中心组织进程状态信息显示；
            - -e：显示所有进程
            - -f：显示完整格式的进程信息
            - -F：显示完整格式的进程信息；
            - -H：以层级结构显示进程的相关信息；
            - o field1, field2,...：自定义要显示的字段列表，以没有空格的逗号分隔；
                - 常用的field：pid, ni, pri, psr, pcpu, stat, comm, tty, ppid, rtprio
                    - ni：nice值；
                    - pri：priority, 优先级；
                    - rtprio：real time priority，实时优先级；
    - ps选项常用组合：
        - aux；显示主要字段解释：
            - VSZ：虚拟内存集，占用虚拟内存大小；
            - RSS：Resident Size，常驻内存集，不能放在交换内存中的内存空间；
            - STAT：当前进程的运行状态
                - R: running
                - S: interruptable sleeping
                - D: uninterruptable sleeping
                - T: Stopped
                - Z: zombie
                - +: 前台进程
                - l: 多线程进程
                - N: 低优先级进程
                - <: 高优先级进程
                - s: session leader
        - -ef
            - PPID，父进程
        - -eFH
            - SZ：size in physical pages of the core image of the process.
            - C： cpu utilization
            - PSR：运行于哪颗CPU之上
        - -eo, axo

- pgrep, pkill命令：look up or signal processes based on name and other attributes
    - pgrep [options] pattern
        - -u uid：effective user
        - -U uid：read user
        - -t  TERMINAL：与指定的终端相关的进程；
        - -l：显示进程名；
        - -a：显示完整格式的进程名；
        - -P pid：显示此进程的子进程；

- pidof: 根据进程名，取其pid；

- top: display Linux processes
    - [top命令](https://www.cnblogs.com/peida/archive/2012/12/24/2831353.html)
    - 键入字母排序方式：
        - P：以占据CPU百分比排序；
        - M：以占据内存百分比排序；
        - T：累积占用CPU时间排序；
    - 首部信息：
        - uptime信息：键入l开启或关闭
        - tasks及cpu信息：键入t开启或关闭
        - 内存信息：键入m开启或关闭
    - 退出命令：q
    - 修改刷新时间间隔：s
    - 终止指定的进程：k
    - 选项：
        - -d #：指定刷新时间间隔，默认为3秒；
        - -b：以批次方式显示；
        - -n #：显示多少批次

- uptime命令：显示系统时间、运行时长及平均负载；
    - 过去1分钟、5分钟和15分钟的平均负载；
    - 等待运行的进程队列的长度；

- htop：支持鼠标操作
    - 选项：
        - -d #：指定延迟时间间隔；
        - -u UserName：仅显示指定用户的进程；
        - -s COLUME：以指定字段进行排序；
    - 子命令：
        - l：显示选定的进程打开的文件列表；
        - s：跟踪选定的进程的系统调用；
        - t：以层级关系显示各进程状态；
        - a：将选定的进程绑定至某指定的CPU核心；

- vmstat: Report virtual memory statistics
    - `vmstat [options] [delay [count]]`
        - procs：
            - r：等待运行的进程的个数；CPU上等待运行的任务的队列长度；
            - b：处于不可中断睡眠态的进程个数；被阻塞的任务队列的长度；
        - memory：
            - swpd：交换内存使用总量；
            - free：空闲的物理内存总量；
            - buffer：用于buffer的内存总量；
            - cache：用于cache的内存总量；
        - swap
            - si：数据进入swap中的数据速率（kb/s）
            - so：数据离开swap的速率(kb/s)
        - io
            - bi：从块设备读入数据到系统的速度（kb/s）
            - bo：保存数据至块设备的速率（kb/s）
        - system
            - in：interrupts，中断速率；
            - cs：context switch, 上下文 切换的速率；
        - cpu 
            - us： user space
            - sy：system
            - id：idle
            - wa：wait
            - st: stolen
    - 选项：
        - -s：显示内存统计数据；

- pmap: report memory map of a process
    - pmap [options] pid [...]
        - -x：显示详细格式的信息；
    - 另一种查看方式：cat  /proc/PID/maps

- glances: A cross-platform curses-based monitoring tool
            
            内建命令：
                
            常用选项：
                -b：以Byte为单位显示网上数据速率；
                -d：关闭磁盘I/O模块；
                -m：关闭mount模块；
                -n：关闭network模块；
                -t #：刷新时间间隔；
                -1：每个cpu的相关数据单独显示；
                -o {HTML|CSV}：输出格式；
                -f  /PATH/TO/SOMEDIR：设定输出文件的位置；
            
            C/S模式下运行glances命令：
                服务模式：
                    glances  -s  -B  IPADDR
                    
                    IPADDR：本机的某地址，用于监听；
                    
                客户端模式：
                    glances  -c  IPADDR
                    
                    IPADDR：是远程服务器的地址；

- dstat

        dstat命令：
            - versatile tool for generating system resource statistics
            
            dstat [-afv] [options..] [delay [count]]
            
            常用选项：
                -c， --cpu：显示cpu相关信息；
                    -C #,#,...,total
                -d, --disk：显示磁盘的相关信息
                    -D sda,sdb,...,tobal
                -g：显示page相关的速率数据；
                -m：Memory的相关统计数据
                -n：Interface的相关统计数据；
                -p：显示process的相关统计数据；
                -r：显示io请求的相关的统计数据；
                -s：显示swapped的相关统计数据；
                
                --tcp 
                --udp
                --raw 
                --socket 
                
                --ipc 
                
                --top-cpu：显示最占用CPU的进程；
                --top-io：最占用io的进程；
                --top-mem：最占用内存的进程；
                --top-lantency：延迟最大的进程；

- kill
        - killall
        kill命令：
            
            - terminate a process
            
            用于向进程发送信号，以实现对进程的管理；
            
            显示当前系统可用信号：
                kill -l [signal]
                
                每个信号的标识方法有三种：
                    1) 信号的数字标识；
                    2) 信号的完整名称；
                    3) 信号的简写名称；
                    
            向进程发信号：
                kill  [-s signal|-SIGNAL]  pid...
                
                常用信号：
                    1） SIGHUP：无须关闭进程而让其重读配置文件；
                    2）SIGINT：终止正在运行的进程，相当于Ctrl+c
                    9）SIGKILL：杀死运行中的进程；
                    15）SIGTERM：终止运行中的进程；
                    18）SIGCONT：
                    19）SIGSTOP：
                    
        killall命令：
            
            - kill processes by name
            
            killall  [-SIGNAL]  program

- job

- bg

- fg

- nohup

- nice

- renice




Linux进程及作业管理(2)

    CentOS 6: http://172.16.0.1/fedora-epel/
    CentOS 7: http://172.16.0.1/fedora-epel/
           
    Linux系统作业控制：
        
        job：
            前台作业(foregroud)：通过终端启动，且启动后会一直占据终端；
            后台作业(backgroud)：可以通过终端启动，但启动后即转入后台运行（释放终端）；
            
        如何让作业运行于后台？
            (1) 运行中的作业
                Ctrl+z
                注意：送往后台后，作业会转为停止态；
            (2) 尚未启动的作业
                # COMMAND &
                
                注意：此类作业虽然被送往后台，但其依然与终端相关；如果希望把送往后台的作业剥离与终端的关系：
                    # nohup  COMMAND  &
                    
        查看所有的作业：
            # jobs
            
        可实现作业控制的常用命令：
            # fg  [[%]JOB_NUM]：把指定的作业调回前台；
            # bg  [[%]JOB_NUM]：让送往后台的作业在后台继续运行；
            # kill  %JOB_NUM：终止指定的作业；
            
    调整进程优先级：
        
        可通过nice值调整的优先级范围：100-139
            分别对应于：-20, 19
            
        进程启动时，其nice值默认为0，其优先级是120；
        
        nice命令：
            以指定的nice值启动并运行命令
                # nice  [OPTION]  [COMMAND [ARGU]...]
                    选项：
                        -n NICE
                        
                注意：仅管理员可调低nice值； 
                
        renice命令：
            # renice  [-n]  NICE  PID...
            
        查看Nice值和优先级：
            ps  axo  pid, ni, priority, comm  
            
    未涉及到的命令：sar,  tsar,  iostat,  iftop,  nethog,  ...
    
    博客作业： htop/dstat/top/ps命令的使用；
