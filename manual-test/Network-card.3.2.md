---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡PXE轮询测试

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-09
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
  1.将PXE服务器关闭
  2.BIOS启动项只保留PXE
  3.单板上电，PXE找不到PXE服务器弹出BIOS setup登录验证框
  4.开启GE接口的PXE服务器，登录BIOS setup直接退出，有结果A)
  5.开启PXE服务器，断开板载网口物理连接
  6.单板上电，PXE找不到PXE服务器弹出BIOS setup登录验证框
  7.将板载网口连接到PXE环境网络
  8.登录BIOS setup直接退出，有结果A)
```

# Expected Result
```bash
  A) PXE能正常启动
```
