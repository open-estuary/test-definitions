---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡对接测试。

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
  1.网卡对接之后、网卡上网口的指示灯亮、说明物理连接通路
  2.给对接网口配置同一网段的ip：ifconfig -s ethx 192.168.1.xxx 255.255.255.0
  3.互ping对端ip、能ping通无丢包
```

# Expected Result
```bash
  1.对接之后物理通路
  2.配置ip后互ping能ping通
```
