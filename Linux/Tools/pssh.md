# pssh

pssh是一个python编写可以在多台服务器上执行命令的工具，也可实现文件复制。pssh需要通过ssh的key验证来管理主机，其不能很好的支持密码验证。用过epel源的pssh包来安装

## pssh options

- `pssh [OPTIONS] command […]`
    - –version：查看版本
    - -h：主机文件列表，内容格式”[user@]host[:port]”
    - -H：主机字符串，内容格式”[user@]host[:port]”
    - -l：登录使用的用户名
    - -p：并发的线程数【可选】
    - -o：输出的文件目录【可选】
    - -e：错误输入文件【可选】
    - -t：TIMEOUT 超时时间设置，0无限制【可选】
    - -O：SSH的选项
    - -v：详细模式
    - -A：手动输入密码模式
    - -x：额外的命令行参数使用空白符号，引号，反斜线处理
    - -X：额外的命令行参数，单个参数模式，同-x
    - -i：每个服务器内部处理信息输出
    - -P：打印出服务器返回信息
    - 常用选项：-H  、-h 、-i、

## pscp.pssh

- 将本地文件批量复制到远程主机

- pscp-pssh选项
    - -v 显示复制过程
    - -a 复制过程中保留常规属性
    - -r 递归复制目录

```
hostname ~ # pscp -h ip.txt /root/ip.txt ~/
[1] 03:07:43 [SUCCESS] 10.0.0.24
[2] 03:07:43 [SUCCESS] 10.0.0.23
# 将本地ip.txt 拷贝到远程目标主机上
```

## pslurp.pssh

- 将远程主机的文件批量复制到本地

- pslurp-pssh选项
    - -L 指定从远程主机下载到本机的存储的目录，local是下载到本地后的名称
    - -r 递归复制目录

```
hostname ~ # pslurp -h ip.txt -L /data1/ /etc/passwd passwd
[1] 03:15:43 [SUCCESS] 10.0.0.24
[2] 03:15:43 [SUCCESS] 10.0.0.23

hostname ~ # cd /data1/
hostname /data1 # ls -l
total 0
drwxr-xr-x 2 root root 42 Jan  9 03:15 10.0.0.23
drwxr-xr-x 2 root root 42 Jan  9 03:15 10.0.0.24
hostname /data1 # cd 10.0.0.24
hostname /data1/10.0.0.24 # ls
passwd

# -L指定保存到本地的哪个目录
# 倒数第二个参数表示要在在远程主机下载的文件
# paswd表示要更换的名字（必须有这一项，否则会报错）
```
