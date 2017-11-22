---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是XGE光口关闭打开流控自协商

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-21
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
  1. 网口初始化后，设置本端流控自协商关闭：ethtool -A ethx autoneg off，提示错误
  2. 网口up，查询本端流控信息2次：ethtool -a ethx 
  3. 设置本端流控自协商打开，提示错误，查询本端流控信息2次
  4. 网口down，查询流控信息2次
```

# Expected Result
```
  1. 各个步骤查询到的流控使能信息正确
  2. XGE光口自协商默认off，不可修改
```
