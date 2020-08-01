# shell

## 编程初步

- 编程语言的分类:
    - 根据运行方式
        - 编译运行: 源代码 --> 编译器(编译) --> 程序文件: C语言
        - 解释运行: 源代码 --> 运行时启动解释器, 由解释器边解释边运行
    - 根据编程过程中, 功能实现是调用库还是调用外部的程序文件:
        - 非完整编程语言: shell脚本编程, 利用os上的命令以及编程组件进行编程
        - 完整编程语言: 其利用库或编程组建进行编程
    - 根据编程模型:
        - 面向过程编程语言: 以指令为中心来组织代码, 数据是服务于代码的
            - 三种执行逻辑: 顺序执行, 选择执行, 循环执行
        - 面向对象编程语言: 以数据为中心来组织代码, 指令是服务于数据的
            - 对象为某种数据类型或者数据模式, 实例化对象

- shell脚本编程: 过程式, 解释运行, 依赖于外部程序文件运行
    - 如何写: 第一行: 给出shebang, 解释其路径, 用于解释执行当前甲苯的解释器程序文件
        - 常见解释器:
            - `#!/bin/bash`
            - `#!/bin/python`
        - 命令的堆积, 需要用程序逻辑来判断, 运行条件, 环境是否满足, 以避免运行中发生错误.
    - 文本编辑器: nano
        - 行编辑器: sed
        - 全屏幕编程器: nano, vi, vim
    - 运行shell脚本:
        - 赋予脚本执行权限, 并直接执行脚本: `chmod u+x /path/shell_file; /pash/shell_file`
        - 解释型运行脚本: `bash /path/shell_file`
        - shell脚本的运行是通过子shell运行的

## 变量

- 变量名: 指向内存空间
- 变量类型: 存储格式, 表示数据的范围, 参与的运算
- shell为弱类型的变量: 把所有变量统统视作字符型, bash变量不需要实现声明
- 变量名的规则: 由字母, 下划线, 数字组成, 不能以数字开头, 不能使用程序的保留字

- bash的变量类型: 本地变量, 环境变量, 局部变量, 位置参数, 特殊变量:

- **本地变量**: 作用域为当前shell进程
    - 赋值:  `name=value`
    - 引用: `${var_name}`, `$var_name`
        - `""`: 变量名会替换为其值
        - `''`: 变量名不会替换为其值

- **环境变量**: 作用域为当前shell及其子shell
    - 赋值:
        - `export name=value`
        - `name=value; export name`
        - `declear -x name=value`
        - `name=value; declear -x name`
    - 引用: `${name}`, `$name`
    - bash内嵌了很多环境变量, (通常为全大写字母), 用于定义bash的工作环境: PATH, HISTFILE, HISTSIZE, HISTFILESIZE, HISTCONTROL, SHELL, HOME, UID, PWD, OLDPWD...
    - 查看环境变量: `export`, `declear -x`, `env`, `printenv`
    - 撤销环境变量: `unset name`, 不能使用$

- **只读变量**:
  - 声明:
        - `declear -r name`
        - `readonly name`
  - 无法重新赋值, 并且不支持撤销; 存活时间为当前shell进程的生命周期, 随shell终止而终止

- **局部变量**: 作用域为某代码片段(函数上下文)

- **位置参数**: 执行脚本的shell进程传递的参数
    - `myscript.sh argu1 argu2`
    - 引用方式: $1, $2, ...,$9 , ${10}, ${11}, ...
    - 轮替: `shift  [n]`, 位置参数轮替;
    - 例如: 通过命令传递两个文本文件路径给脚本, 计算其空白行数之和;
        ```
        #!/bin/bash
        #
        file1_lines=$(grep "^$" $1 | wc -l)
        file2_lines=$(grep "^$" $2 | wc -l)
        echo "Total blank lines: $[$file1_lines+$file2_lines]"
        ```
- **特殊变量**: shell内置的有特殊功用的变量
    - `$?`: 上以命令的执行结果: 0: 成功; 1-255: 失败
    - `$0`: 脚本文件路径本身;
    - `$#`: 脚本参数的个数;
    - `$*`, `$@`: 所有参数, 所有的位置参数;
        - 不被双引号(" ")包含时, 都以`$1`, `$2`, `$3` 的形式输出所有参数
        - 当它们被双引号(" ")包含时:
            - `$*` 会将所有的参数作为一个整体, 以`$1 $2 $3 …`的形式输出所有参数;
            - `$@` 会将各个参数分开, 以`$1`, `$2`, `$3` 的形式输出所有参数

## 数组

- 举例

```sh
ipInfo=(
    host1    10.0.0.1
    host2    10.0.0.2
)
len=${#ipInfo[@]}
while true; do
    for ((i=0; i<len; i+=2)); do
        hostName=${ipInfo[i]}
        ip=${ipInfo[i+1]}
        ping -c 1 -W 1 -s 5000 $ip
        nc -v -w 2 $ip -z 80
        nc -v -w 2 $ip -z 443
        date
        echo $hostName
        sleep 1
    done
done
```

- 排序

```sh
len=10
for((i=0;i<$len;i++)); do
    abc[i]=$RANDOM
done
echo ${abc[*]}
for((i=0;i<$len;i++)); do
    max=$i
    for((j=i;j<$len;j++)); do
        [[ abc[max] -lt abc[j] ]] && max=$j
    done
    if [[ $max -ne $i ]]; then
        temp=${abc[$max]}
        abc[$max]=${abc[$i]}
        abc[$i]=$temp
    fi
done
echo ${abc[*]}
```

- 字符串应用

```sh
#!/bin/bash
a="Hello World !"
echo ${a#*o}
#  World !

echo ${a##*o}
# rld !

echo ${a%o*}
# Hello W

echo ${a%%o*}
# Hell

echo ${a/l/L}
# HeLlo World !

echo ${a//l/L}
# HeLLo WorLd !

echo ${a/l}
# Helo World !

echo ${a//l}
# Heo Word !

echo ${a^^}
# HELLO WORLD !

echo ${a,,}
# hello world !
```

- 字符串处理

```sh
${var:-VALUE}       # 如果 var 为空, 则返回VALUE; 否则返回var的值;
${var:=VALUE}       # 如果 var 为空, 则返回VALUE, 并将var赋值VALUE; 否则返回var的值;
${var:+VALUE}       # 如果 var 不空, 则返回VALUE;
${var:?ERROR_INFO}  # 如果 var 为空, 或未设定, 则返回ERROR_INFO
```

## 基本运算符

### 算数运算

- 算数运算有: `+`, `-`, `*`, `/`, `**`(次方), `%`(取模)
    - 乘法符号`*`, 有些时候需要转义

- 几种赋值方式:

```sh
num1=5
num2=10
let sum=$num1+$num2
echo $sum
echo $[$num1*$num2]
echo $(($num2-$num1))
num3=$(expr $num2 / $num1)
echo $num3
```

- 计算/etc/passwd文件中的第10个用户和第20个用户的id号之和

```sh
id1=$(head -10 /etc/passwd | tail -1 | cut -d: -f3)
id2=$(head -20 /etc/passwd | tail -1 | cut -d: -f3)
```

- 计算/etc/rc.d/init.d/functions和/etc/inittab文件的空白行数之和

```sh
grep "^[[:space:]]*$" /etc/rc.d/init.d/functions | wc -l
```

### 逻辑运算

- 运算数:
    - 真: true, yes, on, 1
    - 假: false, no, off, 0
- 逻辑运算:
    - 与(&&), 或(||), 非(!)
    - 异或: 判断是否不同, 相同为, 不同为1
- 命令执行结果: 执行成功为0, 不成功为1
- 短路法则:
    - 与运算: `COMMAND1 && COMMAND2`, COMMAND1如果没有执行成功, 则COMMAND2不会执行;
    - 或运算: `COMMAND1 || COMMAND2`, COMMAND1如果执行没有成功, 则执行COMMAND2, 如: `id user1 || useradd user1`
    - **#** 为注释

## 条件测试

- 如何编写测试表达式以实现所需的测试:
    - (1) 执行命令, 并利用命令状态返回值来判断;
        - 0: 成功
        - 1-255: 失败
    - (2) 测试表达式
        - test  EXPRESSION
        - [ EXPRESSION ]
        - [[ EXPRESSION ]]
        - 注意: EXPRESSION两端必须有空白字符, 否则为语法错误;

### bash的测试类型

- 数值测试: 数值比较
    - -eq: 是否等于; [ $num1 -eq $num2 ]
    - -ne: 是否不等于;
    - -gt: 是否大于;
    - -ge: 是否大于等于;
    - -lt: 是否小于;
    - -le: 是否小于等于;

- 字符串测试
    - `==, =`: 是否等于;
    - !=: 是否不等于;
    - `=~`: 左侧字符串是否能够被右侧的PATTERN所匹配;
    - -z "STRING": 判断指定的字串是否为空; 空则为真, 不空则假;
    - -n "STRING": 判断指定的字符串是否不空; 不空则真, 空则为假;
    - `$var`: 判断指定字符串是否为空
    - 注意:
        - (1) 字符串要加引用;
        - (2) 要使用`[[ ]]`;

- 文件测试:
    - 存在性测试: 存在则为真, 否则则为假;
        - -a FILE
        - -e FILE
    - 存在性及类型测试:
        - -b  FILE: 是否存在并且为 块设备 文件;
        - -c  FILE: 是否存在并且为 字符设备 文件;
        - -d  FILE: 是否存在并且为 目录文件;
        - -f  FILE: 是否存在并且为 普通文件;
        - -h or -L FILE: 是否存在并且为 符号链接文件;
        - -p  FILE: 是否存在且为 命名管道文件;
        - -S  FILE: 是否存在且为 套接字文件;
    - 文件权限测试:
        - -r  FILE: 是否存在并且 对当前用户可读;
        - -w  FILE: 是否存在并且 对当前用户可写;
        - -x  FILE: 是否存在并且 对当前用户可执行;
    - 特殊权限测试:
        - -u  FILE: 是否存在并且 拥有suid权限;
        - -g  FILE: 是否存在并且 拥有sgid权限;
        - -k  FILE: 是否存在并且 拥有sticky权限;
    - 文件是否有内容:
        - -s  FILE: 是否有内容;
    - 时间戳:
        - -N FILE: 文件自从上一次读操作后是否被修改过;
    - 从属关系测试:
        - -O  FILE: 当前用户是否为文件的属主;
        - -G  FILE: 当前用户是否属于文件的属组;
    - 双目测试:
        - FILE1  -ef  FILE2: FILE1与FILE2是否指向同一个文件系统的相同inode的硬链接;
        - FILE1  -nt  FILE2: FILE1是否新于FILE2;
        - FILE1  -ot  FILE2: FILE1是否旧于FILE2;

- 组合测试条件: 逻辑运算:
    - 第一种方式:
        - `COMMAND1 && COMMAND2`
        - `COMMAND1 || COMMAND2`
        - `! COMMAND`
        - `[ -O FILE ] && [ -r FILE ]`
    - 第二种方式:
        - `EXPRESSION1  -a  EXPRESSION2`
        - `EXPRESSION1  -o  EXPRESSION2`
        - `! EXPRESSION`
        - `[ -O FILE -a -x FILE ]`

## 流程控制

### if, for, while, until, case

- if-then-fi, if-then-else-if, if-then-elif-...-else-fi

- for-do-done

- while-do-done

- until-do-done

- break; continue

- case-esac

https://www.runoob.com/linux/linux-shell-process-control.html

### 用户交互

- 通过键盘输入数据, 从而完成变量赋值操作, 用法

```sh
read [option]... [name ...]
    -p 'PROMPT'
    -t TIMEOUT
```

- 练习: 根据菜单提示用户给出自己的选择, 而后显示对应其选择的相应系统信息, 菜单如下
```
disk) show disks info;
mem) show memory info;
cpu) show cpu info;
*) quit;
```

```sh
#!/bin/bash
#
cat << EOF
disk) show disks info
mem) show memory info
cpu) show cpu info
*) QUIT
EOF
read -p "Your choice: " option
if [[ "$option" == "disk" ]]; then
    fdisk -l /dev/[sh]d[a-z]
elif [[ "$option" == "mem" ]]; then
    free -m
elif [[ "$option" == "cpu" ]];then
    lscpu
else
    echo "Unkown option."
    exit 3
fi
```

## printf

https://www.runoob.com/linux/linux-shell-printf.html

## 函数

- 返回斐波那契数列

```sh
FibonacciSequence() {
    if [[ $1 -lt 0 ]]; then
        echo "error $1"
        exit 1
    elif [[ $1 -le 1 ]]; then
        echo -n "$1 "
    else
        a=$(FibonacciSequence $(($1-1)))
        b=$(FibonacciSequence $(($1-2)))
        echo -n "$(($a+$b)) "
    fi
}
for i in $(seq 0 $1); do
    FibonacciSequence $i
done
echo
```
