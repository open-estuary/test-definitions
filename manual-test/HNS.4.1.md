---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE电口速率和双工模式设置。

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
  1.网口up后，使用ethtool命令先关闭自协商，再分别设置为10M 半双工、10M 全双工、100M 半双工、100M 全双工、1000M 全双工，命令执行成功
  2.设置为1000M 半双工，命令返回不支持此模式
  3.使用ethtool命令查询基本配置，确认设置成功
```

# Expected Result
```bash
  速率设置成功，查询到正确的速率
```
