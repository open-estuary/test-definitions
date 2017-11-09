---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡初始化过程断电测试。

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
  1.单板上电，当POST进入网卡初始化过程对单板进行断电，重新对单板上电，查看系统能否正常启动，进入系统后网卡各端口连通性是否正常，有结果A)
  2.重复以上操作5次
```

# Expected Result
```bash
  A) 网卡正常，系统正常启动，网卡各端口连通性正常
```
