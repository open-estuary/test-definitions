---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是业务网口中断聚合查询功能正确

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-22
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 单板启动正常
  2. 所有网口各模块加载正常
```

# Test Procedure
```
  1. 网口正常初始化后，多次查询中断聚合参数：ethtool -d ethx
  2. 网口up，多次查询中断聚合参数
```

# Expected Result
```
  正确打印水线和超时时间
```
