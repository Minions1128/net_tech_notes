# Linux基础
## 1. 计算机的组成及其功能
计算机由运算器、控制器、存储器和I/O设备等部件组成
* **运算器**：对数据进行各种计算；
* **控制器**：整个计算机系统的控制中心，负责指挥计算机各部分协调地工作，保证计算机按照预先规定的目标和步骤有条不紊地进行操作及处理`现在计算机中，运算器和控制器共同集成在CPU中，除了这两个单元，CPU还有寄存器，其用来保存指令执行过程中临时存放的寄存器操作数和中间（或最终的操作结果）`
* **存储器**：功能是存储程序和各种数据信息，并能在计算机运行过程中高速、自动地完成程序或数据的存取，存储器是具有“记忆”功能的设备。根据计算机用途可分为主存储器（内存）和辅助存储器（外存）
 * **内存**：通常指主板上的存储部件，用来存放当前正在执行的数据和程序，但仅用于暂时存放，计算机关闭电源或断电，数据会丢失
 * **外存**：通常是磁性介质（磁盘、U盘）和光盘等，能长期保存信息
* **I/O**：设备即输入/输出设备，负责管理和控制计算机的所有输入/输出操作，主要分为字符设备和块设备，最常见的I/O设备有打印机、硬盘、键盘和鼠标

## 2. Linux的发行版
Debian、Slackware、RedHat，三个大的发行版都是属于类UNIX计算机操作系统
* Debian Project诞生于1993年8月13日，它的目标是提供一个稳定容错的Linux版本，Debian或者称Debian系列，包括Debian和Ubuntu等。Debian是社区类Linux的典范，是迄今为止最遵循GNU规范的Linux系统。Debian最早由Ian Murdock于1993年创建，分为三个版本分支（branch）： stable, testing和unstable；Debian的优点是遵循GNU规范，100%免费，优秀的网络和社区资源，强大的apt-get。
* Slackware Linux是由Patrick Volkerding开发的GNU/Linux发行版。与很多其他的发行版不同，它坚持KISS(Keep It Simple Stupid)的原则。它的最大特点就是安装灵活，目录结构严谨，版本力求稳定而非追新。Slackware的软件包都是通常的tgz(tar/gzip) 或者txz(xz) 格式文件再加上安装脚本。
* RedHat，应该称为Redhat系列，包括RHEL(Redhat Enterprise Linux，也就是所谓的Redhat Advance Server，收费版本)、Fedora Core(由原来的Redhat桌面版本发展而来，免费版本)、CentOS(RHEL的社区克隆版本，免费)。Redhat应该说是在国内使用人群最多的Linux版本，甚至有人将Redhat等同于Linux，而有些老鸟更是只用这一个版本的Linux。所以这个版本的特点就是使用人群数量大，资料非常多；Redhat系列的包管理方式采用的是基于RPM包的YUM包管理方式，包分发方式是编译好的二进制文件。稳定性方面RHEL和CentOS的稳定性非常好，适合于服务器使用，但是Fedora Core的稳定性较差，最好只用于桌面应用。

## 3. Linux的哲学思想
* 一切皆文件：把几乎所有的资源都抽象为文件，包括硬件设备，通信接口等
* 由众多功能单一的程序组成：一个程序只做一件事，并且做好。将众多小程序组合完成复杂任务
* 尽量避免跟用户交互：易于以编程的方式实现自动化任务
* 使用文本文件保存配置信息：便于用户对程序配置做出调整

## 4. 命令格式即简单命令介绍
### 4.1 简单命令格式
`COMMAND OPTIONS ARGUMENTS`
* COMMAND：命令名称
* OPTIONS：选项（调整命令的运行特性）；选项有短选项和长选项的区别，如果同一命令同时使用多个短选项，多数情况下可合并表示，长选项不能合并；有些选项可以带参数，此称为选项参数，而不是命令参数；短选项的参数用空格来分隔，长选项的参数用 “=” 来设置。
* ARGUMENTS：参数 （命令的作用对象：命令对什么生效），不同命令的参数格式不同；有些命令可同时带多个参数，多个参数之间以空格分隔。

### 4.2 简单命令介绍
* ifconfig：查看Linux网络信息的命令
* echo：回显命令
* tty命令：查看当前终端设备
* startx命令：启动X-window桌面环境
* export命令：用于将shell变量输出为环境变量，或者将shell函数输出为环境变量
* pwd命令：（printing working directory） 显示工作目录
* history命令：查看命令历史命令
* shutdown命令：关机命令
* poweroff命令：关机命令
* reboot命令：重启机器命令
* hwclock命令：与clock相同，查看硬件时钟
* date命令：查看系统时钟

## 5. Linux系统获取命令的帮助信息
* 内部命令使用帮助：`help COMMAND`
* 外部命令的使用帮助：`COMMAND --help`
* 使用man手册： manual：`man COMMAND`
* 命令的在线文档帮助：`info COMMAND`
* 自带帮助文档
  * README:程序的相关信息
  * INSTALL:安装帮助
  * CHANGES: 版本迭代的改动信息
* 主流发行版官方文档：http://www.redhat.com/doc
* MAN命令通过不同章节对命令进行分类
  * man1：用户可用命令（User Commands）
  * man2：使用函数库中程序可用的系统调用
  * man3：程序中可用的C库调用
  * man4：设备文件及特殊文件
  * man5：文件格式（配置文件格式）
  * man6：游戏使用帮助
  * man7：杂项
  * man8：管理工具及守护进程

## 终端的概念
* 物理终端：/dev/console
* 虚拟终端：/dev/tty#
  * 切换方式：ctrl-alt-F[1-6]
* 图形终端：
* 伪终端：/dev/pst/#

* 150Linux命令
![](https://github.com/Minions1128/net_tech_notes/blob/master/img/linux.150.cmd.jpg)