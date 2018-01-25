---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE网口获取和设置Phy配置的容错测试。

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
  1.网口正常初始化后，使用ethtool -s命令分别设置速率为10M、100M、1000M、50M、500M
  2.使用ethtool命令查询基本配置，确认步骤1设置成功；
  3.使用ethtool -s命令关闭（eth3）和不存在设备名（eth4）和空设备名自协商模式；
  4.使用ethtool命令查询基本配置，确认步骤3设置成功；
  5.关闭两端自协商模式，再使用ethtool -s命令设置（eth3）和不存在设备名（eth4）和空设备名两端单双工模式；
  6.使用ethtool命令查询基本配置，确认步骤5设置成功；
  7.测试网络连通性
```

# Expected Result
```bash
  1.10M、100M、1000M速率设置成功、设置成功后网口能正常收发包；50M、500M设置不成功
  2.eth3自协商模式设置成功、设置成功后网口能正常收发包；eth4提示不存在或者返回错误
  3.eth3单双工模式设置成功、设置成功后网口能正常收发包；eth4提示不存在或者返回错误
```
