---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是ping包，业务网口TSO设置查询测试

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
  1. 调用命令“ethtool -k ethx”查询当前的TSO设置并ping对端
  2. 调用命令“ethtool -K ethx tso on/off”修改TSO设置，查询后ping对端
  3. 遍历所有网口
```

# Expected Result
```
  1. TSO默认开启
  2. 查询的结果与设置的一致
  3. ping包正常
```
