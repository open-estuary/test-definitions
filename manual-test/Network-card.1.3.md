---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例是为了验证82599网卡的网口是否正常添加。

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
  1.将网卡插入到服务器的pcie卡槽上
  2.服务器上电、查看服务器是否添加网卡的网口：ip addr
```

# Expected Result
```bash
  1.服务器能识别网卡
  2.网卡上的网口添加正确
```
