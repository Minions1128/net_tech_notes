* 查看操作记录
```
sh logging configuration f
```
* 查看会话记录方法
1. 清除之前debug日志记录
```
clear logging debug
```
2. 定义debug条件
```
debug dp filter src-ip 1.1.1.1 src-port 1234 dst-ip 1.1.1.2 dst-port 23
debug dp filter src-ip 1.1.1.2 src-port 23 dst-ip 1.1.1.1 dst-port 1234
```
3. 开启debug
```
debug dp basic
debug dp snoop 
```
4. 执行会话操作，产生流量
5. 查看日志
```
sh logging debug
```
* [hillstone防火墙整理的入门命令](http://cache.baiducontent.com/c?m=9d78d513d9991af106acd2235141c0676943f0662ba6d2020fa4843c91732a44501695ac26520772d4d2081716de4b4b9d862173471450b08cb98e5ddccb8559259f5044676d875663d40eaebb5154c037e42bfede1af0cd8726d4ee8cdc851215884404099dedda0b5b43c96cfb033194f6c715404810cdea3334b9046029e8721de95afde4336e0584ebd75e4dc820d4&p=916c8e16d9c100fa01bd9b7e0d15c1&newp=882a9545d5d95ae612b6c7710f4e98231610db2151d7d6176b82c825d7331b001c3bbfb42324150ed7c07d6703ae4e5decf03773330123a3dda5c91d9fb4c57479923c7d3a47&user=baidu&fm=sc&query=hillstone%B7%C0%BB%F0%C7%BD%D5%FB%C0%ED%B5%C4%C8%EB%C3%C5%C3%FC%C1%EE&qid=9b636ad7000064f5&p1=2 "hillstone防火墙整理的入门命令")