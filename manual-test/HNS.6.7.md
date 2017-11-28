---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是点灯容错测试。

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
  1.单板网口与对端相连
  2.输入命令ethtool -p ethx[n]，设置（eth3）和不存在设备名（eth4）和空设备名点灯测试
```

# Expected Result
```bash
  1.物理网口eth3的link灯和active灯间隔n秒闪烁
  2.eth4提示不存在
```
