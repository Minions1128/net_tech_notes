# Ansible

- 安装：epel, ansible
- 配置文件：/etc/ansible/ansible.cfg
- 主机清单：/etc/ansible/hosts
- 主程序：
    - ansible
    - ansible-playbook
    - ansible-doc: 查看文档
        - `ansible-doc -l`: 获取模块列表
        - `ansible-doc -s MOD_NAME`

## Ad-hoc

- ansible的简单使用格式：`ansible HOST-PATTERN -m MOD_NAME -a MOD_ARGS -f FORKS -C -u USERNAME -c CONNECTION`

- 常用模块：
    - copy: `ansible HOST-PATTERN -m copy -a "src=/PATH/file.file dest=/tmp/PATH/file.file.ansible mode=600"`
        - src
        - dest
        - content
        - group
        - mode
    - fetch：Fetches a file from remote nodes
    - command模块: 在远程主机运行命令；
    - shell: `ansible HOST-PATTERN -m shell -a "mkdir -pv /home/testuser/test"`
    - user: `ansible HOST-PATTERN -m user -a MOD_ARGS`
        - MOD_ARGS
            - \*name=
            - system=
            - uid=
            - shell=
            - group=
            - groups=
            - comment=
            - home=
    - group: `ansible HOST-PATTERN -m group -a "gid=<int> name=<GROUP-NAME> state={present|absent} system={yes|no}"`
    - file: Sets attributes of files
        - (1) 创建链接文件：\*path= src= state=link
        - (2) 修改属性：path= owner= mode= group=
        - (3) 创建目录：path= state=directory
    - cron: Manage cron.d and crontab entries. `ansible all -m cron -a "minute=*/3 job='/sbin/ntpdate ntp.ksyun.cn &> /dev/null' name='asdf' state=present"`
        - minute=
        - day=
        - month=
        - weekday=
        - hour=
        - job=
        - \*name=
        - state=
            - present：创建
            - absent：删除
    - yum: Manages packages with the 'yum' package manager. `ansible all -m yum -a "name=nginx state=installed"`
        - name=：程序包名称，可以带版本号；
        - state=
            - present, latest, installed
            - absent
    - service: 管理服务`ansible all -m service -a "*name=nginx state={started|stopped|restarted} [enalbed={yes|no}]"`
    - script: `ansible all -m script -a "/tmp/test.sh"`
        - /tmp/test.sh:
        ```
            #!/bin/bash
            echo "ansible script" > /tmp/ansible.test.txt
        ```

## Playbook
Playbook：YAML格式，任务（task）
YAML：YAML（/•jæm•l/，尾音类似camel骆驼）是一个可读性高，用来表达数据序列的格式。YAML参考了其他多种语言，包括：C语言、Python、Perl，并从XML、电子邮件的数据格式（RFC 2822）中获得灵感。Clark Evans在2001年首次发表了这种语言，另外Ingy döt Net与Oren Ben-Kiki也是这语言的共同设计者。目前已经有数种编程语言或脚本语言支持（或者说解析）这种语言。
YAML是"YAML Ain't a Markup Language"（YAML不是一种标记语言）的递归缩写。在开发的这种语言时，YAML 的意思其实是："Yet Another Markup Language"（仍是一种标记语言），但为了强调这种语言以数据做为中心，而不是以标记语言为重点，而用反向缩略语重命名。
YAML的语法和其他高级语言类似，并且可以简单表达清单、散列表，标量等数据形态。它使用空白符号缩进和大量依赖外观的特色，特别适合用来表达或编辑数据结构、各种配置文件、倾印除错内容、文件大纲（例如：许多电子邮件标题格式和YAML非常接近）。
基本数据结构：
标量、数组、关联数组
维基百科
https://zh.wikipedia.org/wiki/YAML
