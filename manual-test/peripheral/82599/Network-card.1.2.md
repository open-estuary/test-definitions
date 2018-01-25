---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡安装测试。

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
  1.将82599网卡插入服务器PCIE卡槽
  2.服务器上电、查看系统是否可以检测到82599网卡：lspci
  3.重复上述步骤、遍历服务器的PCIE卡槽
```

# Expected Result
```bash
  1.能正常插入服务器的PCIE卡槽
  2.服务器上电后能正常检测到网卡
  3.遍历服务器PCIE卡槽、均无异常
```
