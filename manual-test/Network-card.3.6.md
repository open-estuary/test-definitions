---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡端口间相互影响测试。

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
  1.单板上电进入OS，使用ifconfig ethX up命令激活所有网口
  2.使用ifconfig down/up命令来打开或关闭端口，使用ethtool命令查看其他端口的link状态是否影响，查看dmesg中是否有其他端口状态变化的打印，遍历所有端口，有结果A)
  3.使用netperf对一个端口进行冲包，使用ifconfig down/up命令来打开或关闭其他的端口，测试1小时，查看冲包端口是否会产生丢包，遍历所有端口，有结果B)
```

# Expected Result
```bash
  A) 使用ifconfig down/up命令来打开或关闭端口不会影响到其他端口的link状态，dmesg中没有其他端口状态变化的打印
  B) 冲包端口没有丢包
```
