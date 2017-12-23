---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是网口中断聚合设置和查询容错测试

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
  1. 调用“ethtool -c ethx（查询命令）”、“ethtool -C ethx（配置命令）”，输入错误的网口名（如eth10），或者空，观察返回情况
```

# Expected Result
```
  系统提示无此设备
```
