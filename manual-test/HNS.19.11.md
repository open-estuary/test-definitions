---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是业务网口开启GSO/GRO前后性能测试

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
  1. 两块单板的网口对接
  2. 开启GSO/GRO功能，使用iperf对网口进行tcp报文收发测试，记录带宽和cpu占用率数据
  3. 关闭GSO/GRO功能，使用iperf对网口进行tcp报文收发测试，记录带宽和cpu占用率数据
```

# Expected Result
```
  1. 开启GSO/GRO后，性能提升
```
