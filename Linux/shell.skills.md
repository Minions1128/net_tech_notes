# Skills

## 空间分析

- 磁盘空间不足, 需要快速定位或者对文件使用率进行排序, 需要查看哪一些文件目录或者文件占用的空间比较多, 就需要如下组合命令

```sh
du -x --max-depth=1 /|sort -k1nr
```

- 系统上产生很多碎片文件时, 随之产生大量的 Inode, Inode 用于存放着文件系统中文件的源数据, Inode过渡的使用会导致系统 Inode 资源不足.

```sh
find -type f| \
    awk -F/ -v OFS=/ '{$NF="";dir[$0]++}END{for(i in dir)print dir[i]""i}'| \
    sort -k1nr|head

# find -type f: 按照文件类型查找, 查找普通文件
# awk -F/ -v OFS=/ '{$NF="";dir[$0]++}END{for(i in dir)print dir[i]""i}':
#     -v OFS=/: 输出时, 按照"/"分割输出
#     $NF="": 将每一行的最后一个字符置为空
#     dir[$0]: 将$0存入数组; dir[$0]++; 计数+1
#     dir[i]: 计数的内容
#     i: 数组内容
```

## 指定文件操作

- 查找替换

```sh
find ./ -type f -name consumer.xml -exec sed -i "s/aaaaaa/bbbbbb/g" {} \;
```

- 批量打包

```sh
(find . -name "*.txt"|xargs tar -cvf test.tar) && cp -f test.tar /home/.
```
## 链接状态分析

```sh
netstat -n|awk '/^tcp/{++S[$NF]}END {for(a in S) print a, S[a]}'
```

## Curl

```sh
-v: 详情;
--trace file.txt: 将整个过程, 以二进制的形式输出;
--resolve "static.meituan.net:80:[240e:ff:e02c:1:21::]": 手动解析;
-O: 下载文件
-C: 断点续传
```

## Linux Analysis Tools

