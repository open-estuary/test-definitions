---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡AFT（网卡冗余）功能测试。

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
  2.在系统下将网卡的两个端口配置为主备用模式的bonding
    echo 1 > /sys/class/net/bond0/bonding/mode
    echo +eth0 > /sys/class/net/bond0/bonding/slaves
    echo + eth1 > /sys/class/net/bond0/bonding/slaves
  3.使用命令cat /proc/net/bonding/bond0查看当前使用的主端口，给bond0端口配置IP并up
  4.通过另一块单板对该单板的bonding端口进行ping包，查看是否只有主端口在收包
  5.拔掉当前的主端口的网线，使用命令cat /proc/net/bonding/bond0查看当前使用的主端口是否发生切换，查看是否能ping通，查看bond的主备端口状态，通过dmesg查看bond切换时间
  6.重新插上6步骤拔掉的网线，拔掉当前主端口的网线，查看是否还能ping通，查看bond的主备端口状态，通过dmesg查看bond切换时间
  7.在系统下对eth0执行ifconfig eth0 down操作，查看bond的主备端口状态，bond端口能否ping通，通过dmesg查看bond切换时间
  8.在系统下eth0执行ifconfig eth0 up操作，对eth1执行ifconfig eth1 down操作，查看bond的主备端口状态，bond端口能否ping通。通过dmesg查看bond切换时间
  9.在系统下打开eth0、eth1，在交换侧对eth0对应的端口进行shutdown操作，查看bond的主备端口状态，bond端口能否ping通，通过dmesg查看bond切换时间
  10.在交换侧对eth0对应的端口进行undo shutdown操作，对eth1对应的端口进行shutdown操作，查看bond的主备端口状态，bond端口能否ping通。通过dmesg查看bond切换时间
```

# Expected Result
```bash
  1.ping时只有主端口收包
  2.步骤5、6、7、8、9、10：bond发生切换，仍然能ping通，bond切换时间在10s以内
```
