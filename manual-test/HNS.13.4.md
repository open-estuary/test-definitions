---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是业务网口收发队列数查询容错测试。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-16
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
  1.网口正常初始化后，输入命令：ethtool -l ethx查询（eth3）
  2.查询不存在设备名（eth8）和空设备名的收发队列数
```

# Expected Result
```
  1.eth3正确打印收发队列个数信息
  2.eth8提示不存在或者返回错误
```
