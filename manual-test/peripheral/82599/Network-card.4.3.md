---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例验证的是82599网卡同一VLAN内交互测试。

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
  1.将两台服务器上的网卡配置同网段的IP，并配置相同的VLAN ID，两台服务器一台做server，一台做client，使用netperf工具进行冲包: netperf -H Serve_ip -l 300
  2.在将两台服务器上的网卡的其他端口配置其他网段的IP，并配置与步骤2相同的VLAN ID，使用netperf工具同时对两个端口同时冲包: netperf -H Serve1_ip -l 300；netperf -H Serve2_ip -l 300
```

# Expected Result
```bash
  性能在正常范围内，不同网段IP端口同时冲包互不影响
```
