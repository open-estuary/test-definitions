---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是网口关键状态寄存器频繁查询

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-22
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 单板启动正常
  2. 所有网口各模块加载正常
```

# Test Procedure
```
  1. 多次查询网口信息：ethtool -d ethx
  2. 反复up、down网口，up、down的操作间隔5s，执行5次
  3. 停止测试，up网口，能够ping通
```

# Expected Result
```
  没有出现任何异常，停止测试后，网口能正常工作
```
