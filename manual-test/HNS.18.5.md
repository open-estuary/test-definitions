---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是业务网口中断聚合设置功能入参错误

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
  1. 多次输入命令：ethtool -C ethx rx-frames 1024 tx-frames 1024，返回错误
  2. 多次输入命令：ethtool -C ethx rx-frames 0 tx-frames 0，返回错误
```

# Expected Result
```
  打印相应错误信息
```
