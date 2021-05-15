#!/bin/sh
####################
#system optimization
####################
#Jeson@imoocc.com

WORK_DIR=$(pwd)
#Only root
[[ $EUID -ne 0 ]] && echo 'Error: This script must be run as root!' && exit 1


###
# Close selinux services
###
/bin/sed -i 's/mingetty tty/mingetty --noclear tty/' /etc/inittab
/bin/sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/selinux/config
/bin/sed -i 's/SELINUX=enforcing/SELINUX=disabled/'  /etc/selinux/config

/bin/cat<<EOF >> /etc/profile

export PS1='\u@\h:\w\n\\$ '

EOF


###
# Close unuseful services
###
systemctl disable 'postfix'
systemctl disable 'NetworkManager'
systemctl disable 'abrt-ccpp'


###
# Add normal user
###
groupadd -g 20000 jesonc

useradd  -g jesonc -u 20000 -s /bin/bash -c "Dev user" -m -d /home/jesonc jesonc
echo jesonc.com | passwd --stdin jesonc

###
# Configre sudoers
###
sed -i 's/^Defaults    requiretty/#Defaults    requiretty/' /etc/sudoers
sed -i 's/^Defaults    env_keep = "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR \\/Defaults    env_keep = "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR SSH_AUTH_SOCK \\/' /etc/sudoers

cat<<EOF >>/etc/sudoers

# jesonc using sudo
%jesonc        ALL=(ALL)       NOPASSWD: ALL

EOF

###
# Change Intel P-state
###
sed -i '/GRUB_CMDLINE_LINUX/{s/"$//g;s/$/ intel_pstate=disable intel_idle.max_cstate=0 processor.max_cstate=1 idle=poll"/}' /etc/default/grub



###
#Bash Aliases
###
cat > /etc/profile.d/Je.sh <<EOF
alias ls='ls -hAF --color=auto --time-style=long-iso'
alias ll='ls -l'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ds='ds -h'
alias df='df -h'
alias grep='egrep --color'

EOF

chmod 775 /etc/profile.d/Je.sh

###
# Public key
###
mkdir /root/.ssh
pub_key='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA4mvukv4f5seBuzrCnCCm1DpSgYw/kvq+XgsUP8mnzUpyaQ6D8BKfbOn6T20tUU/ksiJwSuUQHfw5v9JsnBACto3o/RmId0Ltn4DCq19sSwMP3YJb9dRb8SA/Pc5Xl7MPwPoSYyuY20ztMfo1GBx5N9dDuQ3j1MdKYTY9SdfFwPr0ZQvesKT1ozfQ9HHrcUi1CLJw+irYW9+jU39CsMrrZmCjb/n53gP77Do0lj9TkqXK2SYNdA88cmK2IQJP3LfFWWrwYH01FkImZbt7ODDQ21BqGccLY7xCbsNaniBlT8Mpy4/Wlg1qqnNPxBbw1nrs9A+2MnAfGDHXYhkFC/n6wQ== root@linux.jesonc.net'
echo $pub_key >> /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
chown -R root:root /root/.ssh

###
# Sysctl config
###
found=`grep -c net.ipv4.tcp_tw_recycle /etc/sysctl.conf`
if ! [ $found -gt "0" ]
then
cat > /etc/sysctl.conf << EOF
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
fs.file-max = 131072
kernel.panic=1
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_no_metrics_save = 1
net.core.netdev_max_backlog = 3072
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_max_tw_buckets = 720000
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_fin_timeout = 5
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_retries1 = 2
net.ipv4.tcp_retries2 = 10
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_syncookies = 1
EOF
fi

sysctl -p

###
# Max open files
###
found=`grep -c "^* soft nproc" /etc/security/limits.conf`
if ! [ $found -gt "0" ]
then
cat >> /etc/security/limits.conf << EOF
* soft nproc 2048
* hard nproc 16384
* soft nofile 8192
* hard nofile 65536
EOF
fi

###
# ssh config
###
/bin/sed -i 's/.*Port[[:space:]].*$/Port 9922/' /etc/ssh/ssh_config
/bin/sed -i 's/.*Port[[:space:]].*$/Port 9922/' /etc/ssh/sshd_config
/bin/sed -i 's/port=\"22\"/port=\"9922\"/' /usr/lib/firewalld/services/ssh.xml
firewall-cmd --reload

###
# Command History
###
found=`grep -c HISTTIMEFORMAT /etc/profile`
if ! [ $found -gt "0" ]
then
echo "export HISTSIZE=2000" >> /etc/profile
echo "export HISTTIMEFORMAT='%F %T:'" >> /etc/profile
fi

###
# Auto configure IP
###

#wget http://linux.jesonc.net/script/autoip.sh
#wget http://linux.jesonc.net/script/autoip7_2.sh
cd ${WORK_DIR}
sh ./autoconfigip.sh

###
# Configure yum repository
###
#cat > /etc/yum.repos.d/Jjesonc.repo << EOF
#-----------------
#Add by Jeson(jeson@imoocc.com)
#released base
#[c6] #repair
#name=CentOS Linux 6x - \$basearch #repair
#baseurl=http://linux.jesonc.net/linux/centos/6/os/x86_64/  #repair
#enabled=1
#gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6  #repair

#[c6-update]  #repair
#name=CentOS Linux 6x - \$basearch - security updates #repair
#baseurl=http://linux.jesonc.net/linux/centos/\$releasever/updates/\$basearch/
#enabled=1
#gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6 #repair

#[c6-extras]  #repair
#name=CentOS-\$releasever - Extras
#baseurl=http://linux.jesonc.net/linux/centos/\$releasever/extras/\$basearch/
#enabled=1
#gpgcheck=0
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6   #repair
#EOF
