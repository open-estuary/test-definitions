---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是网口容错查询测试。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-10
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.单板启动正常
  2.所有网口各模块加载正常
```

# Test Procedure
```bash
  1.网口正常初始化后，使用命令“ethtool 网口名”查询设备网口
  2.使用命令查询不存在设备名（ethx）和空设备名的信息
```

# Expected Result
```bash
  1.设备存在的网口打印网口基本配置信息，不存在的网口提示不存在或者返回错误
```
