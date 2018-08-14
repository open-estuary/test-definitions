---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE光电转换口ping操作。

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
  3.正确配置ip地址
```

# Test Procedure
```bash
  1.单板与对端相连
  2.单板ping 对端
  3.对端ping 单板 
```

# Expected Result
```bash
  单板ping对端能ping通
  对端ping单板能ping通
```

