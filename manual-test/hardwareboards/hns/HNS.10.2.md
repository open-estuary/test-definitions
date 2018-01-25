---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE网口标准统计数据获取容错测试。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-13
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
  1.网口正常初始化后，输入命令：ifconfig ethx查询
  2.查询不存在设备名（eth8）和空设备名的标准统计数据
```

# Expected Result
```bash
  1.设备存在的网口能正确打印标准统计数据
  2.eth8提示设备不存在
```
