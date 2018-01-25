---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡ALB模式性能测试。

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
  1.将TAS端和SUT端的网卡做ALB模式的绑定，bond端口配置4个不同网段IP
  2.在TAS端执行netserver
  3.在SUT上针对每个IP执行如下：netperf -H <Server IP> -t TCP_STREAM -l 300，10GE网口跑双线程
  4.在SUT端执行netserver
  5.在SUT上针对每个IP执行如下：netperf -H <Server IP> -t TCP_STREAM -l 300，10GE网口跑双线程
  6.将网卡修改MTU为9000后再执行以上步骤，修改物理网口和bond MTU
  7.测试完成后恢复MTU 1500
```

# Expected Result
```bash
  1.使用ifconfig和ethtool -S查看网卡统计没有丢包和错包，测试结果数据在正常范围内:
    1000M网卡吞吐量高于940Mb/s，修改MTU后吞吐量高于980Mb/s
    10000M网卡吞吐量高于8000Mb/s，修改MTU后吞吐量高于9800Mb
  2.步骤3和步骤5绑定端口的吞吐量是物理端口带宽的双倍
```
