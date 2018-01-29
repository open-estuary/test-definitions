---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是RSS功能测试

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
  1. 利用ethtool -X ethx equal 16命令配置RSS indrection table
  2. 通过ethtool -S ethx查看统计信息，测试网口对应的各个ring是否均衡增加
  3. 遍历业务网口
```

# Expected Result
```
  1. 各个中断均衡参加
```
