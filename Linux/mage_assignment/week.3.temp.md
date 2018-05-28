# 权限管理
## 权限管理命令：
- chmod：
  - 三类用户：u(ser), g(roup), o(ther), a(ll)
  - chmod [OPTION]... MODE[,MODE]... FILE...：对文件单独操作
    - MODE表示法：
      - 赋值表示：操作一类用户的所有权限位，`chmod g=rx FILE`, `chmod ug=r FILE`，`chmod u=rwx,g=rw,o= FILE` 
      - 授权表示：操作一类用户的一个权限位，`chmod o+r FILE`，`chmod go-x FILE`，`chmod u+x,g+r FILE`
  - chmod [OPTION]... OCTAL-MODE FILE...：将文件修为对应的8进制标识的权限：`chmod 777 FILE`
  - chmod [OPTION]... --reference=RFILE FILE...：将RFILE所对应的权限也赋给FILE：`chmod --reference=RFILE FILE`
  - 选项：
    - -R, --recursive：递归修改
  - 修改文件权限，仅管理员可以修改文件权限
- chown：修改属主属组命令
  - chown [OPTION]... [OWNER][:[GROUP]] FILE...
  - chown [OPTION]... --reference=RFILE FILE...
  - 选项：
    - -R, --recursive，递归修改
  - 修改文件属主，仅仅是管理员，或者文件属主为自己的文件
- chgrp：修改属组的命令
  - chgrp [OPTION]... GROUP FILE...
  - chgrp [OPTION]... --reference=RFILE FILE...
- 用户对目录有写权限，对目录下的文件无写权限，无法修改该目录，可以删除该文件。
- umask：文件权限反向掩码，遮罩码；
  - 文件默认权限：使用`666-umask`，默认不可以有执行权限，如果得到的结果有执行权限，则需要将其+1
  - 目录默认权限：使用`777-umask`，默认可以有执行权限
  - umask命令：
    - 查看umask：`umask`
    - 修改umask：`umask 027`
    - 此类命令仅对当前shell有效
- install命令：copy files and **set attributes**
  - install [OPTION]... [-T] SOURCE DEST：将单个源文件复制到目的
  - install [OPTION]... SOURCE... DIRECTORY：将多个源复制到目的
  - install [OPTION]... -t DIRECTORY SOURCE...：同上
  - install [OPTION]... -d DIRECTORY...：创建空目录
  - 选线：
    - -m, --mode=MODE：设定目标文件权限，默认为755
    - -o, --owner=OWNER：设定文件属主
    - -g, --group=GROUP：设定文件属组
    - -d, --directory：创建目录
- mktemp：创建临时文件、目录
  - mktemp [OPTION]... [TEMPLATE]：`mktemp ./1.tXXXX`，在当前目录下，创建名为1.XXXX的文件，XXX为随机字符，且至少为3个X
  - 选项：
    - -d, --directory：创建临时目录
    - -u, --dry-run：用于测试，不会真正创建出文件
  - 该命令会将文件名直接返回，可以将其文件名保存起来

# BASH基础
## 回顾
- 终端：附着在终端的接口程序：
  - GUI：KDE，GNome，Xfce
  - CLI：/etc/shells
    - bash
    - zsh
    - fish
- bash特性：
  - 命令行展开：~，｛｝
  - 命令别名：alias
  - 命令历史：history
  - 文件名通配：glob
  - 快捷键：
  - 命令补全：
  - 路径补全：
  - 命令hash：缓存此前命令的查找结果：key-value（搜索键-值）
    - 命令：
      - `hash`：列出
      - `hash -d COMMAND`：删除相关命令
      - `hash -r`，清空
    - 变量：
  - 多命令执行：`COMMAND1; COMMAND2; COMMAND3;......`  

## 变量
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
  - **特殊变量**：shell内置的有特殊功用的变量
    - $?：上以命令的执行结果：0：成功；1-255：失败

## 逻辑运算
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
  - **#** 为注释
  - bash的配置文件
    - 交互式登录和非交互式登录：
      - 交互式登录：
        - 在某终端，输入用户名密码登录的登录方式
        - 使用su命令：`su - USERNAME`，`su -l USERNAME`执行登录切换
      - 非交互式登录：
        - `su USERNAME`执行的登录切换
        - 在图形界面下打开的终端
        - 运行脚本时
    - 两类配置文件：
      - prifile类：为交互式登录的shell提供配置：
        - 全局文件：对所有用户都有效，如：`/etc/profile`，`/etc/profiled.d/*.sh`
        - 用户个人：对当前用户有效：如`~/.bash_profile`
        - 用途：用于定义环境变量，用于运行命令、脚本
        - 读取顺序：`/etc/profile` --> `/etc/profile.d/*.sh` --> `~/.bash_profile` --> `~/.bashrc` --> `/etc/bashrc`
      - bashrc类：为非交互式登录的shell提供配置
        - 全局文件：`/etc/bashrc`
        - 用户个人：`~/.bashrc`
        - 用途：用途定义本地变量，定义命令别名
        - 读取顺序：`~/.bashrc` --> `/etc/bashrc` --> `/etc/profile.d/*.sh`
    - 仅有管理员可以定义配置文件
    - 特性的定义：
      - 命令行中定义的：例如变量和别名作用域为当前shell进程的生命周期；
      - 配置文件中定义的：只对随后的新启动的shell进程有效。若想立即生效：
        1. 通过命令行重复定义一次；
        2. 强制shell进程重读配置文件：`~]# {source | .} /PATH/FROM/CONF_FILE`

# 文本处理工具
- Linux文本处理三剑客
  - grep, egrep, fgrep：文本过滤工具，以模式（pattern）进行过滤
    - grep：基本正则表达式，-E，支持扩展正则表达式，-F不支持正则表达式
    - egrep：扩展正则表达式，-G，支持基本正则表达式，-F不支持正则表达式
    - fgrep：不支持正则表达式，-E，支持扩展正则表达式，-G，支持基本正则表达式
  - sed：stream editor，流编辑器，文本编辑工具
  - (g)awk：文本报告生成器，可以格式化文本

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

## 正则表达式
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

## 扩展正则表达式
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

## 文本查看及处理工具
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

# vim编辑器
- vi：Visual Interface
- vim：Vi IMproved
- vim常用模式：
  - 编辑模式：命令模式
  - 输入模式
  - 末行模式：内置的命令行接口
- [vim 使用技巧](https://www.ibm.com/developerworks/cn/linux/l-cn-tip-vim/index.html)
- 关闭文件：q，推出；q!，强制退出，不保存；wq，保存退出；x，保存并推出；w，另存为。
- ![vim 键盘](https://github.com/Minions1128/net_tech_notes/blob/master/img/vim.JPG)

# bash脚本编程的算数运算
- 算数运算有：+、-、*、/、`**`（次方）、%（取模）
- let VAR=算数运算表达式：`let sum=$num1+$num2`
- VAR=$[算数运算表达式]：`$[$num3+$num4]`
- VAR=$((算数运算表达式))：`$(($num3+$num4))`
- `sum=$(expr $num2 + $num4)`
- 乘法符号`*`，有些时候需要转义

# 文件查找
实现工具：locate，find
- locate：依赖于事先构建好的索引库，其系统自动实现（周期性任务），或者手动更新数据库（updatedb）；
  - 工作特点：
    - 模糊查找文件
    - 查找速度快
    - 非实时查找
    - 建立索引需要遍历整个根文件系统，及其消耗系统资源
  - locate [OPTION]... PATTERN...
    - -b, --basename：指定只查找基名
    - -c, --count，统计找出来的个数
    - -r, --regexp REGEXP，匹配正则表达式
- find：实时查找工具，通过遍历指定起始路径下文件系统层级结构完成文件查找
  - 工作特点：
    - 查找速度略慢
    - 精确查找
    - 实时查找
  - `find [选项] [查找起始路径] [查找条件] [处理动作]`
    - 查找起始路径：默认为当前目录
    - 查找条件：文件名、大小、类型、从属关系、权限等；默认为所有文件
      - 根据文件名查找：支持glob风格的通配符查找：`*`，?，[]，[^]
        - -name：根据文件名查找
        - -iname：忽略文件名大小写。
      - 根据文件从属关系：
        - -user：根据属主查找
        - -group：根据属组查找
        - -uid：根据uid查找文件
        - -gid：根据gid查找文件
        - -nouser：查找没有属主的文件
        - -nogroup：查找没有属组的文件
      - 根据文件类型查找：-type TYPE
      - 根据文件大小查找：-size [+ | -]#UNIT
        - `find /tmp -size 172k`
        - 常用单位：k，M，G
        - #UNIT：(#-1, #]
        - -#UNIT：[0, #-1]
        - +#UNIT：(#, +oo]
      - 根据时间戳查找：-OP [+-]#
        - 计算方法：#：(now-#-1, now-#]，第#天；+#：(-oo, now-#-1]，#天外；-#：(now-#, now)，#天内
        - 以天为单位：-atime，-mtime，-ctime
        - 以分钟为单位：-amin，-mmin，-cmin
      - 根据权限查找：
        - `-perm [/|-] mode`：
          - mode：精确选线查找：`find ./ -perm 644`，精确查找权限为644的文件
          - /mode：任何一类用户(u,g,o)的任何一位(r,w,x)符合条件，即满足
          - -mode：任何一类用户(u,g,o)的任何一位(r,w,x)同时符合条件，即满足
      - 组合测试：
        - 与：-a，`find /tmp -user root -type f -ls`
        - 或：-o，`find /tmp -nouser -o -type f -ls`
        - 非：-not，!，`find /tmp {-not | !} -type f -ls`
        - 组合举例：`find /tmp -not  \( -user root -o -iname "*fstab*" \) -ls`
    - 处理动作：先查找文件，将查找到的文件路径一次性传递给命令
      - -print：显示到屏幕
      - -ls：将结果ls到屏幕
      - -delete：删除查找到的文件
      - -fls /PATH/FILE：将文件ls到屏幕，且保存到/PATH/FILE中
      - `-ok COMMAND {} \;`：对查找到的文件进行执行，COMMAND表示执行命令，每次需要确认
      - `-exec COMMAND {} \;`：对查找到的文件进行执行，COMMAND表示执行命令，不需要每次确认
      - find .... | xargs：将find到的内容传递给xargs

# 7.4 15 min