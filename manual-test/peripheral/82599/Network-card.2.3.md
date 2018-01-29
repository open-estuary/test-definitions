---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡大文件传输测试。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-07
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.服务器1台且能正常启动系统
  2.82599网卡一块
```

# Test Procedure
```bash
  1.SUT端构建一个2048M的文件，计算md5值。
    dd if=/dev/zero of=testfile bs=1M count=2048
    md5sum testfile
  2.SUT端通过网口1把文件scp传输到Server端: scp  testfile root@[server ip]:/root/testfile1
  3.SUT端通过网口2把Server端文件scp传输回SUT端: scp root@[server ip]?: /root/testfile1 ./testfile2
  4.SUT端通过网口3把文件scp传输到Server端: scp testfile2 root@[server ip]:/root/testfile3
  5.SUT端通过网口4把Server端文件scp传输回SUT端: scp root@[server ip]?: /root/testfile3 ./testfile4
  6.计算testfile4的md5值与testfile的md5只进行比较，有结果A)
  7.重复以上操作3次
```

# Expected Result
```bash
  A) md5值相等
```
