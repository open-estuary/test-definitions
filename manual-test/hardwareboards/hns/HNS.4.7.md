---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是XGE速率和自协商模式设置失败。

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
  1.网口正常初始化后，打开自协商模式，设置失败
  2.设置速率为1000M/100M/10M，设置失败
  3.使用ethtool命令查询基本配置，确认步骤1和2未设置成功
  4.网口up，重复执行步骤1-3
```

# Expected Result
```bash
  步骤1和2设置失败，打印相应错误信息
  步骤3查询到自协商关闭，速率为10000M
```
