---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是业务网口pause帧流控配置和查询测试

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
  1. 调用“ethtool -a ethx”查询pause帧流控默认值
  2. 设置并查询结果
```

# Expected Result
```
  1. pause帧流控默认开启
  2. 查询结果与设置一致（XGE没有自协商）
```
