---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是MTU容错测试。

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
  1.修改网口MTU为小于68的值、系统提示不可设置、查询MTU还是修改前的值
  2.修改网口MTU为大于9710的值、系统提示不可设置、查询MTU还是修改前的值
  3.修改网口MTU为非数字的值、系统提示不可设置、查询MTU还是修改前的值
```

# Expected Result
```
  范围外的值与非数字MTU值都不可配置
```
