---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是XGE双工模式设置功能。

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
  1.网口up后，关闭自协商模式，再设置为单工模式，设置出错，设置为双工模式，设置成功
  2.使用ethtool命令查询基本配置，确认步骤一设置成功
```

# Expected Result
```bash
  双工模式设置成功、设置成功后网口能正常收发包
```
