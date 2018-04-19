---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是MTU疲劳测试。

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
  1.设置网口MTU为68～9710间的任意值
  2.查询网口MTU值
  3.重复步骤1～2多次
```

# Expected Result
```
  1.每次查询MTU值都与修改的一致
  2.多次修改后、网口功能正常
```
