#-*- coding: UTF-8 -*-

'''
    要求已经安装了mininet，
    其会在两台主机上，创建基于VxLAN的tunnel。
'''

from mininet.log import setLogLevel
from mininet.net import Mininet
from mininet.cli import CLI
from mininet.log import info

def create_vxlan(remote_ip='0.0.0.0', e='1'):
    remote_ip = remote_ip.strip()
    h1_info = {
        'name':'h{}1'.format(e),
        'ip':'10.0.0.{}1'.format(e),
        'mac':'00:00:00:00:00:{}1'.format(e)
    }
    h2_info = {
        'name':'h{}2'.format(e),
        'ip':'10.0.0.{}2'.format(e),
        'mac':'00:00:00:00:00:{}2'.format(e)
    }

    net = Mininet()
    c0 = net.addController()
    s = net.addSwitch('s{}'.format(e))
    h1 = net.addHost(**h1_info)
    h2 = net.addHost(**h2_info)
    net.addLink(s, h1)
    net.addLink(s, h2)

    net.start()
    try:
        s.cmd('ovs-vsctl add-port s{} vx1 -- set interface vx1 type=vxlan options:remote_ip={}'.format(e, remote_ip))
        # add vxlan interface vx1
        h1.cmd('echo "1450" > /sys/class/net/h{}1-eth0/mtu'.format(e))
        h2.cmd('echo "1450" > /sys/class/net/h{}2-eth0/mtu'.format(e))
        # change mtu of test host interface
    except:
        info('\n*** Configuration failed.\n')
    else:
        info('\n*** Configuration is saved successfully.\n')

    CLI(net)
    net.stop()


if '__main__' == __name__:
    setLogLevel('info')
    flag = True
    while flag:
        ip = raw_input('Input the remote outbound IP address: ')
        c = raw_input('Input the DC number [1/2] : ')
        while True:
            yes = raw_input('Are these info correct {}, {}? [y/n] '.format(ip, c))
            if yes == 'y' or yes == 'Y':
                create_vxlan(ip, c)
                flag = False
                break
            elif yes == 'n' or yes == 'N':
                break
            elif yes == 'q' or yes == 'Q':
                flag = False
                break
            else:
                print 'press q for quit'
