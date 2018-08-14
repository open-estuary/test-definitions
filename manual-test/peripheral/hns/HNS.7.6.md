---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是25G光口收发数据灯（Active灯）工作状态。

Hardware platform: D06  
Software Platform: CentOS Ubuntu Debian 
Author: Xue Xing <xuexing4@hisilicon.com>  
Date: 2018-07-30
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.单板启动正常
  2.所有网口各模块加载正常
  3.正确配置网口ip
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

