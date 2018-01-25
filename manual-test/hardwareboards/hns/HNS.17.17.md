---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是XGE光电转换口关闭打开RX流控

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-21
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 单板启动正常
  2. 所有网口各模块加载正常
```

# Test Procedure
```
  1. 网口初始化后，设置对端RX流控关闭：ethtool -A ethx rx off
  2. 网口up，查询对端流控信息2次：ethtool -a ethx
  3. 设置对端RX流控打开，查询对端流控信息2次
  4. 网口down，设置对端RX流控关闭，查询对端流控信息2次
```

# Expected Result
```
  各个步骤查询到的流控使能信息正确
```
