# IPerf
Iperf是一款网络性能测试工具，可以测试TCP、UDP等类型的网络。其分为server端和client端。
## 1. 参数说明
* iperf –s //以server端启动iperf；
* iperf –c 1.1.1.1 //以client端启动，指向server端1.1.1.1；
## 2. C/S端通用参数
* -f，--format [kmKM] 规定显示的带宽单位，分别表示Kbits，Mbits，Kbytes，Mbytes，默认为m
* -i，--interval 带宽输出时间间隔
* -l，--length [KM] 缓冲区的大小，默认为8KB
* -m，--print_mss 输出TCP MSS
* -o，--output <filename> 将报告和错误信息输出到文件中，仅支持windows系统
* -p，--port，server所监听的特定端口，需要C/S两端同时设置
* -u，--udp 使用UDP
* -w，--window，TCP窗口大小，socket的缓冲大小
* -B，--bind <host> 绑定host，接口或者组播地址
* -C，--compatibility 可以兼容就得版本
* -M，--mss 设置TCP MMS大小，默认为MTU-40字节
* -N，--nodelay 设置TCP不延时，禁用Nagle's Algorithm
* -V，--IPv6Version 设置使用IPv6协议
## 3. 服务器专用参数
* -D，--daemon 运行时，作为守护进程运行
* -U，--single_udp 运行时，使用单个UDP线程模式
## 4. 客户端专用参数
* -d，--dualtest 同时进行双向测试
* -n，--num [KM] 设置传输字节数，代替-t参数
* -r，--tradeoff 做双向测试，做完一侧之后，再做另一侧
* -t，--time 设置测试时间，默认为10s钟
* -F，--fileinput <name> 从文件中，获取传输数据
* -T，--ttl 设置TTL值
* -Z, --linux-congestion <algo> 设置TCP拥塞控制算法
* -I，--stdin 输入的数据来自一个stdin
* -L，--listenport 设置双向检测时的返回端口
* -P，--parallel 允许client运行线程的个数
* -b，--bandwidth [KM] 仅UDP使用，设置发送带宽，单位是bps
