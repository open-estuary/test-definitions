---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡共享中断测试。

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
  1.激活单板所有网卡设备，ifconfig ethX up
  2.查看文件/proc/interrupts
  3.确认每个网卡设备获得中断号
  4.确认每一个网卡设备使用唯一的中断号
```

# Expected Result
```bash
  每个网卡设备获得唯一中断号
```
