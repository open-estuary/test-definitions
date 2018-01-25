---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是MTU边界值。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-20
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.单板启动正常
  2.所有网口各模块加载正常
```

# Test Procedure
```
  1.下发命令修改网口MTU为最小值：ifconfig ethx mtu 68
  2.下发命令修改网口MTU为最小值：ifconfig ethx mtu 9710
  3.修改网口MTU值后、网口功能正常
```

# Expected Result
```
  1.可以配置MTU为最小值
  2.可以配置MTU为最大值
  3.修改MTU后网口还能正常通信
```
