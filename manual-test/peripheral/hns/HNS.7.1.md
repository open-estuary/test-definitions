---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE光口收发数据灯（Active灯）工作状态。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-13
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
  1.ping对端，Active灯闪烁
  2.停止ping包，Active灯灭
  3.重复步骤1-2多次
```

# Expected Result
```bash
  Active灯状态与规格一致
```
