---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是设备网口多次up/down操作。

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
  1.打开各网口，正确配置ip，与对端进行ping操作
  2.关闭各网口，与对端进行ping操作
  3.多次重复步骤1和步骤2
```

# Expected Result
```bash
  打开网口后，能ping通对端
  关闭网口后，不能ping通对端
```
