---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡Jumbo Frame测试。

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
  1.装有相同网卡的两台服务器对接，配置同网段的IP
  2.将网卡的MTU值设置在1500和网卡支持的最大Jumbo Frames值之间，两台服务器间ping包，使用tcpdump在网卡物理端口抓包，查看网卡物理端口发出的包大小是否为设置值
  3.将网卡的MTU值设置为网卡支持的最大Jumbo Frames值，两台服务器间ping包，使用tcpdump在网卡物理端口抓包，查看发查看网卡物理端口发出的包大小是否为设置值
  4.将网卡的MTU值设置大于网卡支持的最大Jumbo Frames值，两台服务器间ping包，使用tcpdump在网卡物理端口抓包，查看发查看网卡物理端口发出的包大小是否为网卡支持的最大Jumbo Frames
```

# Expected Result
```bash
  步骤2、3: 网卡物理端口发出的包大小为设置值
  步骤4: 网卡物理端口发出的包大小为网卡支持的最大Jumbo Frames
```
