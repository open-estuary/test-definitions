---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡Vlan配置测试。

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
  1.使用vconfig命令配置vlan 在ethx接口上配置两个VLAN 
    vconfig add ethx 100 
    vconfig add ethx 200 
  2.给ethx接口的两个VLAN配置IP
    ifconfig ethx.100 192.168.100.50 netmask 255.255.255.0 up 
    ifconfig ethx.200 192.168.200.50 netmask 255.255.255.0 up 
  3.删除VLAN命令 
    vconfig rem ethx.100 
    vconfig rem ethx.200 
  4.遍历所有网口，有结果A)
```

# Expected Result
```bash
  A) VLAN能正常配置
```
