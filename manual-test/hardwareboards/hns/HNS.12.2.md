---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE电口关闭自协商后重新自协商功能。

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
```bash
  1.网口正常初始化后，使用ethtool命令先关闭自协商，再分别设置为10M 半双工、10M 全双工、100M 半双工、100M 全双工，命令执行成功
  2.ping对端成功
  3.输入重新自协商命令，ping对端成功
```

# Expected Result
```bash
  重新自协商命令执行成功，ping包成功
```
