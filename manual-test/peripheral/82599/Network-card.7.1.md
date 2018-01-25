---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡AFT模式性能测试。

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
  1.将Server端和SUT端的网卡做AFT模式的绑定，配置同一网段IP
  2.在Server端执行netserver
  3.在SUT上执行如下命令，pkt_length依次取值64、128、256、512、680、1024和10240，并记录测试结果：netperf -H <Server IP> -t TCP_STREAM –l 300 -- -m pkt_length
  4.修改MTU为9000后再执行步骤3，修改物理网口和bond MTU
  5.以上步骤遍历SUT端网卡
  6.重复以上步骤3次，测试完成后恢复MTU 1500
```

# Expected Result
```bash
  使用ifconfig和ethtool -S 查看网卡统计没有丢包和错包，测试结果数据在正常范围内，大包:
   1000M网卡吞吐量高于940Mb/s，修改MTU后吞吐量高于980Mb/s
   10000M网卡吞吐量高于8000Mb/s，修改MTU后吞吐量高于9800Mb/s
```
