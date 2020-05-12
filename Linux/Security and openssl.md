# Security and OpenSSL

## 安全通信概述

- 通信回顾：
    - 同一主机上的进程间通信：IPC， message queue, shm, semerphor
    - 不同主上的进程间通信：socket

- SSL: Secure Sockets Layer: http --> ssl --> https

- 安全的目标：
    - 保密性：confidentiality
    - 完整性：integrity
    - 可用性：availability

- 攻击类型：
    - 威胁保密性的攻击：窃听、通信量分析；
    - 威胁完整性的攻击：更改、伪装、重放、否认
    - 威胁可用性的攻击：拒绝服务（DoS）

- 解决方案：
    - 技术（加密和解密）
        - 传统加密方法：替代加密方法、置换加密方法
        - 现代加密方法：现代块加密方法
    - 服务（用于抵御攻击的服务，也即是为了上述安全目标而特地设计的安全服务）
        - 认证机制
        - 访问控制机制

- Linux系统实现安全的方案：OpenSSL(ssl)， GPG(pgp)

- OpenSSL由三部分组成：
    - libencrypto库
    - libssl库
    - openssl多用途命令行工具

- 密钥算法和协议
    - 对称加密：加密和解密使用同一个密钥；
        - DES：Data Encryption Standard;
        - 3DES：Triple DES;
        - AES：Advanced Encryption Standard;  (128bits, 192bits, 256bits, 384bits)
        - Blowfish, Twofish, IDEA, RC6, CAST5
        - 特性：
            - 1、加密、解密使用同一个密钥；
            - 2、将原始数据分割成为固定大小的块，逐个进行加密；
        - 缺陷：
            - 1、密钥过多；
            - 2、密钥分发困难；
    - 公钥加密：密钥分为公钥与私钥
        - 公钥：从私钥中提取产生；可公开给所有人；pubkey
        - 私钥：通过工具创建，使用者自己留存，必须保证其私密性；private key；
        - 特点：用公钥加密的数据，只能使用与之配对儿的私钥解密；反之亦然；
        - 用途：
            - 数字签名：主要在于让接收方确认发送方的身份；
            - 密钥交换：发送方用对方公钥加密一个对称密钥，并发送给对方；
            - 数据加密（不常用，比对称加密要慢3个数量级）
        - 算法：RSA，DSA，ELGamal
            - RSA: 可以实现签名和加解密
            - DSS: Digital Signature Standard
            - DSA：Digital Signature Algorithm, 仅能实现签名，不能加解密
    - 单向加密：即提出数据指纹；只能加密，不能解密；摘要
        - 特性：定长输出、雪崩效应；
        - 功能：完整性；
        - 算法：
            - md5：Message Digest 5, 128bits
            - sha1：Secure Hash Algorithm 1, 160bits
            - sha224, sha256, sha384, sha512
    - 密钥交换： IKE（Internet Key Exchange），其实现方法有：
        - 公钥加密：RSA
        - DH（Deffie-Hellman）：AB双方生成明文的大素数: p, g；并且AB双方自己产生x, y; 即：
            - A有: p, g, x
            - B有: p, g, y
            - A将p^x%g发送给B
            - B将p^y%g发送给A
            - A得到(p^y%g)^x=p^(yx)%g，B得到(p^x%g)^y=p^(xy)%g，即AB得到相同的值
        - ECDH（椭圆曲线DH）
        - ECDHE（临时椭圆曲线DH）

- PKI：Public Key Infrastructure
    - 包含内同：
        - 签证机构：CA
        - 注册机构：RA
        - 证书吊销列表：CRL
        - 证书存取库：
    - X.509v3：定义了证书的结构以及认证协议标准：版本号，序列号，签名算法ID，发行者名称，有效期限，主体名称，主体公钥，发行者的惟一标识，主体的惟一标识，扩展，发行者的签名

- SSL：Secure sockets Layer
    - Netscape: 1994
    - V1.0, V2.0, V3.0
    - SSL会话主要三步
        - 客户端向服务器端索要并验正证书；
        - 双方协商生成“会话密钥”；
        - 双方采用“会话密钥”进行加密通信；

![ssl.tls.handshake.process](https://github.com/Minions1128/net_tech_notes/blob/master/img/ssl.tls.handshake.process.png "ssl.tls.handshake.process")

- SSL Handshake Protocol：
    - 第一阶段：ClientHello：
        - 支持的协议版本，比如tls 1.2；
        - 客户端生成一个随机数，稍后用户生成“会话密钥”
        - 支持的加密算法，比如AES、3DES、RSA；
        - 支持的压缩算法；
    - 第二阶段：ServerHello
        - 确认使用的加密通信协议版本，比如tls 1.2；
        - 服务器端生成一个随机数，稍后用于生成“会话密钥”
        - 确认使用的加密方法；
        - 服务器证书；
    - 第三阶段：
        - 验正服务器证书，在确认无误后取出其公钥；（发证机构、证书完整性、证书持有者、证书有效期、吊销列表）
        - 发送以下信息给服务器端：
            - 一个随机数；
            - 编码变更通知，表示随后的信息都将用双方商定的加密方法和密钥发送；
            - 客户端握手结束通知；
    - 第四阶段：
        - 收到客户端发来的第三个随机数pre-master-key后，计算生成本次会话所有到的“会话密钥”；
        - 向客户端发送如下信息：
            - 编码变更通知，表示随后的信息都将用双方商定的加密方法和密钥发送；
            - 服务端握手结束通知；

- TLS: Transport Layer Security
    - IETF: 1999
    - V1.0, V1.1, V1.2, V1.3
    - 分层设计：
        - 1、最底层：基础算法原语的实现，aes, rsa, md5
        - 2、向上一层：各种算法的实现；
        - 3、再向上一层：组合算法实现的半成品；
        - 4、用各种组件拼装而成的各种成品密码学协议软件；

- 协议的开源实现：OpenSSL

## OpenSSL

- 众多子命令，分为三类，支持`?`查询：
    - Standard commands: enc, ca, req, genrsa, ...
    - Message Digest commands (see the 'dgst' command for more details)
    - Cipher commands (see the 'enc' command for more details)

- 对称加密：
    - 工具：openssl  enc,  gpg
    - 支持的算法：3des, aes, blowfish, towfish
    - enc命令：
        - 加密：`openssl enc -e -des3 -a -salt -in fstab.planetext -out fstab.ciphertext`
        - 解密：`openssl enc -d -des3 -a -salt -out fstab.planetext -in fstab.ciphertext`

- 单向加密：
    - 工具：openssl dgst, md5sum, sha1sum, sha224sum, ...
    - dgst命令：
        - `openssl dgst -md5 /PATH/TO/SOMEFILE`
        - 还可以：`md5sum /PATH/TO/SOMEFILE`
    - 生成用户密码：(工具：passwd, openssl passwd)
        - `openssl passwd -1 -salt SALT`
    - 生成随机数：(工具：openssl rand)
        - `openssl rand -hex NUM`
        - `openssl rand -base64 NUM`

- 公钥加密：
    - 加密解密：
        - 算法：RSA，ELGamal
        - 工具：openssl rsautl, gpg
    - 数字签名：
        - 算法：RSA，DSA，ELGamal
        - 工具：openssl rsautl, gpg
    - 密钥交换：
        - 算法：DH
    - 生成密钥：
        - 生成私钥：`(umask 077; openssl genrsa -out /PATH/TO/PRIVATE_KEY_FILE NUM_BITS)`
        - 提出公钥：`openssl rsa -in /PATH/FROM/PRIVATE_KEY_FILE -pubout`

- Linux系统上的随机数生成器：
    - /dev/random：仅从熵池返回随机数；随机数用尽，阻塞；
    - /dev/urandom：从熵池返回随机数；随机数用尽，会利用软件生成伪随机数（伪随机数不安全），非阻塞；
    - 熵池中随机数的来源：硬盘、键盘IO中断时间间隔；

## CA

- 公共信任的CA，私有CA；
- 建立私有CA：
    - openssl
    - OpenCA

- openssl命令配置文件：/etc/pki/tls/openssl.cnf

- 构建私有CA: 在确定配置为CA的服务上生成一个自签证书，并为CA提供所需要的目录及文件即可；步骤：
    - (1) 生成私钥: `(umask 077; openssl genrsa -out /etc/pki/CA/private/cakey.pem 4096)`
    - (2) 生成自签证书: `openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days 3655`
        - -new：生成新证书签署请求；
        - -x509：生成自签格式证书，专用于创建私有CA时；
        - -key：生成请求时用到的私有文件路径；
        - -out：生成的请求文件路径；如果自签操作将直接生成签署过的证书；
        - -days：证书的有效时长，单位是day；
    - (3) 为CA提供所需的目录及文件；
        - `mkdir -pv /etc/pki/CA/{certs,crl,newcerts}`
        - `touch /etc/pki/CA/{serial,index.txt}`
        - `echo 01 > /etc/pki/CA/serial`

- 要用到证书进行安全通信的服务器，需要向CA请求签署证书：步骤：（以httpd为例）
    - (1) 用到证书的主机生成私钥；
        - `mkdir /etc/httpd/ssl`
        - `cd /etc/httpd/ssl`
        - `(umask 077; openssl genrsa -out /etc/httpd/ssl/httpd.key 2048)`
    - (2) 生成证书签署请求
        - `openssl req -new -key /etc/httpd/ssl/httpd.key -out /etc/httpd/ssl/httpd.csr -days 365`
    - (3) 将请求通过可靠方式发送给CA主机；(例如，使用scp)
    - (4) 在CA主机上签署证书；
        - `openssl ca -in /tmp/httpd.csr -out /etc/pki/CA/certs/httpd.crt -days 365`
    - (5) 将证书信息发送给请求者
    - 查看证书中的信息：
        - `openssl x509 -in /etc/pki/CA/certs/httpd.crt -noout -serial -subject`

- 吊销证书步骤：
    - (1) 客户端获取要吊销的证书的serial（在使用证书的主机执行）
        - `openssl  x509  -in /etc/pki/CA/certs/httpd.crt  -noout  -serial  -subject`
    - (2) CA主机吊销证书
        - 先根据客户提交的serial和subject信息，对比其与本机数据库index.txt中存储的是否一致；
        - 吊销：`openssl  ca  -revoke  /etc/pki/CA/newcerts/SERIAL.pem`
        - 其中的SERIAL要换成证书真正的序列号；
    - (3) 生成吊销证书的吊销编号（第一次吊销证书时执行）
        - `echo  01  > /etc/pki/CA/crlnumber`
    - (4) 更新证书吊销列表
        - `openssl  ca  -gencrl  -out  thisca.crl`
    - 查看crl文件：
        - `openssl  crl  -in  /PATH/FROM/CRL_FILE.crl  -noout  -text`
