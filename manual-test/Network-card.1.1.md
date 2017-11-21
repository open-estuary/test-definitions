---
计算机与外界局域网的连接是通过主机箱内插入一块网络接口板，这块网络接口板的简称就是网卡，我们主要验证的是PCIe 82599网卡在我们服务器上的性能。
本用例主要是验证82599网卡的上电功能。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-07
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
  1.被测82599网卡插入服务器相应槽位
  2.服务器上电，查看是否能识别到82599网卡
```

# Expected Result
```bash
  1.网卡能正常安装、无结构干涉
  2.网卡能上电、正常被识别
```
