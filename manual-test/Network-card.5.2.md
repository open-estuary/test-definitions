---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡ALB（负载均衡）功能测。

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
  1.单板上电进入OS
  2.在系统下将网卡的两个端口配置为负载均衡模式的bonding
    echo 0 > /sys/class/net/bond0/bonding/mode
    echo +eth0 > /sys/class/net/bond0/bonding/slaves
    echo + eth1 > /sys/class/net/bond0/bonding/slaves
  3.使用命令cat /proc/net/bonding/bond0查看当前使用的主端口，给bond0端口配置IP并up
  4.eth0和eth1连接交换机的端口需要配置端口汇聚
  5.通过其他两块单板的网卡使用netperf工具同时对bonding端口进行冲包，使用sar工具查看绑定的端口是否都有数据包接收，速率和流量统计是否差不多
  6.在系统下执行ifconfig eth0 down操作，使用sar工具查看绑定端口的端口流量变化
  7.在系统下执行ifconfig eth0 up, ifconfig eth1 down操作，使用sar工具查看绑定端口的端口流量变化
  8.在系统下执行ifconfig eth1 up，在交换机侧对eth0对应的端口进行shutdown操作，使用sar工具查看绑定端口的端口流量变化
  9.在交换机侧对eth0对应的端口进行undo shutdown操作，对eth1对应的端口进行shutdown操作，，使用sar工具查看绑定端口的端口流量变化
```

# Expected Result
```bash
  步骤5: 使用sar工具查看绑定的端口都有数据包接收，速率和流量统计差不多，至少在同一个数量级
  步骤6、7、8、9: 只有up的端口有流量，为前面两个端口的流量的和
```
