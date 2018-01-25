---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是网口mac地址不随up/down而改变。

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
  1.检查随机生成的MAC地址
  2.网口up/down操作后，检查mac地址是否变化（地址不能变）
```

# Expected Result
```
  地址随机生成，网口up/down后mac地址保持不变
```
