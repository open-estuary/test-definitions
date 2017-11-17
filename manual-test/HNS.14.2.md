---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是网口Mac地址设置容错测试。

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
  1.网口正常初始化后，调用命令“ifconfig ethx hw ether xx:xx:xx:xx:xx:xx”，配置非法MAC地址（包括全0，全F，多播广播，大于48bit，小于48bit）
  2.网口正常初始化后，调用命令“ifconfig 网口名 hw ether xx:xx:xx:xx:xx:xx”，配置设备不存在网口的MAC地址
```

# Expected Result
```
  1.非法MAC设置不成功，MAC地址如果不足48bit，会自动加零，如果超过48bit，会自动截断
  2.配置设备不存在网口mac地址，系统提示无此设备
```
