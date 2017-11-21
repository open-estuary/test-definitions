---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡冲包过程拔插光纤操作。

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
  1.配置IP，使用netperf对网卡进行冲包，要进行测试的网卡做为Server 端
    Server 端：netserver
    SUT端：netperf –H ip –l 3600
  2.在冲包过程中拔掉光纤，1分钟后再插上光纤，反复拔插10次
  3.测试完后查看网卡是否正常，端口连通性是否正常
```

# Expected Result
```bash
   网卡正常，端口连通性正常
```
