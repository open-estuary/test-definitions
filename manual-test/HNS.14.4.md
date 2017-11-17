---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是网口mac地址与EBL查询的一致。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-17
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.单板启动正常
  2.所有网口各模块加载正常
```

# Test Procedure
```
  1.EBL下查询网口mac地址：showmac 0
  2.系统起来后查询网口mac地址：ifconfig ethx
  3.对比两个查询结果
```

# Expected Result
```
  MAC地址一样
```
