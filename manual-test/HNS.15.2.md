---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是网口MTU修改。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-20
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
  1.下发命令修改网口的MTU值：ifconfig ethx mtu xxx
  2.查询修改后网口的MTU值是否与修改的一致：ifconfig ethx
  3.MTU修改后、网口功能正常
```

# Expected Result
```
  1.可以正常修改网口MTU值
  2.修改后查询网口MTU值与修改的一致
  3.修改后网口能正常通信
```
