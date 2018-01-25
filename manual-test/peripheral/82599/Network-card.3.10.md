---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡压力下网络攻击测试。

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
  1.配置IP，使用netperf或者iperf工具对SUT端口网卡进行冲包，同时使用HUTAF xDefend工具模拟网络攻击此冲包端口，查看dmesg中有没有异常产生
  2.查看网卡是否正常，性能是否有抖动
```

# Expected Result
```bash
  网卡正常，能持续收包
```
