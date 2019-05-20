# shell编程初步

- 编程语言的分类：
    - 根据运行方式
        - 编译运行：源代码 --> 编译器（编译） --> 程序文件：C语言
        - 解释运行：源代码 --> 运行时启动解释器，由解释器边解释边运行
    - 根据编程过程中，功能实现是调用库还是调用外部的程序文件：
        - 非完整编程语言：shell脚本编程，利用os上的命令以及编程组件进行编程
        - 完整编程语言：其利用库或编程组建进行编程
    - 根据编程模型：
        - 面向过程编程语言：以指令为中心来组织代码，数据是服务于代码的
            - 三种执行逻辑：顺序执行、选择执行、循环执行
        - 面向对象编程语言：以数据为中心来组织代码，指令是服务于数据的
            - 对象为某种数据类型或者数据模式，实例化对象

- shell脚本编程：过程式，解释运行，依赖于外部程序文件运行
    - 如何写：第一行：给出shebang，解释其路径，用于解释执行当前甲苯的解释器程序文件
        - 常见解释器：
            - `#!/bin/bash`
            - `#!/bin/python`
        - 命令的堆积，需要用程序逻辑来判断，运行条件、环境是否满足，以避免运行中发生错误。
    - 文本编辑器：nano
        - 行编辑器：sed
        - 全屏幕编程器：nano，vi，vim
    - 运行shell脚本：
        - 赋予脚本执行权限，并直接执行脚本：`chmod u+x /path/shell_file; /pash/shell_file`
        - 解释型运行脚本：`bash /path/shell_file`
        - shell脚本的运行是通过子shell运行的

# 变量

- 变量名：指向内存空间
- 变量类型：存储格式，表示数据的范围，参与的运算
- shell为弱类型的变量：把所有变量统统视作字符型，bash变量不需要实现声明
- 变量名的规则：由字母，下划线，数字组成，不能以数字开头，不能使用程序的保留字
- bash的变量类型：本地变量、环境变量、局部变量、位置参数、特殊变量：
    - **本地变量**：作用域为当前shell进程
        - 赋值： `name=value`
        - 引用：`${var_name}`，`$var_name`
            - `""`：变量名会替换为其值
            - `''`：变量名不会替换为其值
        - 查看变量：`set`命令
        - 撤销变量：`unset name`，不能使用$
    - **环境变量**：作用域为当前shell及其子shell
        - 赋值：
            - `export name=value`
            - `name=value; export name`
            - `declear -x name=value`
            - `name=value; declear -x name`
        - 引用：`${name}`，`$name`
        - bash内嵌了很多环境变量，（通常为全大写字母），用于定义bash的工作环境：PATH, HISTFILE, HISTSIZE, HISTFILESIZE, HISTCONTROL, SHELL, HOME, UID, PWD, OLDPWD...
        - 查看环境变量：`export`，`declear -x`，`env`，`printenv`
        - 撤销环境变量：`unset name`，不能使用$
    - **只读变量**：
      - 声明：
            - `declear -r name`
            - `readonly name`
      - 无法重新赋值，并且不支持撤销；存活时间为当前shell进程的生命周期，随shell终止而终止
    - **局部变量**：作用域为某代码片段（函数上下文）
    - **位置参数**：执行脚本的shell进程传递的参数
        - `myscript.sh  argu1 argu2`
        - 引用方式：$1, $2, ...,$9 , ${10}, ${11}, ...
        - 轮替：`shift  [n]`, 位置参数轮替；
        - 例如：通过命令传递两个文本文件路径给脚本，计算其空白行数之和；
            ```
            #!/bin/bash
            #
            file1_lines=$(grep "^$" $1 | wc -l)
            file2_lines=$(grep "^$" $2 | wc -l)
            echo "Total blank lines: $[$file1_lines+$file2_lines]"  
            ```
    - **特殊变量**：shell内置的有特殊功用的变量
        - $?：上以命令的执行结果：0：成功；1-255：失败
        - $0：脚本文件路径本身；
        - $#：脚本参数的个数；
        - `$*`：所有参数，所有的位置参数,被作为一个单词.
        - $@：与`$*`同义，但是每个参数都是一个独立的""引用字串，这就意味着参数被完整地传递，并没有被解释和扩展。这也意味着,每个参数列表中的每个参数都被当成一个独立的单词。
        - 注意:"$@"必须被引用.注意:`"$*"`必须被""引用.

# 逻辑运算

- 运算数：
    - 真：true, yes, on, 1
    - 假：false, no, off, 0
- 逻辑运算：
    - 与（&&），或（||），非（!）
    - 异或：判断是否不同，相同为，不同为1
- 命令执行结果：执行成功为0，不成功为1
- 短路法则：
    - 与运算：`COMMAND1 && COMMAND2`，COMMAND1如果没有执行成功，则COMMAND2不会执行；
    - 或运算：`COMMAND1 || COMMAND2`，COMMAND1如果执行没有成功，则执行COMMAND2，如：`id user1 || useradd user1`
    - **#** 为注释

# bash脚本编程的算数运算

- 算数运算有：`+`、`-`、`*`、/、`**`（次方）、`%`（取模）
    - 乘法符号`*`，有些时候需要转义
- let VAR=算数运算表达式：`let sum=$num1+$num2`
- VAR=$[算数运算表达式]：`$[$num3+$num4]`
- VAR=$((算数运算表达式))：`$(($num3+$num4))`
- `sum=$(expr $num2 + $num4)`

- 计算/etc/passwd文件中的第10个用户和第20个用户的id号之和

```sh
id1=$(head -10 /etc/passwd | tail -1 | cut -d: -f3)
id2=$(head -20 /etc/passwd | tail -1 | cut -d: -f3)
```

- 计算/etc/rc.d/init.d/functions和/etc/inittab文件的空白行数之和

```sh
grep "^[[:space:]]*$" /etc/rc.d/init.d/functions | wc -l
```

## 条件测试

- 如何编写测试表达式以实现所需的测试：
    - (1) 执行命令，并利用命令状态返回值来判断；
        - 0：成功
        - 1-255：失败
    - (2) 测试表达式
        - test  EXPRESSION
        - [ EXPRESSION ]
        - [[ EXPRESSION ]]
        - 注意：EXPRESSION两端必须有空白字符，否则为语法错误；

- bash的测试类型：
    - 数值测试：数值比较
        - -eq：是否等于； [ $num1 -eq $num2 ]
        - -ne：是否不等于；
        - -gt：是否大于；
        - -ge：是否大于等于；
        - -lt：是否小于；
        - -le：是否小于等于；
    - 字符串测试
        - ==：是否等于；
        - >：是否大于；
        - <：是否小于；
        - !=：是否不等于；
        - =~：左侧字符串是否能够被右侧的PATTERN所匹配；
        - -z "STRING"：判断指定的字串是否为空；空则为真，不空则假；
        - -n "STRING"：判断指定的字符串是否不空；不空则真，空则为假；
        - 注意：
            - (1) 字符串要加引用；
            - (2) 要使用[[ ]]；
    - 文件测试：
        - 存在性测试: 存在则为真，否则则为假；
            - -a  FILE
            - -e  FILE
        - 存在性及类型测试：
            - -b  FILE：是否存在并且为 块设备 文件；
            - -c  FILE：是否存在并且为 字符设备 文件；
            - -d  FILE：是否存在并且为 目录文件；
            - -f  FILE：是否存在并且为 普通文件；
            - -h or -L FILE：是否存在并且为 符号链接文件；
            - -p  FILE：是否存在且为 命名管道文件；
            - -S  FILE：是否存在且为 套接字文件；
        - 文件权限测试：
            - -r  FILE：是否存在并且 对当前用户可读；
            - -w  FILE：是否存在并且 对当前用户可写；
            - -x  FILE：是否存在并且 对当前用户可执行；
        - 特殊权限测试：
            - -u  FILE：是否存在并且 拥有suid权限；
            - -g  FILE：是否存在并且 拥有sgid权限；
            - -k  FILE：是否存在并且 拥有sticky权限；
        - 文件是否有内容：
            - -s  FILE：是否有内容；
        - 时间戳：
            - -N FILE：文件自从上一次读操作后是否被修改过；
        - 从属关系测试：
            - -O  FILE：当前用户是否为文件的属主；
            - -G  FILE：当前用户是否属于文件的属组；
        - 双目测试：
            - FILE1  -ef  FILE2：FILE1与FILE2是否指向同一个文件系统的相同inode的硬链接；
            - FILE1  -nt  FILE2：FILE1是否新于FILE2；
            - FILE1  -ot  FILE2：FILE1是否旧于FILE2；
- 组合测试条件：逻辑运算：
    - 第一种方式：
    ```
    COMMAND1 && COMMAND2
    COMMAND1 || COMMAND2
    ! COMMAND 

    [ -O FILE ] && [ -r FILE ]
    ```        
    - 第二种方式：
    ```
    EXPRESSION1  -a  EXPRESSION2
    EXPRESSION1  -o  EXPRESSION2
    ! EXPRESSION
    
    [ -O FILE -a -x FILE ]
    ```

- 将当前主机名称保存至hostName变量中；主机名如果为空，或者为localhost.localdomain，则将其设置为www.magedu.com；
```sh
hostName=$(hostname)

[ -z "$hostName" -o "$hostName" == "localhost.localdomain" -o "$hostName" == "localhost" ] && hostname www.magedu.com
```

- 脚本的状态返回值：
    - 默认是脚本中执行的最后一条件命令的状态返回值；
    - 自定义状态退出状态码：exit [n]：n为自己指定的状态码；
        - 注意：shell进程遇到exit时，即会终止，因此，整个脚本执行即为结束；

##  过程式编程语言的代码执行顺序

- 顺序执行：逐条运行；
- 选择执行：
    - 代码有一个分支：条件满足时才会执行；
    - 两个或以上的分支：只会执行其中一个满足条件的分支；
- 循环执行：
    - 代码片断（循环体）要执行0、1或多个来回；

### 选择执行

- 选择执行：
    1. `&&`, `||`
    2. if语句
    3. case语句

#### 单分支的if语句

```sh
if  测试条件
then
    代码分支
fi
```

- 示例：通过参数传递一个用户名给脚本，此用户不存时，则添加之；
```sh
#!/bin/bash
#
if ! grep "^$1\>" /etc/passwd &> /dev/null; then
    useradd $1
    echo $1 | passwd --stdin $1 &> /dev/null
    echo "Add user $1 finished."
fi
```

```sh
#!/bin/bash
#
if [ $# -lt 1 ]; then
    echo "At least one username."
    exit 2
fi

if ! grep "^$1\>" /etc/passwd &> /dev/null; then
    useradd $1
    echo $1 | passwd --stdin $1 &> /dev/null
    echo "Add user $1 finished."
fi
```

#### 双分支的if语句

```sh
if  测试条件; then
    条件为真时执行的分支
else
    条件为假时执行的分支
fi
```

```sh
#!/bin/bash
#
if [ $# -lt 1 ]; then
    echo "At least one username."
    exit 2
fi

if grep "^$1\>" /etc/passwd &> /dev/null; then
    echo "User $1 exists."
else
    useradd $1
    echo $1 | passwd --stdin $1 &> /dev/null
    echo "Add user $1 finished."
fi
```

- 练习1：通过命令行参数给定两个数字，输出其中较大的数值；

```sh
#!/bin/bash
#
if [ $# -lt 2 ]; then
    echo "Two integers."
    exit 2
fi

if [ $1 -ge $2 ]; then
    echo "Max number: $1."
else
    echo "Max number: $2."
fi
```

```sh
#!/bin/bash
#

if [ $# -lt 2 ]; then
    echo "Two integers."
    exit 2
fi

declare -i max=$1

if [ $1 -lt $2 ]; then
    max=$2
fi

echo "Max number: $max."
```

- 练习2：通过命令行参数给定一个用户名，判断其ID号是偶数还是奇数；

- 练习3：通过命令行参数给定两个文本文件名，如果某文件不存在，则结束脚本执行；都存在时返回每个文件的行数，并说明其中行数较多的文件；

- 练习4：
    - 1、创建一个20G的文件系统，块大小为2048，文件系统ext4，卷标为TEST，要求此分区开机后自动挂载至/testing目录，且默认有acl挂载选项；
        - (1) 创建20G分区；
        - (2) 格式化：`mke2fs -t ext4 -b 2048 -L 'TEST' /dev/DEVICE`
        - (3) 编辑/etc/fstab文件：`LABEL='TEST'    /testing    ext4    defaults,acl    0 0`
    - 2、创建一个5G的文件系统，卷标HUGE，要求此分区开机自动挂载至/mogdata目录，文件系统类型为ext3；
    - 3、写一个脚本，完成如下功能：
        - (1) 列出当前系统识别到的所有磁盘设备；
        - (2) 如磁盘数量为1，则显示其空间使用信息；否则，则显示最后一个磁盘上的空间使用信息；
            ```sh
            if [ $disks -eq 1 ]; then 
                fdisk -l /dev/[hs]da
            else 
                fdisk -l $(fdisk -l /dev/[sh]d[a-z] | grep -o "^Disk /dev/[sh]d[a-]" | tail -1 | cut -d' ' -f2)
            fi
```

#### 多分支的if语句

```sh
if  CONDITION1; then
    条件1为真分支
elif  CONDITION2; then
    条件2为真分支
elif  CONDITION3; then
    条件3为真分支
    ...
elif  CONDITIONn; then
    条件n为真分支
else
    所有条件均不满足时的分支
fi
注意：if语句可嵌套；
```

- 示例：脚本参数传递一个文件路径给脚本，判断此文件的类型；

```sh
#!/bin/bash
#
if [ $# -lt 1 ]; then
    echo "At least on path."
    exit 1
fi

if ! [ -e $1 ]; then
    echo "No such file."
    exit 2
fi

if [ -f $1 ]; then
    echo "Common file."
elif [ -d $1 ]; then
    echo "Directory."
elif [ -L $1 ]; then
    echo "Symbolic link."
elif [ -b $1 ]; then
    echo "block special file."
elif [ -c $1 ]; then
    echo "character special file."
elif [ -S $1 ]; then
    echo "Socket file."
else
    echo "Unkown."
fi
```

- 练习：写一个脚本
    - (1) 传递一个参数给脚本，此参数为用户名；
    - (2) 根据其ID号来判断用户类型：
        - 0： 管理员
        - 1-999：系统用户
        - 1000+：登录用户
```sh
#!/bin/bash
#
[ $# -lt 1 ] && echo "At least on user name." && exit 1

! id $1 &> /dev/null && echo "No such user." && exit 2

userid=$(id -u $1)

if [ $userid -eq 0 ]; then
    echo "root"
elif [ $userid -ge 1000 ]; then
    echo "login user."
else
    echo "System user."
fi                                      
```

- 练习：写一个脚本
    - (1) 列出如下菜单给用户：
    ```
        disk) show disks info;
        mem) show memory info;
        cpu) show cpu info;
        *) quit;
    ```
    - (2) 提示用户给出自己的选择，而后显示对应其选择的相应系统信息；

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

### 循环执行

- 将一段代码重复执行0、1或多次；
    - 进入条件：条件满足时才进入循环；
    - 退出条件：每个循环都应该有退出条件，以有机会退出循环；
        
- bash脚本：
    - for循环
    - while循环
    - until循环

#### for循环

- 两种格式：
    - (1) 遍历列表
        ```sh
        for  VARAIBLE  in  LIST; do
            循环体
        done
        ```
        - 进入条件：只要列表有元素，即可进入循环；
        - 退出条件：列表中的元素遍历完成；
    - (2) 控制变量

- LISTT的生成方式：
    - (1) 直接给出；
    - (2) 整数列表
        - (a) `{start..end}`
        - (b) `seq [start [incremtal]] last`
    - (3) 返回列表的命令: `cat FILE`, `ls PATH`
    - (4) glob: 通配符
    - (5) 变量引用： `$@`, `$*`

- 添加三个用户

```sh
#!/bin/bash
#
for username in user21 user22 user23; do
    if id $username &> /dev/null; then
        echo "$username exists."
    else
        useradd $username && echo "Add user $username finished."
    fi
done
```

- 示例：求100以内所有正整数之和；

```sh
#!/bin/bash
#
declare -i sum=0
for i in {1..100}; do
    echo "\$sum is $sum, \$i is $i"
    sum=$[$sum+$i]
done
echo $sum
```

- 示例：判断/var/log目录下的每一个文件的内容类型

```sh
#!/bin/bash
#
for filename in /var/log/*; do
    if [ -f $filename ]; then
        echo "Common file."
    elif [ -d $filename ]; then
        echo "Directory."
    elif [ -L $filename ]; then
        echo "Symbolic link."
    elif [ -b $filename ]; then
        echo "block special file."
    elif [ -c $filename ]; then
        echo "character special file."
    elif [ -S $filename ]; then
        echo "Socket file."
    else
        echo "Unkown."
    fi                  
done
```

- 练习：
    - 1、分别求100以内所有偶数之和，以及所有奇数之和；
    - 2、计算当前系统上的所有用的id之和；
    - 3、通过脚本参数传递一个目录给脚本，而后计算此目录下所有文本文件的行数之和；并说明此类文件的总数；

#### while循环

```sh
while  CONDITION; do
    循环体
    循环控制变量修正表达式
done

# 进入条件：CONDITION测试为”真“
# 退出条件：CONDITION测试为”假“
```

- 示例：求100以内所有正整数之和
```sh
#!/bin/bash

declare -i sum=0
declare -i i=1

while [ $i -le 100 ]; do
    let sum+=$i
    let i++
done

echo $sum
```
        
#### until循环

```sh
until  CONDITION; do
    循环体
    循环控制变量修正表达式
done

# 进入条件：CONDITION测试为”假“
# 退出条件：CONDITION测试为”真“
```
- 示例：求100以内所有正整数之和

```sh
            
#!/bin/bash
#
declare -i sum=0
declare -i i=1

until [ $i -gt 100 ]; do
    let sum+=$i
    let i++
done

echo $sum
```

- 练习：分别使用for, while, until实现
    - 1、分别求100以内所有偶数之和，100以内所奇数之和；
    - 2、创建10个用户，user101-user110；密码同用户名；
    - 3、打印九九乘法表；
    - 4、打印逆序的九九乘法表；

```sh
#!/bin/bash
#
for j in {1..9}; do
    for i in $(seq 1 $j); do
        echo -n -e "${i}X${j}=$[${i}*${j}]\t"
    done
    echo
done
```

## 用户交互

- 用户交互：通过键盘输入数据，从而完成变量赋值操作；

- 用法

```sh
    read [option]... [name ...]
        -p 'PROMPT'
        -t TIMEOUT
```

- 例子：

```sh
    #!/bin/bash
    #
    read -p "Enter a username: " name
    [ -z "$name" ] && echo "a username is needed." && exit 2

    read -p "Enter password for $name, [password]: " password
    [ -z "$password" ] && password="password"

    if id $name &> /dev/null; then
        echo "$name exists."
    else
        useradd $name
        echo "$password" | passwd --stdin $name &> /dev/null
        echo "Add user $name finished."
    fi          
```

- 检测脚本中的语法错误`bash -n /path/to/some_script`

- 调试执行`bash -x /path/to/some_script`

- 示例：

```sh
#!/bin/bash
# Version: 0.0.1
# Author: MageEdu
# Description: read testing

read -p "Enter a disk special file: " diskfile
[ -z "$diskfile" ] && echo "Fool" && exit 1

if fdisk -l | grep "^Disk $diskfile" &> /dev/null; then
    fdisk -l $diskfile
else
    echo "Wrong disk special file."
    exit 2
fi
```
