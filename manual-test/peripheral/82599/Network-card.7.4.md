---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡UDP数据包性能测试。

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
  1.在Server端执行netserver
  2.在SUT上执行如下命令，pkt_length依次取值64、128、256、512、680、1024和10240，并记录测试结果
    对于GE网口执行: netperf -H <Server IP> -t UDP_STREAM –l 300 -- -m pkt_length
    对于10GE网口执行: netperf -H <Server IP> -t UDP_STREAM -- -m pkt_length –s 4096000 –S 4096000
  3.修改SUT端和TAS端网口MTU为9000，然后再次执行步骤2: ifconfig ethx mtu 9000
  4.以上步骤遍历网口所有网口，重复以上步骤3次
  5.测试完成后恢复SUT端和TAS端网口的MTU值: ifconfig ethx mtu 1500
```

# Expected Result
```bash
  使用ifconfig ethx 和ethtool -S ethx查看网卡统计没有丢包和错包，测试结果数据在正常范围内，大包:
   1000M网卡吞吐量高于940Mb/s，修改MTU后吞吐量高于980Mb/s
   10000M网卡吞吐量高于8000Mb/s，修改MTU后吞吐量高于9800Mb/s
```
