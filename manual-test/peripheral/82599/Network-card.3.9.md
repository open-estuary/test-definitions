---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡网络风暴恢复后ping包测试。

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
  1.给SUT端口网卡配置IP，对网卡进行ping包测试
  2.配置交换机，将某几个口设置在一个vlan里面（要包含网卡ping包的端口，其他端口不在此vlan中），然后短接其中两个口，制造一个隔离的网络风暴的场景，使风暴持续1小时
  3.1小时后对网络风暴进行去除，然后查看ping包测试是否继续，网卡是否正常，不在网络风暴vlan环境下的端口连通性是否是正常
```

# Expected Result
```bash
  去风暴后ping包能继续，不在网络风暴vlan环境下的端口连通性正常，网卡没有异常
```
