---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是业务网口带VLAN的TSO分片功能测试

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-22
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
  1. 两块单板的网口对接，并使用ethtool打开网口的TSO功能
  2. 在网口上配置vlan
  3. 在该网口上运行iperf tcp业务，观察TCP连接是否正常，分片是否正常
```

# Expected Result
```
  带有vlan的业务正常，无错包丢包
```
