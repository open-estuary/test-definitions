---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡ping包时网络攻击。

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
  1.配置IP，从server板往外ping包。
  2.使用HUTAF xDefend工具模拟网络攻击此端口，持续攻击一小时，查看ping包是否会中断，查看dmesg中有没有异常产生。
  3.遍历网卡所有端口。
  4.使用HUTAF xDefend工具模拟网络攻击，持续攻击网卡端口，在攻击过程中使用ifconfig ethx down/up对网卡端口进行反复关闭和打开操作10次，然后查看端口状态是否为linkup，ping此端口的IP，查看是否能ping通
```

# Expected Result
```bash
  1.Ping包没有发生过中断，ping包没有丢包，dmesg中没有异常信息
  2.网卡端口为linkup，能ping通
```
