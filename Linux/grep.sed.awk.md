# 文本处理工具
- Linux文本处理三剑客
    - grep, egrep, fgrep：文本过滤工具，以模式（pattern）进行过滤
        - grep：基本正则表达式，-E，支持扩展正则表达式，-F不支持正则表达式
        - egrep：扩展正则表达式，-G，支持基本正则表达式，-F不支持正则表达式
        - fgrep：不支持正则表达式，-E，支持扩展正则表达式，-G，支持基本正则表达式
    - sed：stream editor，流（行）编辑器，文本编辑工具
        - 模式空间
        - 保持空间
    - (g)awk：文本报告生成器，可以格式化文本

## grep

- **grep**：Global search REgular expression and Print out the line
    - 模式：由正则表达式的元字符及文本字符所编写的过滤条件
    - 用法：
        - grep [OPTIONS] PATTERN [FILE...]：直接使用pattern
        - grep [OPTIONS] [-e PATTERN | -f FILE] [FILE...]，将pattern 放在文件中使用
    - 选项：
        - -i, --ignore-case：不区分字符大小写
        - -o, --only-matching：近显示其字符串本身
        - -v, --invert-match：显示不能被模式匹配的
        - -E, --extended-regexp：支持使用扩展的正则表达式
        - -q, --quiet, --silent：不输出任何信息
        - -A #：after，同时输出匹配到的字符的前#行
        - -B #：before，同时输出匹配到的字符的后#行
        - -C #：context，同时输出匹配到的字符的前后#行

### 正则表达式
Regular Expression，REGEXP：由一类特殊字符及文本所编写的模式，其中有些字符不表示其字面意义，而表示控制、通配的功能。
- 分为两类：
    - 基本正则表达式：BRE
    - 扩展正则表达式：ERE
    - 其元字符不一致
- 基本正则的元字符
    - 字符匹配：
        - `.`：匹配任意单个字符
        - `[]`：匹配指定范围内的任意单个字符
        - `[^]`：匹配指定范围外的任意单个字符
    - 匹配次数：用于要指定其出现的次数的字符后面，用于限制其前面字符出现的次数，默认工作于贪婪模式
        - `*`：匹配其前面的字符任意次
        - `.*`：匹配任意表达式的任意字符
        - `\?`：匹配其前面的字符匹配0次或1次
        - `\+`：匹配前面的字符1次或者多次
        - `\{m\}`：匹配前面的字符m次
        - `\{m, n\}`：匹配前面的字符，至少m次，最多n次
        - `\{m,\}`：匹配前面的字符，至少m次
    - 位置锚定
        - `^`：行首锚定
        - `$`：行尾锚定
        - `^PATTERN$`：完整匹配PATTERN
            - `^$`：空白行
            - `^[[:space:]]$`：空白或者包含空白字符的行
       - 单词锚定：任意连续的字符串
            - `\<`or`\b`：首单词锚定，放在单词的左侧
            - `\>`or`\b`：尾单词锚定，放在单词的右侧
            - `\<PATTERN\>`：匹配完整单词
    - 分组以及引用：将一个或多个字符捆绑在一起
        - `\(PATTERN1\)*PATTERN2`
        - 注意：分组括号的模式匹配到的内容会被正则表达式引擎自动记录于内部变量中，这些变量为：`\#`
            - \1：从左侧起，第一个匹配到的组。
            - ```
               ]# cat 1.txt
              He loves his lover.
              He likes his lover.
              She loves her liker.
              She likes her liker.
              ]# cat 1.txt | grep "\(l..e\).*\1"
              He loves his lover.
              She likes her liker.
              ]#
              ]# cat /etc/passwd | grep "r..t"
              root:x:0:0:root:/root:/bin/bash
              operator:x:11:0:operator:/root:/sbin/nologin
              ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
              ]# cat /etc/passwd | grep "\(r..t\).*\1"
              root:x:0:0:root:/root:/bin/bash
              ]# ```
            - 后向引用：引用前面的分组括号中的模式所匹配到的字符

### 扩展正则表达式
- 支持扩展的正则表达式实现类似于grep文本过滤功能；grep -E
- 字符匹配：同grep
- 次数匹配：基本同grep，去掉了很多转义字符`\`
    - `*`：匹配其前面的字符任意次
        - `?`：匹配其前面的字符匹配0次或1次
        - `+`：匹配前面的字符1次或者多次
        - `{m}`：匹配前面的字符m次
        - `{m, n}`：匹配前面的字符，至少m次，最多n次
        - `{m,}`：匹配前面的字符，至少m次
- 位置锚定：同grep
- 分组及引用：基本同grep，去掉了很多转义字符`\`
    - `(PATTERN1)*PATTERN2`
    - 或者使用`|`
        - `C|cat`：表示C或者cat
        - `(C|c)at`：表示Cat或者cat

#### Examples
1. 找出/proc/meminfo文件中，所有以大写或小写S开头的行；至少有三种实现方式；
```
~]# grep -i "^s" /proc/meminfo
~]# grep "^[sS]" /proc/meminfo
~]# grep -E "^(s|S)" /proc/meminfo
```

2. 显示肖前系统上root、centos或user1用户的相关信息；
`~]# grep -E "^(root|centos|user1)\>" /etc/passwd`

3. 找出/etc/rc.d/init.d/functions文件中某单词后面跟一个小括号的行；
`~]# grep  -E  -o  "[_[:alnum:]]+\(\)"  /etc/rc.d/init.d/functions`

4. 使用echo命令输出一绝对路径，使用egrep取出基名；
`~]# echo /etc/sysconfig/ | grep  -E  -o  "[^/]+/?$"`

5. 找出ifconfig命令结果中的1-255之间的数值；
`~]# ifconfig | grep  -E  -o  "\<([1-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\>"`

6. 添加用户bash, testbash, basher以及nologin(其shell为/sbin/nologin)；而后找出/etc/passwd文件中用户名同shell名的行；
`~]# grep  -E  "^([^:]+\>).*\1$"  /etc/passwd`


### 文本查看及处理工具
- **wc**：word count
    - `wc [OPTION]... [FILE]...`：查看文件的行数、单词数、字节数
    - 选项：
        - -l, --lines：行数
        - -w, --words：单词数
        - -c, --bytes：字节数

- **cut**：文本截取工具
    - `cut OPTION... [FILE]...`
    - 选项：
        - -d, --delimiter=DELIM，直接跟分隔符
        - -f, --fields=LIST，截取的范围：
            - #，一个字段
            - #-#，连续字段
            - #，#，离散字段
        - `cut -d: -f1,7 /etc/passwd`：将`/etc/passwd`文件中，以`:`分割，输出第1部分和第7部分

- **sort**：排序命令
    - `sort [OPTION]... [FILE]...`
    - 选项：
        - -t, --field-separator=SEP：指定分隔符
        - -k, --key=KEYDEF：用于排序比较的字段
        - -n, --numeric-sort：基于数值大小排序，而非字符
        - -r, --reverse：逆序排序
        - -f, --ignore-case：忽略字符大小写
        - -u, --unique：重复数据只保留一次

- **uniq**：报告或移除重复行
    - `uniq [OPTION]... [INPUT [OUTPUT]]`
    - 选项：
        - -c, --count：统计分别出现的次数
        - -d, --repeated：仅显示有重复的行
        - -u, --unique：仅显示无重复的行

- **diff**：compare files line by line
    - `diff [OPTION]... FILES`
    - 生成补丁：`diff /PATH/OLD_FILE /PATH/NEW_FILE > /PATH/PATCH_FILE`
    - 选项：
        - -u, -U NUM, --unified[=NUM]：显示修改行的上下文，默认为3行
    - 还可以对比两个目录中所有的文件，并且均生成所有的补丁文件

- **patch**：apply a diff file to an original
    - `patch [options] [originalfile [patchfile]]`
    - 打补丁：`patch -i /PATH/PATCH_FILE /PATH/OLD_FILE`or`patch /PATH/OLD_FILE < /PATH/PATCH_FILE`



## sed

- 其大致原理是：其会先将文件中每一行文本，放在自己的工作车间：pattern space，处理（edit）之后会被放入到stdout

- `sed [OPTION]... 'script' [input-file] ...`
    - 常用选项：
        - -n：不输出模式空间中的内容至屏幕；
        - -e script, --expression=script：多点编辑；
        - -f /PATH/TO/SED_SCRIPT_FILE: 每行一个编辑命令；
        - -r, --regexp-extended：支持使用扩展正则表达式；
        - -i[SUFFIX], --in-place[=SUFFIX]：直接编辑原文件；
        - `~]# sed    -e    's@^#[[:space:]]*@@'     -e    '/^UUID/d'    /etc/fstab`
    - script：地址定界编辑命令
        - 地址定界：
            - (1) 空地址：对全文进行处理；
            - (2) 单地址：
                - `#`：指定行；
                - `/pattern/`：被此模式所匹配到的每一行；
            - (3) 地址范围
                - #,#：
                - #,+#：
                - #，/pat1/
                - /pat1/,/pat2/
                - $：最后一行；
            - (4) 步进：~
                - 1~2：所有奇数行
                - 2~2：所有偶数行
        - 编辑命令：
            - d：删除；
            - p：显示模式空间中的内容；(-n)
            - a \text：在行后面追加文本“text”，支持使用\n实现多行追加；
            - i \text：在行前面插入文本“text”，支持使用\n实现多行插入；
                - `sed '3i \new line' /etc/fstab`
                - `sed '/^UUID/a \# add new device based on uuid' /etc/fstab`
            - c \text：把匹配到的行替换为此处指定的文本“text”；
                - `sed '/^UUID/c \####' /etc/fstab`
            - w /PATH/TO/SOMEFILE：保存模式空间匹配到的行至指定的文件中；
                - `sed '/^[^#]/w ./ssss.txt' /etc/fstab`
                - `sed '/^#/!w ./ssss.txt' /etc/fstab`
            - r /PATH/FROM/SOMEFILE：读取指定文件的内容至当前文件被模式匹配到的行后面；文件合并；
            - =：为模式匹配到的行打印行号；
            - !：条件取反:
                - 地址定界!编辑命令；
                - `sed '/^#/!w ./ssss.txt' /etc/fstab`
            - s///：查找替换，其分隔符可自行指定，常用的有s@@@, s###等；
                - 替换标记：
                    - g：全局替换；
                    - w /PATH/TO/SOMEFILE：将替换成功的结果保存至指定文件中；
                    - p：显示替换成功的行；
    - 高级编辑命令：
        - h：把模式空间中的内容覆盖至保持空间中；
        - H：把模式空间中的内容追加至保持空间中；
        - g：把保持空间中的内容覆盖至模式空间中；
        - G：把保持空间中的内容追加至模式空间中；
        - x：把模式空间中的内容与保持空间中的内容互换；
        - n：覆盖读取匹配到的行的下一行至模式空间中；
        - N：追加读取匹配到的行的下一行至模式空间中；
        - d：删除模式空间中的行；
        - D：删除多行模式空间中的所有行；

- 练习1：删除/boot/grub/grub2.cfg文件中所有以空白字符开头的行的行首的所有空白字符；
```sh
sed 's@^[[:space:]]\+@@' /etc/grub2.cfg
```
- 练习2：删除/etc/fstab文件中所有以#开头的行的行首的#号及#后面的所有空白字符；
```sh
sed 's@^#[[:space:]]*@@' /etc/fstab
```
- 练习3：输出一个绝对路径给sed命令，取出其目录，其行为类似于dirname；
```sh
echo "/var/log/messages/" | sed 's@[^/]\+/\?$@@'
echo "/var/log/messages" | sed -r 's@[^/]+/?$@@'
```
- 练习4：
```sh
sed    -n    'n;p'          FILE    # 显示偶数行；
sed          '1!G;h;$!d'    FILE    # 逆序显示文件的内容；
sed          '$!d'          FILE    # 取出最后一行；
sed          '$!N;$!D'      FILE    # 取出文件后两行；
sed          '/^$/d;G'      FILE    # 删除原有的所有空白行，而后为所有的非空白行后添加一个空白行；
sed          'n;d'          FILE    # 显示奇数行；
sed          'G'            FILE    # 在原有的每行后方添加一个空白行；
```

## awk

- GNU awk：Aho, Weinberger, Kernighan --> New AWK, NAWK
    - pattern scanning and processing language
    - 基本用法：gawk [options] 'program' FILE ...
        - program: PATTERN{ACTION STATEMENTS}
            - 语句之间用分号分隔
            - 例如：print, printf
    - 选项：
        - -F：指明输入时用到的字段分隔符；
        - -v var=value: 自定义变量；

### 1. print

- `print item1, item2, ...`

- 要点：
    - (1) 逗号分隔符;
    - (2) 输出的各item可以字符串，也可以是数值；当前记录的字段、变量或awk的表达式;
    - (3) 如省略item，相当于print $0;

- 例如：
```sh
tail -5 /etc/fstab | awk '{print $2,$5}'
/home 0
/tmp 0
/usr 0
/var 0
swap 0
```

```sh
tail -5 /etc/fstab | awk '{print "hello: " $2}'
hello: /home
hello: /tmp
hello: /usr
hello: /var
hello: swap
```

### 2. 变量

- 2.1 内建变量
    - FS：input field seperator，默认为空白字符；
        ```sh
        tail -5 /etc/fstab |  awk -v FS='=' '{print $1}'
        UUID
        UUID
        UUID
        UUID
        UUID
        ```
        ```sh
        tail -5 /etc/fstab |  awk -F '=' '{print $1}'
        UUID
        UUID
        UUID
        UUID
        UUID
        ```
    - OFS：output field seperator，默认为空白字符；
        ```sh
        tail -5 /etc/fstab |  awk -v FS='-' -v OFS='%%' '{print $1,$2}'
        UUID=5aeef323%%4cbf
        UUID=d4264ed9%%0440
        UUID=61901ea4%%9e66
        UUID=82aaf98d%%f9da
        UUID=35cfc685%%753d
        ```
    - RS：input record seperator，输入时的换行符；
        ```sh
        tail -2 /etc/fstab |  awk -v RS='-'  '{print $1,$2}'
        UUID=82aaf98d
        f9da
        4937
        9f12
        9d6bf026d130 /var
        753d
        439d
        9f08
        28c1c544b54d swap
        ```
    - ORS：output record seperator，输出时的换行符；
        ```sh
        tail -2 /etc/fstab | awk -v RS='-' -v OFS='#' '{print $1,$2}'
        UUID=82aaf98d#
        f9da#
        4937#
        9f12#
        9d6bf026d130#/var
        753d#
        439d#
        9f08#
        28c1c544b54d#swap
        ```
    - NF：number of field，字段数量，`{print NF}`
        ```sh
        tail -2 /etc/fstab | awk -F '=' '{print NF}'
        2
        2
        # {print NF}为打印第二个字段
        ```
    - NR：number of record, 行数；
        ```sh
        tail -5 /etc/fstab | awk -F '=' '{print NR}'
        1
        2
        3
        4
        5
        ```
    - FNR：各文件分别计行数；
    - FILENAME：当前文件名；
    - ARGC：命令行参数的个数；
    - ARGV：数组，保存的是命令行所给定的各参数；

- 2.2 自定义变量
    - (1) -v var=value，变量名区分字符大小写；
        - `awk -v test='hello awk' 'BEGIN{print test}'`
    - (2) 在program中直接定义
        - `awk 'BEGIN{test="hello awk";print test}'`

### 3. printf命令

- 格式化输出：`printf FORMAT, item1, item2, ...`
    - (1) FORMAT必须给出;
    - (2) 不会自动换行，需要显式给出换行控制符，\n
    - (3) FORMAT中需要分别为后面的每个item指定一个格式化符号；

- 格式符：
    - %c: 显示字符的ASCII码；
    - %d, %i: 显示十进制整数；
    - %e, %E: 科学计数法数值显示；
    - %f：显示为浮点数；
    - %g, %G：以科学计数法或浮点形式显示数值；
    - %s：显示字符串；
    - %u：无符号整数；
    - %%: 显示%自身；

```sh
tail -5 /etc/fstab | awk -F- '{printf "p1:%s;\tp2:%s\n",$2,$3}'
p1:4cbf;        p2:40f0
p1:0440;        p2:4abb
p1:9e66;        p2:4856
p1:f9da;        p2:4937
p1:753d;        p2:439d
```

- 修饰符：
    - #[.#]：第一个数字控制显示的宽度；第二个#表示小数点后的精度；`%3.1f`
    - -: 左对齐
    - +：显示数值的符号

```sh
tail -5 /etc/passwd| awk -F: '{printf "%+2.2f\n",$3}'
+1000.00
+52.00
+1001.00
+1002.00
+25.00
```

### 4. 操作符

- 算术操作符：
    - `x+y, x-y, x*y, x/y, x^y, x%y`
    - `-x`
    - `+x`: 转换为数值；

- 字符串操作符：没有符号的操作符，字符串连接

- 赋值操作符：
    - `=, +=, -=, *=, /=, %=, ^=`
    - `++, --`

- 比较操作符：
    - `>, >=, <, <=, !=, ==`

- 模式匹配符：
    - ~：是否匹配
    - !~：是否不匹配

- 逻辑操作符：
    - &&
    - ||
    - !

- 函数调用：
    - `function_name(argu1, argu2, ...)`

- 条件表达式：
    - `selector?IF-TRUE-EXPRESSION:IF-FALSE-EXPRESSION`
    - 例如：`awk -F: '{$3>=1000?usertype="Common User":usertype="Sysadmin or SysUser";printf "%15s:%-s\n",$1,usertype}' /etc/passwd`

### 5. PATTERN

- (1) empty：空模式，匹配每一行；
- (2) /regular expression/：仅处理能够被此处的模式匹配到的行；
    - !: 对结果取反
    ```sh
    awk -F- '/^UUID/{print $1}' /etc/fstab
    UUID=19d170bc
    UUID=06fe9c9e
    UUID=1a6af1df
    UUID=24203acf
    UUID=718dab94
    UUID=42090979
    UUID=d1fd90b7
    UUID=9d83aed5
    ```
    ```sh
    awk '!/^UUID/{print $1}' /etc/fstab

    #
    #
    #
    #
    #
    ```
- (3) relational expression: 关系表达式；结果有“真”有“假”；
    - 结果为“真”才会被处理；
    - 真：结果为非0值，非空字符串；
    ```sh
    awk -F: '$3>=1000{print $3}' /etc/passwd
    65534
    1000
    1001
    1002
    1003
    2002
    1005
    2003
    2020
    ```
    ```sh
    awk -F: '$NF=="/bin/bash"{print $1,$NF}' /etc/passwd
    awk -F: '$NF~/bash$/{print $1,$NF}' /etc/passwd
    root /bin/bash
    shenzj /bin/bash
    hadoop /bin/bash
    bash /bin/bash
    testbash /bin/bash
    user1 /bin/bash
    user2 /bin/bash
    ```
- (4) line ranges：行范围，
    - startline,endline：/pat1/,/pat2/
    - 注意： 不支持直接给出数字的格式
    ```sh
    awk -F: '(NR>=11&&NR<=15){print $3}' /etc/passwd # 在11行到15行之间的
    12
    14
    99
    66
    170
    ```
- (5) BEGIN/END模式
    - BEGIN{}: 仅在开始处理文件中的文本之前执行一次；
        ```sh
        awk -F: 'BEGIN{print "\tUSERNAME: \tUID\t\n----------------------------------------------"}(NR>=11&&NR<=13){printf "%20s\t%s\t\n",$1,$3}' /etc/passwd
                USERNAME:       UID
        ----------------------------------------------
                      shenzj    1012
                       test1    1014
                      nobody    1099
        ```
    - END{}：仅在文本处理完成之后执行一次；

### 6. 常用的action

- (1) Expressions
- (2) Control statements：if, while等；
- (3) Compound statements：组合语句；
- (4) input statements
- (5) output statements

### 7. 控制语句

- 控制语句种类：
    - if(condition) {statments}
    - if(condition) {statments} else {statements}
    - while(conditon) {statments}
    - do {statements} while(condition)
    - for(expr1;expr2;expr3) {statements}
    - break
    - continue
    - delete array[index]
    - delete array
    - exit
    - { statements }

- 7.1 if-else
    - 语法：if(condition) statement [else statement]
    - 使用场景：对awk取得的整行或某个字段做条件判断；
    - e.g.1： userid大于1000的显示为“common user”，否则显示为“root or Sysuser”
        ```sh
        awk -F: '{if($3>=1000) {printf "Common user: %s\n",$1} else {printf "root or Sysuser: %s\n",$1}}' /etc/passwd
        root or Sysuser: root
        root or Sysuser: nobody
        Common user: shenzj
        Common user: user1
        Common user: user2
        ...
        ```
    - e.g.2： 显示以“/bin/bash”结尾的用户
        ```sh
        awk -F: '{if($NF=="/bin/bash") print $1}' /etc/passwd
        root
        shenzj
        ...
        ```
    - `awk '{if(NF>5) print $0}' /etc/fstab`
    - `df -h | awk -F[%] '/^\/dev/{print $1}' | awk '{if($NF>=20) print $1}'`

- 7.2 while循环
    - 语法：while(condition) statement; 条件“真”，进入循环；条件“假”，退出循环；
    - 使用场景：对一行内的多个字段逐一类似处理时使用；对数组中的各元素逐一处理时使用；
    - e.g.1: 处理文件`/etc/grub2.cfg`中，linux16开头的每一行，统计其每个字符串的字符个数：
        ```sh
        cat /etc/grub2.cfg | grep "^[[:space:]]*linux16"
                linux16 /vmlinuz-3.10.0-327.el7.x86_64 root=UUID=19d170bc-a683-4050-adba-978d99e8e910 ro rhgb quiet net.ifnames=0 biosdevname=0
                linux16 /vmlinuz-0-rescue-f2646364ecfc443f8bf9c2da8550a3c7 root=UUID=19d170bc-a683-4050-adba-978d99e8e910 ro rhgb quiet net.ifnames=0 biosdevname=0
        ####
        cat /etc/grub2.cfg | grep "^[[:space:]]*linux16" | awk '{i=1;while(i<NF) {printf "string: [%s],\t length is %s\n",$i,length($i);i++}printf"\n"}'
        awk '/^[[:space:]]*linux16/{i=1;while(i<=NF) {printf "string: [%s],\t length is %s\n", $i, length($i); i++}printf"\n"}' /etc/grub2.cfg
        string: [linux16],       length is 7
        string: [/vmlinuz-3.10.0-327.el7.x86_64],        length is 30
        string: [root=UUID=19d170bc-a683-4050-adba-978d99e8e910],        length is 46
        string: [ro],    length is 2
        string: [rhgb],  length is 4
        string: [quiet],         length is 5
        string: [net.ifnames=0],         length is 13

        string: [linux16],       length is 7
        string: [/vmlinuz-0-rescue-f2646364ecfc443f8bf9c2da8550a3c7],    length is 50
        string: [root=UUID=19d170bc-a683-4050-adba-978d99e8e910],        length is 46
        string: [ro],    length is 2
        string: [rhgb],  length is 4
        string: [quiet],         length is 5
        string: [net.ifnames=0],         length is 13

        # {
        #     i=1;
        #     while(i<NF)
        #     {
        #         printf "string: [%s],\t length is %s\n",$i,length($i);
        #         i++
        #     }
        #     printf"\n"
        # }
        ```
    - e.g.2: 在e.g.1中，只显示长度大于等于7的字符串及其长度
        ```sh
        cat /etc/grub2.cfg | grep "^[[:space:]]*linux16" | awk '{i=1;while(i<NF){if(length($i)>=7) printf "string: [%s],\t length is %s\n", $i, length($i); i++}printf "\n"}'
        awk '/^[[:space:]]*linux16/{i=1;while(i<NF){if(length($i)>=7) printf "string: [%s],\t length is %s\n", $i, length($i); i++}printf "\n"}' /etc/grub2.cfg
        string: [linux16],       length is 7
        string: [/vmlinuz-3.10.0-327.el7.x86_64],        length is 30
        string: [root=UUID=19d170bc-a683-4050-adba-978d99e8e910],        length is 46
        string: [net.ifnames=0],         length is 13

        string: [linux16],       length is 7
        string: [/vmlinuz-0-rescue-f2646364ecfc443f8bf9c2da8550a3c7],    length is 50
        string: [root=UUID=19d170bc-a683-4050-adba-978d99e8e910],        length is 46
        string: [net.ifnames=0],         length is 13

        # {
        #     i=1;
        #     while(i<NF)
        #     {
        #         if(length($i)>=7)
        #             printf "string: [%s],\t length is %s\n", $i, length($i);
        #         i++
        #     }
        #     printf "\n"
        # }
        ```

- 7.3 do-while循环
    - 语法：do statement while(condition)
    - 意义：至少执行一次循环体

- 7.4 for循环
    - 语法：for(variable assignment;condition;iteration process) {for-body}
    - 能够遍历数组中的元素：
        - 语法：for(var in array) {for-body}
    - 7.2中的e.g.2
        ```sh
        cat /etc/grub2.cfg | grep "^[[:space:]]*linux16" | awk '{for(i=1;i<NF;i++){printf "string: [%s],\t length is %s\n", $i, length($i)}printf "\n"}'
        awk '/^[[:space:]]*linux16/{for(i=1;i<NF;i++){printf "string: [%s],\t length is %s\n", $i, length($i)}printf "\n"}' /etc/grub2.cfg
        string: [linux16],       length is 7
        string: [/vmlinuz-3.10.0-327.el7.x86_64],        length is 30
        string: [root=UUID=19d170bc-a683-4050-adba-978d99e8e910],        length is 46
        string: [ro],    length is 2
        string: [rhgb],  length is 4
        string: [quiet],         length is 5
        string: [net.ifnames=0],         length is 13

        string: [linux16],       length is 7
        string: [/vmlinuz-0-rescue-f2646364ecfc443f8bf9c2da8550a3c7],    length is 50
        string: [root=UUID=19d170bc-a683-4050-adba-978d99e8e910],        length is 46
        string: [ro],    length is 2
        string: [rhgb],  length is 4
        string: [quiet],         length is 5
        string: [net.ifnames=0],         length is 13

        ```

- 7.5 switch语句
    - 语法：switch(expression) {case VALUE1 or /REGEXP/: statement; case VALUE2 or /REGEXP2/: statement; ...; default: statement}

- 7.6 break和continue
    - break [n], 可以退出n重循环
    - continue

- 7.7 next
    - 提前结束对本行的处理而直接进入下一行；
    - `awk -F: '{if($3%2!=0) next; print $1,$3}' /etc/passwd`

### 8. array

- 关联数组：array[index-expression]

- index-expression:
    - (1) 可使用任意字符串；字符串要使用双引号；
    - (2) 如果某数组元素事先不存在，在引用时，awk会自动创建此元素，并将其值初始化为“空串”；

- 若要判断数组中是否存在某元素，要使用"index in array"格式进行；
    - weekdays["mon"]="Monday"
    ```sh
    awk 'BEGIN{weekdays["mon"]="Monday";weekdays["tue"]="Tuesday";print weekdays["tue"];print weekdays["mon"]}'
    Tuesday
    Monday
    ```

- 若要遍历数组中的每个元素，要使用for循环: `for(var in array) {for-body}`
    - `awk 'BEGIN{weekdays["mon"]="Monday";weekdays["tue"]="Tuesday";for(i in weekdays) {print weekdays[i]}}'` **注意：var会遍历array的每个索引**
    - 统计`netstat -tan`中，每种状态各出现了多少次
        ```sh
        # state["LISTEN"]++
        # state["ESTABLISHED"]++
        netstat -tan | awk '/^tcp\>/{state[$NF]++}END{for(i in state) { print i,state[i]}}'
        LISTEN 15
        CLOSE_WAIT 29
        ESTABLISHED 24
        TIME_WAIT 214
        ```

- 练习1：统计/etc/fstab文件中每个文件系统类型出现的次数；

```sh
awk '/^UUID/{f[$3]++}END{for (i in f) {print i,f[i]}}' /etc/fstab
```

- 练习2：统计指定文件中每个单词出现的次数；

```sh
awk '{for(i=1;i<=NF;i++){count[$i]++}}END{for(i in count) {print i,count[i]}}' /etc/fstab
```

### 9. 函数

- 9.1 内置函数
    - 数值处理：
        - rand()：返回0和1之间一个随机浮点数；
        - 数学相关：cos( x ), sin( x ), exp( x ), log( x ), sqrt( x ), int( x )
    - 字符串处理：
        - length([s])：返回指定字符串的长度；
        - sub(r,s,[t])：以r表示的模式来查找t所表示的字符中的匹配的内容，并将其第一次出现替换为s所表示的内容；
        - gsub(r,s,[t])：以r表示的模式来查找t所表示的字符中的匹配的内容，并将其所有出现均替换为s所表示的内容；
        - split(s,a[,r])：以r为分隔符切割字符s，并将切割后的结果保存至a所表示的数组中；
            - `netstat -tan | awk '/^tcp\>/{split($5,ip,":");count[ip[1]]++}END{for (i in count) {print i,count[i]}}'`

- 9.2 自定义函数
    - 《sed和awk》

### 一些例子：

1. 清除ARP表项

```sh
arp -n | awk '/^[1-9]/{system("arp -d "$1)}'
arp -n | awk '/^[1-9]/{print "arp -d ",$1}' | sh -x
```

2. 有三个文件 std_num, gender, score.

```sh
cat std_num
张三|000001
李四|000002

cat gender
张三|m
李四|f

cat score
000001|maths|65
000001|chemistry|70
000002|maths|75
000002|chemistry|80
```

要求将学生姓名和性别还有分数对应输出, 为:

```
张三-m-000001-maths-65
张三-m-000001-chemistry-70
李四-f-000002-maths-75
李四-f-000002-chemistry-80
```

一种 awk 的写法为:

```sh
awk -F'|' -v OFS='-' '
    NR==FNR{n[$2]=$1;next}
    NR-2==FNR{g[$1]=$2;next}
    {print n[$1], g[n[$1]], $1, $2, $3}
' std_num gender score
```
