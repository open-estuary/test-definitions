---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡网口序号一致性测试。

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
  1.确认单板上板载网口序号
  2.进入OS，输入命令“ifconfig -a”查看网卡在系统下的标识，有结果A)
  3.使用ifconfig ethX up依次把网口up，ethtool ethX 确认所有网口均为“link”状态,有结果B)
  4.按顺序依次断开网卡物理网口连接，每次断开一个网口后，均进入系统通过ethtool查看该断开网口的标识是否与物理网口序号一致，有结果C)
```

# Expected Result
```bash
  A) 网卡网口在系统下的标识顺序为eth4、eth5
  B) 所有网口均处于Link状态
  C) OS下的网口序号与物理网口一致：eth4对应物理网口1、eth5对应物理网口2
```
