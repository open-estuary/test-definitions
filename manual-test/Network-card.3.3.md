---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡长时间压力测试。

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
  1.Server端运行netserver
  2.SUT端每个网口都同时启动一个netperf测试，TCP和UDP进行交替冲包，每10分钟交替一次。如使用如下命令跑TCP包: “netperf -H <Server IP1> -l 600 & netperf -H <Server IP2> -l 600......”
  3.长时间跑netperf压力测试后查看是否有丢包错包，查看dmesg中是否有网卡异常的信息，如link状态闪断
```

# Expected Result
```bash
  长时间测试没有出现丢包错包，dmesg没有异常信息
```
