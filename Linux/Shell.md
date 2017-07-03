# SHELL
* Shell，俗称壳（区别于核），用于用户与内核之间的翻译：用户输入的指令由shell接受，翻译为二进制数；内核处理完成的结果再由shell翻译，展示给用户。
* 其一种脚本化语言，bash为shell的一种，linux默认使用/bin/bash。
* SHELL命令分为2中：一种是系统内核的内部命令，另一种是外部文件命令。使用type命令查看：
```
type cd 
cd is a shell builtin   #（内部命令）
type mkdir
mkdir is /bin/mkdir     #（文件命令）
```
* 保存系统支持的SHELL：`/etc/shells`
* 保存用户的SHELL信息：`/etc/passwd`
* 查看当前系统默认使用的SHELL：`echo $SHELL`，切换shell后，使用exit 或ctrl+d关闭当前的shell
## 1. 系统默认执行配置文件
* 用户每次登录时执行：`~/.bash_profile【~/.profile】`
* 每次切换新的bash环境执行：`~/.bashrc`
* 用户每次退出登录时执行：`~/.bash_logout`
* 系统的初始配置文件：`/etc/profile`
## 2. SHELL的组成
* 脚本声明：#!/bin/bash
* 注释信息：以“#”开头
* 可执行语句：脚本主体
## 3. 执行脚本
执行脚本，不一定要有x权限
1. 执行脚本路径：`./1.sh`（要求要有x）
2. 用shell环境翻译脚本：`bash 1.sh`
3. 通过source或者.运行脚本：`{ source | . } 1.sh`
## 4. 交互式硬件设备
|  |  |  |
| ------------ | ------------ | ------------ |
| 标准输入 | /dev/stdin | 0 |
| 标准输出 | /dev/stdout | 1 |
| 标准错误输出 | /dev/stderr | 2 |
## 5. 引号
1. 单引号：无法识别变量；
2. 双引号：可以识别变量；
3. 反引号：$()等价于``，执行命令
## 6. 变量
```
expr $NUM1 + 100    # 自定义变量
readonly VAR        # 定义只读变量
unset VAR           # 删除变量

$HOME, $PATH        # 环境变量

$1, $2, $3          # 位置变量：脚本用来传递参数

# 预定义变量
$0                  # 脚本名称
$*                  # 代表所有未知参数
$#                  # 未知参数的个数
$?                  # 系统上一个变量
# 举个栗子：
tar zcvf $BAK $* &>/dev/null
echo "Finish the $0 shell script."
echo "Finish $# archive files."
echo "The files include: $*"

# 输入变量，如：从键盘录入作为变量赋值：
read [-p "Please input your name: "] NAME
echo "Welcome $NAME!"

# 变量的运算：
NUM1=1; NUM2=2; a=`expr $NUM1 + $NUM2`  # 变量与运算符之间，要有空格
echo $a
```
## 7. 条件测试
test+条件表达式，or，[ 条件表达式 ]；如果测试成功，返回0，否则为其他值。
### 7.1 文件测试
```
[ 参数 文件 ]
[ -e 1.sh ] && echo "yes" || echo "no"
```
参数：
* -e，文件或目录是否存在；
* -f，文件是否存在；
* -d，目录是否存在；
* -w是否可写；
* -r，是否可读；
* -x，是否可执行。
### 7.2 整数测试
```
[ 整数1 操作符 整数2 ]
[ $(who | wc -l) -eq 1 ] && echo "only one file" || echo "more than one files"
```
参数：
* -eq，等于；
* -ne，不等于；
* -gt，大于；
* -lt，小于；
* -le，小于等于；
* -ge，大于等于。
### 7.3 字符串测试
```
[ 字符串1 [!]= 字符串2 ]  # 字符串1[不]等于字符串2
[ -z 字符串 ]             # 判断字符串是否为空
```
7.4 逻辑测试
&&逻辑与，||逻辑或，！逻辑非
## 8 IF语句
### 8.1 单IF语句
```
if [ 判断语句 ]
then
    执行语句
fi
```
8.2 多分支结构
```
if [ 判断语句1 ]
then
    执行语句1
[elif [ 判断语句2 ]
then
    执行语句2]
else
    执行语句3
fi
# 举例：
read -p "Please input your score (0-100): " SCORE
if [ $SCORE -gt 80 ] && [ $SCORE -le 100 ]
then
  echo "Great."
elif [ $SCORE -ge 60 ] && [ $SCORE -le 80 ]
then
  echo "Good."
elif [ $SCORE -lt 0 ] || [ $SCORE -gt 100 ]
then
  echo "Please input the right score."
else 
  echo "Bad."
fi
```
## 9. 循环语句
### 9.1 for语句
```
for var in item1 item2 ... itemN
do
    command1
    command2
    ...
    commandN
done

# 或者
for (( i = 0; i < 10; i++ )); do
    echo "haha"
    sleep 1
done

# 例子：从/home/szj/ip_list.txt中读取IP地址，然后判断其是否在线
HOST_LIST=`/home/szj/ip_list.txt`
for IP in $HOST_LIST
do
    ping -c 3 -i 0.2 -W 3 $IP &>/dev/null
    if [ $? -eq 0 ]; then
        echo "Host $IP is up."
    else
        echo "Host $IP is down."
    fi
done
```
1.9.2.  while语句
```
while condition
do
    command
done

# 例子：
i=1
while [ $i -le 20 ]; do
    echo "$i, haha"
    sleep 1
    let i++
done
```
1.10    case语句
```
case 值 in
模式1)
    command11
    command12
    ...
    command1N
    ;;
模式2）
    command21
    command22
    ...
    command2N
    ;;
esac

# 例如，重启服务：
case "$1" in
  start )
    echo "Starting networking service"
    ;;
  stop ) 
    echo "Stopping networking service"
    ;;
  restart )
    echo "Stopping networking service"
    echo "Starting networking service"
    ;;
  * ) 
    echo "Usage: networking {start|stop|restart}"
esac
```
1.11    其他
笔记补充：[SHELL 教程](http://www.runoob.com/linux/linux-shell.html "SHELL 教程")
