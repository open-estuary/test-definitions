---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡上网口开关测试。

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
  1.开启所有网卡：ifconfig ethX up ，ethtool查询所有网卡Link状态是否显示yes，速率协商和带宽是否正确，有结果A)
  2.配置IP后检查所有网卡均能ping通，有结果B)
  3.关闭所有网卡：ifconfig ethX down，ethtool查询所有网卡Link状态是否显示no，有结果C)
  4.重复执行网卡打开关闭动作10次
  5.恢复82599网卡IP，验证网口连通性，需要遍历网卡所有网口，有结果B)
  6.查看dmesg是否有异常信息，有结果D)
```

# Expected Result
```bash
  A) 网卡Link状态显示yes，GE口显示GE速率，10GE口显示10GE速率，不支持自协商
  B) 所有网卡均能通信
  C) 网卡Link状态显示no
  D) 网卡打开关闭操作没有异常日志产生
```
