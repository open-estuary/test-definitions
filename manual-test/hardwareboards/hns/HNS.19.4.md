---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是业务网口GRO设置查询测试

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
  1. 调用命令“ethtool -k ethx”查询当前的GRO设置
  2. 调用命令“ethtool -K ethx gro on/off”修改GRO设置，并查询
  3. 遍历所有网口
```

# Expected Result
```
  1. 查询结果与设置一致
```
