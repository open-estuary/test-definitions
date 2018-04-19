---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是XGE光口连接查询link状态。

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
  1.光纤连接，本端down，对端反复up down，查询到link down
  2.光纤连接，本端up，对端反复up down，查询到link状态与对端up down状态一致
  3.光纤连接，本端反复up down，对端反复up down，只有在两边同时up时查询到link up
  4.光纤连接，本端反复up down，对端未初始化，查询到link down
  5.光纤未连接，本端反复up down，查询到link down
  6.两端up，反复拔插光纤，插入光纤时查询到的link up，拔出光纤时查询到link down
  7.本端up，反复拔插光模块，查询到link down
  8.光驱连接，对端up，本端反复复位自协商，查询到link up
  9.光纤连接，对端down，本端反复复位自协商，查询到link down
```

# Expected Result
```bash
  链路连接状态查询结果正确
```
