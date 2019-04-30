- 压缩工具
    - (压缩)/(解压),         文件名后缀
    - compress/uncompress,  .Z
    - gzip/gunzip,          .gz
    - bzip2/bunzip2,        .bz2
    - xz/unxz,              .xz
    - lzma/unlzma,          .lzma
    - zip/unzip
    - tar, cpio

- gzip/gunzip/zcat
    - gzip, gunzip, zcat - compress or expand files
    - gzip  [OPTION]...  FILE... 直接压缩文件，删除源文件，只保留压缩文件，解压后的文件为源文件名.gz
        -d：解压缩，相当于gunzip；
        -#：指定压缩比，默认是6；数字越大压缩比越大（1-9）；
        -c：将压缩结果输出至标准输出；
            - `gzip -c FILE > /PATH/TO/SOMEFILE.gz`压缩后，保留源文件
    - gunzip: 解压文件，删除压缩文件，保留解压后的文件
    - zcat: 查看压缩文件

- bzip2/bunzip2/bzcat
    - bzip2, bunzip2 - a block-sorting file compressor, v1.0.6
    - bzip2  [OPTION]...  FILE...
        -d：解压缩
        -#：指定压缩比；默认是6；数字越大压缩比越大（1-9）；
        -k：keep，保留原文件；
    - bunzip2: 解压文件
    - bacat：查看压缩文件

- xz/unxz/xzcat
    - xz, unxz, xzcat, lzma, unlzma, lzcat - Compress or decompress .xz and .lzma files
    - xz  [OPTION]...  FILE...，默认会删除源文件，只保留压缩文件
        -d：解压缩
        -#：指定压缩比；默认是6；数字越大压缩比越大（1-9）；
        -k：保留原文件；

- tar命令：归档
    - tar  [OPTION]...  FILE...
    - (1) 创建归档
        - `-c -f /PATH/TO/SOMEFILE.tar FILE...`
        - `-cf /PATH/TO/SOMEFILE.tar FILE... `
    - (2) 展开归档
        - `-x -f /PATH/FROM/SOMEFILE.tar`
        - `-xf /PATH/FROM/SOMEFILE.tar -C /PATH/TO/SOMEDIR`
    - (3) 查看归档文件的文件列表
        - `-tf /PATH/TO/SOMEFILE.tar`
    - 归档完成后通常需要压缩，结果此前的压缩工具，就能实现压缩多个文件了；
    - (4) 归档压缩
            -z：gzip2
                -zcf   /PATH/TO/SOMEFILE.tar.gz  FILE...
                解压缩并展开归档：-zxf  /PATH/TO/SOMEFILE.tar.gz
                
            -j：bzip2
                -jcf
                -jxf
                
            -J: xz
                -Jcf
                -Jxf

zip：
    zip/unzip
        后缀名：.zip
        
练习：下载redis-3.0.2.tar.gz，展开至/tmp目录；而后得新创建压缩为xz格式；
    lftp  172.16.0.1/pub/Sources/sources/redis
    lftp> mget redis-3.0.2.tar.gz
