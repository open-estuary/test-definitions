---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡长时间收发包测试。

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
  1.SUT端网口不断ping Server端网口，这个过程中过程中包长逐步递增
    ping –c 10  –s  0  [Server IP]
    ping –c 10  –s  256  [Server IP]
    ping –c 10  –s  512  [Server IP]
    ping –c 10  –s  777  [Server IP]
    ping –c 10  –s  1024  [Server IP]
    ping –c 10  –s  2048 [Server IP]
    ping –c 10  –s  3478  [Server IP]
    ping –c 10  –s  6800  [Server IP]
    ping –c 10  –s  8972  [Server IP]
    ping –c 10  –s  8973  [Server IP]
    ping –c 10  –s  9000  [Server IP]
  2.修改SUT和Server网卡MTU为9000: ifconfig HiNICX mtu 9000
  3.SUT不断ping Server端网口，过程中包长逐步递增
    ping –c 10  –s  8972  [Server IP]
    ping –c 10  –s  9000  [Server IP]
    ping –c 10  –s  10000  [Server IP]
    ping –c 10  –s  20000  [Server IP]
    ping –c 10  –s  50000  [Server IP]
    ping –c 10  –s  60000 [Server IP]
    ping –c 10  –s  65507  [Server IP]
  4.SUT端所有网卡遍历以上测试
```

# Expected Result
```bash
  ifconfig查看，ping包过程中没有丢包和错包
```
