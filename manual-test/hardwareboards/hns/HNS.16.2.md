---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE光口流控使能查询。

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
  1.网口初始化后，查询流控信息2次：ethtool -a ethx
  2.网口up，查询流控信息2次：ethtool -a ethx
  3.网口down，查询流控信息2次：ethtool -a ethx
  4.重复步骤2～3多次
```

# Expected Result
```
  每个步骤查询到的流控tx、rx默认使能，流控自协商默认打开
```
