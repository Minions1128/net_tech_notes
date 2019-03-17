# 文本处理工具
- Linux文本处理三剑客
  - grep, egrep, fgrep：文本过滤工具，以模式（pattern）进行过滤
    - grep：基本正则表达式，-E，支持扩展正则表达式，-F不支持正则表达式
    - egrep：扩展正则表达式，-G，支持基本正则表达式，-F不支持正则表达式
    - fgrep：不支持正则表达式，-E，支持扩展正则表达式，-G，支持基本正则表达式
  - sed：stream editor，流编辑器，文本编辑工具
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

## awk
