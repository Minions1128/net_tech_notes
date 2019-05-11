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

- Linux系统上的进程查看及管理工具：pstree, ps, pidof, pgrep, top, htop, glances, pmap, vmstat, dstat, kill, pkill, job, bg, fg, nohup, nice, renice, killall, ...
        
        CentOS 5:  SysV init
        CentOS 6：upstart
        CentOS 7：systemd
        
            /sbin/init, 
        
        pstree命令：
            pstree  - display a tree of processes
            
        ps命令：
            /proc/：内核中的状态信息；
                内核参数：
                    可设置其值从而调整内核运行特性的参数；/proc/sys/
                    状态变量：其用于输出内核中统计信息或状态信息，仅用于查看；
                    
                参数：模拟成文件系统类型；
                
            进程：
                /proc/#：
                    #：PID 
                
            ps - report a snapshot of the current processes.
            
                ps [options]：
                    选项有三种风格：
                        1   UNIX options, which may be grouped and must be preceded by a dash.
                        2   BSD options, which may be grouped and must not be used with a dash.
                        3   GNU long options, which are preceded by two dashes.
                    
                    启动进程的方式：
                        系统启动过程中自动启动：与终端无关的进程；
                        用户通过终端启动：与终端相关的进程；
                        
                    选项：
                        a：所有与终端相关的进程；
                        x：所有与终端无关的进程；
                        u：以用户为中心组织进程状态信息显示；
                        
                        常用组合之一：aux
                            VSZ：虚拟内存集；
                            RSS：Resident Size，常驻内存集；
                            STAT：
                                R：running
                                S：interruptable sleeping
                                D：uninterruptable sleeping
                                T：Stopped
                                Z：zombie
                                
                                +：前台进程
                                l：多线程进程
                                N：低优先级进程
                                <：高优先级进程
                                s：session leader 
                                
                        -e：显示所有进程
                        -f：显示完整格式的进程信息
                        
                        常用组合之二：-ef
                        
                        -F：显示完整格式的进程信息；
                            C： cpu utilization
                            PSR：运行于哪颗CPU之上
                        -H：以层级结构显示进程的相关信息；
                        
                        常用组合之三：-eFH
                        
                        常用组合之四：-eo, axo
                            o  field1, field2,...：自定义要显示的字段列表，以逗号分隔；
                                常用的field：pid, ni, pri, psr, pcpu, stat, comm, tty, ppid, rtprio
                                    ni：nice值；
                                    priority：priority, 优先级；
                                    rtprio：real time priority，实时优先级；
                                    
            pgrep, pkill命令：
                - look up or signal processes based on name and other attributes
                
                pgrep [options] pattern
                    -u uid：effective user
                    -U uid：read user
                    -t  TERMINAL：与指定的终端相关的进程；
                    -l：显示进程名；
                    -a：显示完整格式的进程名；
                    -P pid：显示此进程的子进程；
                    
            pidof命令：
                根据进程名，取其pid；
                
            top命令：
                - display Linux processes
                
                排序：
                    P：以占据CPU百分比排序；
                    M：以占据内存百分比排序；
                    T：累积占用CPU时间排序；
                    
                首部信息：
                    uptime信息：l命令
                    tasks及cpu信息：t命令
                    内存信息：m命令
                    
                退出命令：q
                修改刷新时间间隔：s
                终止指定的进程：k
                
                选项：
                    -d #：指定刷新时间间隔，默认为3秒；
                    -b：以批次方式显示；
                    -n #：显示多少批次；
                
            uptime命令：显示系统时间、运行时长及平均负载；
                过去1分钟、5分钟和15分钟的平均负载；
                    等待运行的进程队列的长度；
