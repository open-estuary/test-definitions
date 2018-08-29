---
lmbench.md - Lmbench是一套微型测评工具，一般来说，它衡量两个关键特征：反应时间和带宽。
Hardware platform: D05 D06
Software Platform: CentOS Ubuntu Debian
Author: dingyu <1136920311@qq.com>
Date: 2018-08-15 15:38:05
Categories: Estuary Documents
Remark:
---
#命令说明
```
       -i # 用来指定测试内容.
       0=write/rewrite
       1=read/re-read
       2=random-read/write
       3=Read-backwards
       4=Re-write-record
       5=stride-read
       6=fwrite/re-fwrite
       7=fread/Re-fread,
       8=random mix
       9=pwrite/Re-pwrite
       10=pread/Re-pread
       11=pwritev/Re-pwritev,
       12=preadv/Re-preadv
```
#选项
---
　　　　　　　-R 产生execl格式的输出日志。

              -b 将产生二进制的execl的日志文件名。

              -s 测试的文件大小。

              -q 指定最大文件块大小（这里的 -q 64k 包括了4K,8K,16K,32K,64K）

              -r 指测试的文件块大小（与-q有别，-r 64k只进行64k的测试）

              -a 在希望的文件系统上测试，不过只有
a的话会进行全面测试，要花费很长时间，最好用-i指定测试范围。

             -g 指定最大测试文件大小。

             -n 指定最小测试文件大小。

             -f 指定测试文件的名字，完成后会自动删除（这个文件必须指定在你要测试的那个硬盘中）

             -C 显示每个节点的吞吐量。

             -c 测试包括文件的关闭时间

---
# Test
```bash
     (1)安装所需要的安装包
       centos:
　　　   yum install make gcc -y
       ubuntu|debian
         apt-get install make gcc -y
     (2)下载iozone安装包
　　　  $wget http://www.iozone.org/src/current/iozone-3-434.src.rpm
　　　  rpm -ivh iozone-3-434.src.rpm
　　　  cd ~/rpmbuild/SOURCES
     (3)解压iozone3
        tar -xvf iozone3_434.tar
        cd iozone3_434/
        cd ./src/
        cd current/

     (4)编译
        make linux-AMD64

     (5)最简单开始使用iozone方法是自动模式
        $./iozone -a
                                                            random        random    bkwd   record   stride
              KB  reclen   write rewrite    read    reread    read   write    read  rewrite     read   fwrite frewrite   fread  freread
              64       4  496362  939223  2772930  2923952 1828508 1017549 1392258  1143223  1768283   533875   653436 1679761  2203800
              64       8  913649 1421755  4274062  4564786 3022727 1562436 1933893  1690338  2467108   799377  1357066 2467108  3203069
              64      16 1083249 1734015  5389653  6421025 4274062 2052169 2379626  2379626  3363612  1101022  1734015 3057153  4018152
              64      32 1183548 1879725  6421025  7940539 4988978 2278628 2278628  2772930  3588436  1452528  2298136 3057153  3588436

　  (6)iozone将测试结果放在Excel中
      $./iozone -Ra output.xls
                                                            random  random    bkwd   record   stride
              KB  reclen   write rewrite    read    reread    read   write    read  rewrite     read   fwrite frewrite   fread  freread
              64       4  503814  901377  2772930  3057153 1933893 1029254 1452528  1124074  1879725   603489  1017549 1599680  1828508
              64       8  780776 1310683  4018152  4564786 2772930 1452528 1562436  1452528  2467108   952555  1484662 2006158  2772930
              64      16  874936 1304314  4897948  6421025 3958892 1947927 1562436  2203800  3022727  1204796  2006158 2379626  4274062
              64      32 1143223 1734015  6421025  7100397 2923952 2379626 2561267  2772930  3165299  1599680  2801873 2203800  4207076

　  (7)8进程文件性能测试

      $./iozone –s 128k –i 0 –i 1 –i 2 –i 3 –i 4 –i 5 –i 8 –t 8 –r 1m –S 2048 –G –o –B > test-128k-8-g.txt

    (8)64进程文件性能测试：

     $./iozone –s 128k –i 0 –i 1 –i 2 –i 3 –i 4 –i 5 –i 8 –t 64 –r 1m –S 2048 –G –o –B > test-128k-64-g.txt

　　(9)128进程文件性能测试：

    $./iozone –s 128k –i 0 –i 1 –i 2 –i 3 –i 4 –i 5 –i 8 –t 128 –r 1m –S 2048 –G –o –B > test-128k-128-g.txt

    (10)进行全面测试.最小测试文件为512M直到测试到4G.测试read,write,和    Strided Rea测试的地方在mnt下,生成Excel的文件.

   $./iozone -a -n 512m -g 4g -i 0 -i 1 -i 5 -f /mnt/iozone -Rb ./iozone.xls

   (11)卸载安装包
　　centos:       yum remove gcc make -y
    ubuntu|debian:yum remove make

   (12)关闭iozone进程
    pkill iozone
```
