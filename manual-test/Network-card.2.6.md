---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡驱动自测试。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-08
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
  1.执行ethtool -t ethX命令，遍历所有网口，反复执行10次，查看测试结果，有结果A) 
  2.验证SUT端所有网口连通性
```

# Expected Result
```bash
  A) 驱动自测试均PASS
  B) 反复自测试后，网卡仍保持正常通讯
```
