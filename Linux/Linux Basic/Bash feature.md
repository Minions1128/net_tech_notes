# bash的基本特性

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
  - 多命令执行：`COMMAND1; COMMAND2; COMMAND3;......`  


- 命令执行的状态结果：bash通过状态返回值，成功0，失败用非0（1-255）值。其会在命令执行完成之后，保存在$?的变量中
- 命令执行结果：引用命令的执行结果$(COMMAND)或者\`COMMAND\`来应用命令的执行结果
- 引用：
  - 强引用''
  - 弱引用""
  - 命令引用\`\`
- 快捷键：
  - ctrl+a：跳转至命令行首
  - ctrl+e：跳转至命令行尾
  - ctrl+u：删除行首到光标所在处之间的所有字符
  - ctrl+k：删除光标所在处到行尾之间的所有字符
  - ctrl+l：清屏，相当于clear


## bash 基础特性：globbing

文件名通配
- 匹配模式：元字符
  - \*：任意长度的任意字符
  - ?：任意单个字符
  - []：匹配指定范围内的任意单个字符
    - [a-z]：任意单个字母a-z
  - [0-9]：任意单个数字
  - [a-z0-9]：任意单个字母或者数字
  - [abcxyz]：a, b, c, x, y, z中的任意单个字符
  - [[:upper:]]：所有大写字母
  - [[:lower:]]：所有小写字母
  - [[:alpha:]：所有字母
  - [[:digit:]]：所有数字
  - [[:alnum:]]：所有字母和数字
  - [[:space:]]：空白字符
    - \为转义字符
  - [[:punct:]]：所有标点符号
  - [^]：匹配指定范围外的任意单个字符：
    - [^[:alnum:]]：任意非字母和数字的字符

## I/0重定向及管道

- 程序三种数据流：
  - 输入的数据流：<-- 标准输入（stdin），键盘
  - 输出数据流：-->标准输出（stdout），显示器
  - 错误输出流：-->错误输出（stderr），显示器
- fd：file descriptor，文件描述符
  - 标准输入：0
  - 标准输出：1
  - 错误输出：2

## 基本命令

命令类型：内部命令、外部命令。通过`type COMMAND`类查看。命令有别名，别名可以与原名相同，此时原名被隐藏。如果要运行原命令，需要在使用`/`
- **aslias**
  - 查看所有可用的别名定义：`aslias`
  - 定义别名：`alias fping='ping -w 1 -n 10 -i 0.01'`，仅本次登录有效
  - 撤销别名：`unalias fping`
- **witch**：显示命令的完整路径
  - 用法：which [options] [--] programname [...]
  - 参数：`--skip-alias`：忽略别名
- **whereis**：显示二进制程序路径、手册路径和源地址路径
  - 用法：whereis [options] [-BMS directory... -f] name...
  - 选项：
    - -b：仅显示二进制程序路径
    - -m：Search only for manuals.
    - -s：Search only for sources.
- **who**：登录当前系统的用户
  - 选项：
    - -b：系统上一次的启动时间
    - -r：运行级别
- **w**：增强版的who命令
- **history**
  - shell进程会在其会话中，保存此前用户提交执行的命令。使用`history`命令查看
  - 定制history的功能，可通过环境变量来实现：
    -  `echo $HISTSIZE`：命令历史的条数
    -  `echo $HISTFILE`：查看当前用户持久保存命令历史的文件路径
    -  `echo $HISTFILESIZE`：查看HISTFILE中的命令大小
  -  用法：
    -  `history [-c] [-d 偏移量] [n]`：对历史命令进行操作
      -  **-c**：清空命令历史
      -  **-c -d 偏移量**：从指定偏移量清除历史，偏移量标识
      -  `history 10`：显示最近10条命令
    -  `history -anrw [filename]`：操作历史文件
      -  **-r**：从文件中，读取历史命令到缓存中（read the history file and append the contents to the history list）
      -  **-w**：读取缓存中的历史命令，追加到文件中（write the current history to the history file and append them to the history list）
    -  调用history中的命令：
      -  `!10`，再次执行第10条命令
- 调用上一条命令的最后一个参数：`ESC .`、`!$`
- 控制命令历史的方式：HISTCONTROL，其取值有：
  - ignoredups：忽略重复命令
  - ignorespace：忽略以空白开头的命令
  - ignoreboth：忽略以上两种
  - 修改方式：`HISTCONTROL=ignorespace`，仅对当前shell有效


## bash的配置文件
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
