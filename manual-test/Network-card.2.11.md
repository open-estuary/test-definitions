---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡指示灯测试。

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
  1.单板上电启动，检查网卡指示灯状态，有结果A)
  2.进入OS，执行ethtool –p ethX，查看网卡指示是否闪烁，遍历网卡所有端口，有结果B)
  3.断开网卡物理连接，单板下电上电，进入OS，将网卡所有物理网口连接交换机，检查指示灯状态，有结果A)
```

# Expected Result
```bash
  A) Link灯亮绿灯，ACT灯有收发数据时闪黄灯
  B) 网卡点灯功能正常
```
