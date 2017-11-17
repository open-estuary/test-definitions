---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是网口Mac地址设置功能测试。

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
```
  1.网口正常初始化后，调用命令“ifconfig ethx hw ether xx:xx:xx:xx:xx:xx”，配置新的MAC地址
  2.配置mac地址后查询（ifconfig ethx）、结果与配置的一致
```

# Expected Result
```
  可以配置网口MAC地址
```
