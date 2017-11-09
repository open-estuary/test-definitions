---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡双向带宽测试。

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
  1.使用在一台主机上运行iperf进行双向带宽测试:
    server端: iperf -s
    SUT端GE执行: iperf -c serverip -i 1 -t 60 -d ; 10GE执行: iperf -c serverip -i 3 -P 3 -t 60 -d
  2.遍历网卡所有端口
```

# Expected Result
```bash
  使用ifconfig ethx 和ethtool -S ethx查看网卡统计没有丢包和错包，GE口双向带宽均不低于940M ，10GE口双向带宽均不低于8G
```
