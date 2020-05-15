# httpd的https

- CA Server上创建私钥, 自签证书

```sh
cd /etc/pki/CA/
(umask 077;openssl genrsa -out private/cakey.pem 2048)

openssl req -new -x509 -key private/cakey.pem -out cacert.pem -days 365
# You are about to be asked to enter information that will be incorporated
# into your certificate request.
# What you are about to enter is what is called a Distinguished Name or a DN.
# There are quite a few fields but you can leave some blank
# For some fields there will be a default value,
# If you enter '.', the field will be left blank.
# -----
# Country Name (2 letter code) [XX]:CN
# State or Province Name (full name) []:Beijing
# Locality Name (eg, city) [Default City]:Beijing
# Organization Name (eg, company) [Default Company Ltd]:zhejian
# Organizational Unit Name (eg, section) []:devops
# Common Name (eg, your name or your server's hostname) []:ca.zhejian.com
# Email Address []:
```

- httpd创建私钥, 证书签发请求

```sh
mkdir -pv /etc/httpd/ssl
cd /etc/httpd/ssl
(umask 077; openssl genrsa -out httpd_key.pem 1024)

openssl req -new -key httpd_key.pem -out httpd_csr.pem

# You are about to be asked to enter information that will be incorporated
# into your certificate request.
# What you are about to enter is what is called a Distinguished Name or a DN.
# There are quite a few fields but you can leave some blank
# For some fields there will be a default value,
# If you enter '.', the field will be left blank.
# -----
# Country Name (2 letter code) [XX]:CN
# State or Province Name (full name) []:Beijing
# Locality Name (eg, city) [Default City]:Beijing
# Organization Name (eg, company) [Default Company Ltd]:zhejian
# Organizational Unit Name (eg, section) []:devops
# Common Name (eg, your name or your server's hostname) []:www.zhejian.com
# Email Address []:
# Please enter the following 'extra' attributes
# to be sent with your certificate request
# A challenge password []:
# An optional company name []:

```

- 将httpd服务器上的签发请求, 在CA服务器上对其签发

```sh
# 准备签发文件
touch index.txt; echo "01" >> serial

# 签发证书
openssl ca -in /tmp/httpd_csr.pem -out certs/httpd_crt.pem
# Using configuration from /etc/pki/tls/openssl.cnf
# Check that the request matches the signature
# Signature ok
# Certificate Details:
#         Serial Number: 1 (0x1)
#         Validity
#             Not Before: May 15 04:08:00 2020 GMT
#             Not After : May 15 04:08:00 2021 GMT
#         Subject:
#             countryName               = CN
#             stateOrProvinceName       = Beijing
#             organizationName          = zhejian
#             organizationalUnitName    = devops
#             commonName                = www.zhejian.com
#         X509v3 extensions:
#             X509v3 Basic Constraints:
#                 CA:FALSE
#             Netscape Comment:
#                 OpenSSL Generated Certificate
#             X509v3 Subject Key Identifier:
#                 BD:9E:A3:9F:4B:F3:8F:A6:C8:0D:B7:BD:52:DA:DA:B1:D2:2B:96:AE
#             X509v3 Authority Key Identifier:
#                 keyid:1D:AB:32:E5:C8:E9:2C:80:A9:66:2C:5A:54:17:6C:94:00:82:F4:7D

# Certificate is to be certified until May 15 04:08:00 2021 GMT (365 days)
# Sign the certificate? [y/n]:y


# 1 out of 1 certificate requests certified, commit? [y/n]y
# Write out database with 1 new entries
# Data Base Updated
```

- httpd的配置中, 指定证书和私钥

```
SSLCertificateFile /etc/httpd/ssl/httpd_crt.pem
SSLCertificateKeyFile /etc/httpd/ssl/httpd_key.pem
```

- 在客户端请求

```sh
openssl s_client -connect www.zhejian.com:443 -CAfile /tmp/cacert.pem
# CONNECTED(00000003)
# depth=1 C = CN, ST = Beijing, L = Beijing, O = zhejian, OU = devops, CN = ca.zhejian.com
# verify return:1
# depth=0 C = CN, ST = Beijing, O = zhejian, OU = devops, CN = www.zhejian.com
# verify return:1
# ---
# Certificate chain
#  0 s:/C=CN/ST=Beijing/O=zhejian/OU=devops/CN=www.zhejian.com
#    i:/C=CN/ST=Beijing/L=Beijing/O=zhejian/OU=devops/CN=ca.zhejian.com
# ---
# Server certificate
# -----BEGIN CERTIFICATE-----
# MIIDOzCCAiOgAwIBAgIBATANBgkqhkiG9w0BAQUFADBtMQswCQYDVQQGEwJDTjEQ
# MA4GA1UECAwHQmVpamluZzEQMA4GA1UEBwwHQmVpamluZzEQMA4GA1UECgwHemhl
# amlhbjEPMA0GA1UECwwGZGV2b3BzMRcwFQYDVQQDDA5jYS56aGVqaWFuLmNvbTAe
# Fw0yMDA1MTUwNDA4MDBaFw0yMTA1MTUwNDA4MDBaMFwxCzAJBgNVBAYTAkNOMRAw
# DgYDVQQIDAdCZWlqaW5nMRAwDgYDVQQKDAd6aGVqaWFuMQ8wDQYDVQQLDAZkZXZv
# cHMxGDAWBgNVBAMMD3d3dy56aGVqaWFuLmNvbTCBnzANBgkqhkiG9w0BAQEFAAOB
# jQAwgYkCgYEA3H+hV9wsqQGGfPfBshhw0d+NjubAu/pgeFRItAFeC854TknUvTef
# HarXs6ULy5V9HPIEy3mcJpe5j8tyTYOrwqcidEMhpFR2255bxpBu8lfilFCH0brc
# sWz+NTm1Dp0svgyVAkqfSDzpB/kmhHNVhN4TKV6PEDk6RmFrCz501gcCAwEAAaN7
# MHkwCQYDVR0TBAIwADAsBglghkgBhvhCAQ0EHxYdT3BlblNTTCBHZW5lcmF0ZWQg
# Q2VydGlmaWNhdGUwHQYDVR0OBBYEFL2eo59L84+myA23vVLa2rHSK5auMB8GA1Ud
# IwQYMBaAFB2rMuXI6SyAqWYsWlQXbJQAgvR9MA0GCSqGSIb3DQEBBQUAA4IBAQDb
# 6fSDeKvYwlP9h83G2wlXvmSQ9iXBgEQ1Y46yTTxw/FbW+4rUrQ24NIHOpOx+wgT4
# qn35i22bXOG4Pfhx23w0+QJQSDlzUarRqEa3s1FsFMV3hf+OIiDwScSfqjBaQx0F
# lbdqU1F1i8Fmi7Hl4ch0BzKkFbWHgoobnPvXsGrIlBMDtC/rwdwSQYIPzihCZBtM
# P+lbK87OPTayP6Kwp74WWcu7Vho/u3NOYWc9IWVSQ+I31cqFblU2o/Ka9SYX68He
# 3VADD8MGXrQnZIho7LCj+nNss2MDFLpNT2r2XZCsCHUFoS0r2eBgxvY4W/ceUvgF
# jfp+L1NIHRhP8kARFZeb
# -----END CERTIFICATE-----
# subject=/C=CN/ST=Beijing/O=zhejian/OU=devops/CN=www.zhejian.com
# issuer=/C=CN/ST=Beijing/L=Beijing/O=zhejian/OU=devops/CN=ca.zhejian.com
# ---
# No client certificate CA names sent
# Peer signing digest: SHA512
# Server Temp Key: ECDH, P-256, 256 bits
# ---
# SSL handshake has read 1394 bytes and written 415 bytes
# ---
# New, TLSv1/SSLv3, Cipher is ECDHE-RSA-AES256-GCM-SHA384
# Server public key is 1024 bit
# Secure Renegotiation IS supported
# Compression: NONE
# Expansion: NONE
# No ALPN negotiated
# SSL-Session:
#     Protocol  : TLSv1.2
#     Cipher    : ECDHE-RSA-AES256-GCM-SHA384
#     Session-ID: A433768834AF448A634EF2D70D3AA26787B00C1607FE4C809CC8940CE28E1F73
#     Session-ID-ctx:
#     Master-Key: 9502CE5199217308806AB180DEA5A8BAB52CAB913B0E297EE55026509F1D7C292419A1ADD7A5655C4CA610FD824A045E
#     Key-Arg   : None
#     Krb5 Principal: None
#     PSK identity: None
#     PSK identity hint: None
#     TLS session ticket lifetime hint: 300 (seconds)
#     TLS session ticket:
#     0000 - 26 79 78 03 d8 85 dd ed-d8 f0 b6 61 a3 d2 72 90   &yx........a..r.
#     0010 - dd b9 19 42 f7 7f 07 15-d1 95 15 01 32 02 be 21   ...B........2..!
#     0020 - 58 13 52 23 4e fe f7 58-c2 c2 06 02 67 2f f8 77   X.R#N..X....g/.w
#     0030 - a6 b4 95 b3 f9 13 c8 da-61 bd 43 51 97 5a 56 84   ........a.CQ.ZV.
#     0040 - 5f 64 c7 26 85 2f 10 e6-bc e2 9f ff 82 9f 1e 9b   _d.&./..........
#     0050 - 32 65 82 21 5d cc 79 42-a7 54 06 98 9e c6 8f 0f   2e.!].yB.T......
#     0060 - 2c 60 68 04 bb d0 73 74-7e 32 70 d0 4c f9 68 04   ,`h...st~2p.L.h.
#     0070 - c7 bc 0e 0c 53 f7 1b 17-cf 6b 6d fa 95 06 ff 9b   ....S....km.....
#     0080 - 22 ef df 6a b1 f4 2f 28-a7 90 88 99 af 27 1b 73   "..j../(.....'.s
#     0090 - db 78 40 d2 74 2b e5 93-83 57 99 ea a0 5d bc 42   .x@.t+...W...].B
#     00a0 - 9d bd 4c 4a fe b8 08 ae-ce 11 5c c2 aa 64 17 59   ..LJ......\..d.Y
#     00b0 - bc 41 86 c3 cd aa 25 62-56 37 ef 9b de e6 f9 7a   .A....%bV7.....z

#     Start Time: 1589519539
#     Timeout   : 300 (sec)
#     Verify return code: 0 (ok)          # ok
# ---

curl -cert /tmp/cacert.pem -key /etc/httpd/ssl/httpd_key.pem https://www.zhejian.com/index.html

# <!DOCTYPE html>
# <html>
# <head>
#     <title>test page</title>
# </head>
# <body>
#     <h1>welcome</h1>
#     <center>this is test page</center>
# </body>
# </html>
```
