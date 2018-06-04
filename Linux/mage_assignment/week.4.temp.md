# 第四周作业
1. 复制/etc/skel目录为/home/tuser1，要求/home/tuser1及其内部文件的属组和其他用户均没有任何访问权限

```
cp -r /etc/skel/ /home/tuser1
chmod go= /home/tuser1/ -R
```

2. 编辑/etc/group文件，添加组hadoop

```
vim /etc/group
hadoop:x:2020
```

3. 手动编辑/etc/passwd文件新增一行，添加用户hadoop，其基本组ID为hadoop组的id号；其家目录为/home/hadoop

```
echo "hadoop:x:2020:2020::/home/hadoop:/bin/bash" >> /etc/passwd
id hadoop
uid=2020(hadoop) gid=2020 groups=2020
```

4. 复制/etc/skel/目录为/home/hadoop/，要求修改hadoop目录的属组和其他用户没有任何访问权限

```
cp -r /etc/skel/ /home/hadoop 
chmod go= /home/hadoop/ 
```

5. 修改/home/hadoop目录及其内部的所有文件的属主为hadoop，属组为hadoop

```
chown hadoop:hadoop /home/hadoop/ -R
```

6. 显示/proc/meminfo文件中以大写或小写s开头的行；用两种方式

```
cat /proc/meminfo | grep -i '^s'
cat /proc/meminfo | grep -E '^(S|s)'
```

7. 显示/etc/passwd文件中其默认shell为非/sbin/nologin的用户

```
cat /etc/passwd | grep -v "/sbin/nologin$" | cut -d: -f1
```

8. 显示/etc/passwd文件中其默认shell为/bin/bash的用户

```
cat /etc/passwd | grep  "/bin/bash$" | cut -d: -f1
```

9. 找出/etc/passwd文件中的一位数或两位数

```
cat /etc/passwd | grep  -oE "\<[0-9]{1,2}\>" 
```

10. 显示/boot/grub2/grub.cfg中以至少一个空白字符开头的行

```
cat /boot/grub2/grub.cfg | grep -E "^[[:space:]]+"
```

11. 显示/etc/rc.d/rc.sysinit文件中以#开头，后面跟至少一个空白字符，而后又有至少一个非空白字符的行

```
cat /etc/rc.d/rc.local |grep -E '^#[[:space:]]+[^[:space:]]+'
```

12. 打出netstat -tan 命令执行结果中以’LISTEN’后或跟空白字符结尾的行

```
netstat -tan | grep -E "(LISTEN)|(LISTEN[[:space:]]*$)"
```


13. 添加用户bash testbash basher nologin (此一个用户的shell为/sbin/nologin),而后找出当前系统上其用户名和默认shell相同的用户信息

```
useradd bash
useradd testbash
useradd basher
useradd -s /sbin/nologin nologin
cat /etc/passwd |grep "^\(\<.*\>\).*\1$"
```

# 磁盘分区及文件系统管理
`8.1 30 min`