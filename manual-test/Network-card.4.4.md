---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡端口满配Vlan。

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
  1.给网卡端口配置宣称支持的Vlan数目的Vlan，在另一台服务器上对接的端口配置同样的Vlan
  2.在两台服务器上的每个Vlan上配置一个IP，通过一台服务器往另一台服务器ping包，能否ping通，记录配置成功且能ping通的最大Vlan数目
  3.遍历网卡上所有端口
```

# Expected Result
```bash
  能配置支持的Vlan数目的Vlan，能正常通信
```
