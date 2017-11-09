---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡端口流控功能。

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
  1.使用命令ethtool –a ethx查看被测网卡的流控是否打开，如果没有打开，使用命令ethtool –A ethx [rx on] [tx on]打开网卡端口的流控
  2.在被测网卡所在的服务器上运行netserver
  3.在其他两台辅助服务器上跑netperf，对被测网卡的同一个端口进行冲包，使流量超过被测网卡的线速，使用ethtool –S ethx查看被测网卡是否有往外发送pause frame（看tx_pauseframes统计是否不为0Network-card.1.1)
  4.在一台辅助服务器上运行netserver。
  5.使用netperf工具从被测网卡端口往外发线速的包，使用sar工具监控被网卡端口流量，在交换机测模拟给被测网卡发送pause frame，使用ethtool –S ethx查看被测网卡是否有收到pause frame（看rx_pauseframes统计是否不为0），网卡是否往外发送的流量减少或者在一段时间没有发包。
```

# Expected Result
```bash
  步骤3: 当流量超过被测网卡线速时网卡有往外发送pause frame
  步骤5: 被测网卡有收到pause frame，网卡往外发送的流量减少或者在一段时间没有发包
```
