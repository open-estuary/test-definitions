---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE电口连接查询link状态。

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
  1.网线连接，本端down，对端反复up down，查询到link down
  2.网线连接，本端up，对端反复up down，查询到link状态与对端up down状态一致
  3.网线连接，本端反复up down，对端反复up down，只有在两边同时up时查询到link up
  4.网线连接，本端反复up down，对端未初始化，查询到link down
  5.网线未连接，本端反复up down，查询到link down
  6.两端up，反复拔插网线，插入网线时查询到的link up，拔出网线时查询到link down
  7.网线连接，对端up，本端反复复位自协商，查询到link up
  8.网线连接，对端down，本端反复复位自协商，查询到link down
```

# Expected Result
```bash
  链路连接状态查询结果正确
```
