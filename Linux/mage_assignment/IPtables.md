# IPtables

## 3. IPtables状态
在IPtables上一共有四种状态，分别被称为NEW、ESTABLISHED、INVALID、RELATED，这四种状态对于TCP、UDP、ICMP三种协议均有效。

### 3.1 NEW
匹配的报文是某个连接的第一个报文。如TCP中的SYN包。

### 3.2 ESTABLISHED
已经匹配到两个方向上的数据传输，而且会继续匹配这个连接的包。

### 3.3 RELATED
当一个连接和某个已处于ESTABLISHED状态的连接有关系时，就被认为是RELATED的了。换句话说，一个连接要想是RELATED的，首先要有一个ESTABLISHED的连接。这个ESTABLISHED连接再产生一个主连接之外的连接，这个新的连接就是RELATED的了。如，FTP，FTP-data 连接就是和FTP-control有关联的。

* ICMP应答、FTP传输

### 3.4 INVALID
数据包不能被识别属于哪个连接或没有任何状态。有几个原因可以产生这种情况，比如，内存溢出，收到不知属于哪个连接的ICMP错误信息。一般地，我们DROP这个状态的任何东西。

## 4. 管理



* -S, --list-rules [chain]，查看规则



* service IPtables {restart | start | stop | status | save}
* IPtables-save > ip_tab.rules，保存策略
* IPtables-restore < ip_tab. rules，恢复策略
* service IPtables status查看其状态
