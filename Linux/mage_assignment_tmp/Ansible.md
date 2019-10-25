# Ansible

- 安装：epel, ansible
- 配置文件：/etc/ansible/ansible.cfg
- 主机清单：/etc/ansible/hosts
- 主程序：
    - ansible
    - ansible-playbook
    - ansible-doc
- ansible的简单使用格式：`ansible HOST-PATTERN -m MOD_NAME -a MOD_ARGS -f FORKS -C -u USERNAME -c CONNECTION`

- 常用模块：
    - `ansible-doc -l`: 获取模块列表
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
