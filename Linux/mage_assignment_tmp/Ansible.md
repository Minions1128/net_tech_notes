# Ansible

- [Ansible中文权威指南](http://www.ansible.com.cn "Ansible中文权威指南")

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

### 常用模块：

- copy: `ansible HOST-PATTERN -m copy -a "src=/PATH/file.file dest=/tmp/PATH/file.file.ansible mode=600"`
    - src
    - dest
    - content
    - group
    - mode
    ```
    ansible -i hosts all -m copy -a "
        { src=/home/shenzhejian/gwFlow_go | content=asdd }
        dest=/home/shenzhejian/
        group=shenzhejian
        owner=shenzhejian
        mode=0755
    "
    ```

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

- Playbook：YAML格式，任务（task）
    - Example:
    ```
    - hosts: all
      remote_user: root
      tasks:
        - name: install redis
          yum: name=redis state=latest
        - name: copy config file
          copy: src=/home/shenzhejian/playbook/redis.conf dest=/etc/redis.conf owner=redis
          notify: restart redis
          tags: configfiles
        - name: start redis
          service: name=redis state=started
      handlers:
        - name: restart redis
          service: name=redis state=restarted
    ```
    - YAML, YAML Ain't a Markup Language, YAML不是一种标记语言; 基本数据结构：标量、数组、关联数组

- Playbook的核心元素：
    - Hosts：主机
    - Tasks：任务列表
    - Variables：
    - Templates：包含了模板语法的文本文件；
    - Handlers：由特定条件触发的任务；
    - Roles

- 运行playbook的方式：
    - (1) 测试
        - `ansible-playbook --check` 只检测可能会发生的改变，但不真正执行操作；
        - `ansible-playbook --list-hosts` 列出运行任务的主机；
    - (2) 运行

### 基础组件

- Hosts：运行指定任务的目标主机；

- remoute_user: 在远程主机上执行任务的用户，如，sudo_user

- tasks：任务列表
    - 模块，模块参数；
    - 格式：
        - (1) action: module arguments
        - (2) module: arguments
    - 注意：shell和command模块后面直接跟命令，而非key=value类的参数列表；
        - (1) 某任务的状态在运行后为changed时，可通过“notify”通知给相应的handlers；
        - (2) 任务可以通过"tags“打标签，而后可在ansible-playbook命令上使用-t指定进行调用；

- handlers：任务，在特定条件下触发；
    - 接收到其它任务的通知时被触发；notify: HANDLER TASK NAME

- variables：
    - 变量引用：{{ variable }}
    - (1) facts：可直接调用，可使用setup模块直接获取目标主机的facters；
        ```yaml
        - hosts: 172.17.0.111
          remote_user: root
          tasks:
            - name: copy file
              copy: content={{ ansible_env }} dest=/tmp/ansible.env
        ```
    - (2) 用户自定义变量：
        - (a) ansible-playbook命令的命令行中的: -e VARS, --extra-vars=VARS
        - (b) 在playbook中定义变量的方法：
            ```
            - var1: value1
            - var2: value2
            ```
            ```
            - hosts: all
              remote_user: root
              tasks:
                - name: install {{ pkgname }} package
                  yum: name={{ pkgname }} state=latest
            # ansible-playbook -e pkgname=mencached 1.yaml
            ```
    - (3) 通过roles传递变量；
    - (4) Host Inventory
        - (a) 用户自定义变量
            - (i) 向不同的主机传递不同的变量；
                - IP/HOSTNAME varaiable=value var2=value2
            - (ii) 向组中的主机传递相同的变量；在host文件中，定义：
            ```
            - [groupname:vars]
            - variable=value
            ```
        - (b) invertory参数: 用于定义ansible远程连接目标主机时使用的参数，而非传递给playbook的变量；
            - ansible_ssh_host
            - ansible_ssh_port
            - ansible_ssh_user
            - ansible_ssh_pass
            - ansbile_sudo_pass
            ```
            # vim /etc/ansible/hosts
            10.0.0.1  ansible_ssh_user=root ansible_ssh_port=22 ansible_ssh_pass=root@123
            ```
            ```
            # hosts
            10.0.0.1 http_port=80
            10.0.0.2 http_port=80

            # var.yaml
            - hosts: websrvs
              remote_user: root
              vars:
                - pbvar: playbook var testing
              tasks:
                - name: command line var
                  copy: content={{ cmdvar }} dest=/tmp/cmd.var
                - name: playbook var
                  copy: content={{ pbvar }} dest=/tmp/pb.var
                - name: host inv var
                  copy: content={{ hivar }} dest=/tmp/hi.var

            # ansible-playbook -e "cmdvar='asdf asdf asdf'" var.yaml
            # cat cmd.var pb.var hi.var
            ```

- setup模块

### 模板

- template模块：基于模板方式生成一个文件复制到远程主机
    - \*src=
    - \*dest=
    - owner=
    - group=
    - mode=

- templates: 文本文件，嵌套有脚本（使用模板编程语言编写）,Jinja2，示例：
    ```
    # cat var.yaml
    - hosts: websrvs
      remote_user: root
      tasks:
        - name: install nginx
          yum: name=nginx state=present
        - name: install conf file
          template: src=files/nginx.conf.j2 dest=/etc/nginx/nginx.conf
          notify: restart nginx
          tags: instconf
        - name: start nginx service
          service: name=nginx state=started
      handlers:
        - name: restart nginx
          service: name=nginx state=restarted

    # nginx.conf.j2
    worker_processes {{ ansible_processor_vcpus }};
    listen {{ http_port }};
    ```

### 条件测试

- when语句：在task中使用，jinja2的语法格式
    ```yaml
    - hosts: websrvs
      remote_user: root
      tasks:
        - name: install conf file to centos7
          template: src=files/nginx.conf.c7.j2
          when: ansible_distribution_major_version == "7"
        - name: install conf file to centos6
          template: src=files/nginx.conf.c6.j2
          when: ansible_distribution_major_version == "6"
    ```

### 循环

- 迭代，需要重复执行的任务；对迭代项的引用，固定变量名为”item“; 而后，要在task中使用with_items给定要迭代的元素列表；
    ```yaml
    - hosts: websrvs
      remote_user: root
      tasks:
        - name: install some packages
          yum: name={{ item }} state=present
          with_items:
            - nginx
            - memcached
            - php-fpm
        - name: add some groups
          group: name={{ item }} state=present
          with_items:
            - group11
            - group12
            - group13
        - name: add some users
          user: name={{ item.name }} group={{ item.group }} state=present
          with_items:
            - { name: 'user11', group: 'group11' }
            - { name: 'user12', group: 'group12' }
            - { name: 'user13', group: 'group13' }
    ```

### 角色(roles)

- 角色集合：
    - roles/
    - mysql/
    - httpd/
    - nginx/
    - memcached/

- 每个角色，以特定的层级目录结构进行组织：
    - mysql/
    - files/ ：存放由copy或script模块等调用的文件；
    - templates/：template模块查找所需要模板文件的目录；
    - tasks/：至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含；
    - handlers/：至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含；
    - vars/：至少应该包含一个名为main.yml的文件；其它的文件需要在此文件中通过include进行包含；
    - meta/：至少应该包含一个名为main.yml的文件，定义当前角色的特殊设定及其依赖关系；其它的文件需要在此文件中通过include进行包含；
    - default/：设定默认变量时使用此目录中的main.yml文件；
    - 在playbook调用角色方法1：
        ```
        - hosts: websrvs
          remote_user: root
          roles:
            - mysql
            - memcached
            - nginx
        ```
    - 在playbook调用角色方法2：传递变量给角色
        ```
        - hosts:
          remote_user:
          roles:
            - { role: nginx, username: nginx }
        ```
    - 键role用于指定角色名称；后续的k/v用于传递变量给角色；
    - 还可以基于条件测试实现角色调用；
        ```
        roles:
        - { role: nginx, when: "ansible_distribution_major_version == '7' " }
        ```

## Others

- ansible-vcs：https://github.com/andrewrothstein/ansible-vcs

- 实战项目：
    - 主/备模式高可用keepalived+nginx(proxy)
    - 两台主机：httpd+php
    - 一台主机：mysql-server或mariadb-server；
