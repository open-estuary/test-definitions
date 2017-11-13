---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE电口自协商模式设置。

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
  1.网口up后，使用ethtool命令关闭自协商模式
  2.使用ethtool命令查询基本配置，确认步骤一设置成功
```

# Expected Result
```bash
  自协商模式设置成功、查询到正确的工作模式
```
