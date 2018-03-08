---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是业务网口超时时间设置后功能验证

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
  1. 网口正常初始化后，输入命令：ethtool -C ethx rx-usecs 1023 tx-usecs 1023，输入查询命令：ethtool -c ethx
  2. 网口up，ping对端
  3. 网口正常初始化后，输入命令：ethtool -C ethx rx-usecs 1 tx-usecs 1，输入查询命令ethtool -c ethx
  4. ping对端，网口down
  5. 重复步骤1-4多次，观察现象是否稳定
```

# Expected Result
```
  1. 每次查询到的参数与配置进去的参数一致
  2. 步骤2的ping延时比步骤4大
```
