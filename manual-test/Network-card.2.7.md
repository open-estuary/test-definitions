---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡MAC地址查询测试。

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
  1.进入BIOS setup，在PXE配置界面查询板载网卡MAC地址
  2.单板上电，进入系统后，通过ifconfig 查询网卡MAC地址信息，有结果A)
```

# Expected Result
```bash
  A) 网卡MAC地址信息正确，和BIOS setup查询一致
```
