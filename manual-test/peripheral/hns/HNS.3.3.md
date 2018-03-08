---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是反复开关网口并查询网口信息。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-10
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.单板启动正常
  2.所有网口各模块加载正常
```

# Test Procedure
```bash
  1.反复up、down网口，up、down的操作间隔5s，执行半小时
  2.在网口up/down的同时查询网口基本配置信息
  3.停止测试，up网口，能够ping通
  4.遍历设备上各类型的网口
```

# Expected Result
```bash
  操作过程无异常，网口up后能正常工作
```
