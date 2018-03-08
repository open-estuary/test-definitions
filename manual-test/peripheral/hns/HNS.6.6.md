---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是设置网口灯闪烁（link灯和active灯）。

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
  1.单板网口与对端相连
  2.输入命令ethtool -p ethx [n]
```

# Expected Result
```bash
  观察物理网口的link灯和active灯闪烁n秒
```
