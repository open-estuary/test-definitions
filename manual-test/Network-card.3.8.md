---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡稳定性测试。

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
  1.系统启动后使用free命令查看系统总的内存大小，然后使用ifconfig –a 命令能否查看到网卡端口
  2.重启系统，使用free命令查看系统总的内存大小是否不变，使用ifconfig –a 命令能否查看到网卡端口
  3.重复以上步骤10次
```

# Expected Result
```bash
  系统内存不变，ifconfig –a 命令查看到网卡端口个数正确
```
