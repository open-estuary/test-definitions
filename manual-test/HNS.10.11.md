---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是接入小网后网口标准统计查询。

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
  1.网口正常初始化后，接入小网，等待10分钟
  2.调用标准统计接口查询(ethtool ethx)
```

# Expected Result
```
  正确打印标准统计，底层没有丢包和错包（通过详细统计确认）
```
