---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是25G光口标准统计数据获取功能和测试初始化详细统计数据查询。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-15
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
  1.输入"ifconfig ethx",获取标准统计数据
  2.网口初始化后，输入"ethtool -l ethx"，查询初始化统计数据
```

# Expected Result
```bash
  1.获得标准统计数据
  2.正确打印统计数据
```

