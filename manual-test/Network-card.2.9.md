---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡典型包长传输测试。

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
  1.Server端执行netserver
  2.SUT端网卡执行如下命令，记录测试结果: netperf -t TCP_RR -H TASIP地址 -l 10 -- -r 32,X
    X的值的范围是： 100 ～1200，1445 ～1465，2000
  3.SUT端所有网卡重复上面步骤，有结果A)
```

# Expected Result
```bash
  A) 相同带宽网口的测试结果数据不会有几个数量级上的差别
```
