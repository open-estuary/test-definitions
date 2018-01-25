---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡驱动信息测试。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-07
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.服务器1台且能正常启动系统
  2.82599网卡一块
```

# Test Procedure
```bash
  1.查询网卡驱动版本和Firmware信息：ethtool -i ethX
  2.比较所有网口查询出的驱动版本和Firmware信息是否相同，有结果A)
  3.反复执行以上步骤10次，有结果B)
```

# Expected Result
```bash
  A) 驱动版本和Firmware信息相同
  B) 驱动版本和Fireware在多次查询中相同，不会发生变化
```
