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
  - grep：文本过滤工具，以模式（pattern）进行过滤
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


# 6.4 0:14:00