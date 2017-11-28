---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是设备网口模式查询。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-10
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.单板启动正常
  2.所有网口各模块加载正常
```

# Test Procedure
```bash
  1.网口模块加载后执行查询命令，查到的网口基本配置信息与规格相符
  2.网口up，执行查询命令，查到的网口基本配置信息与规格相符
  3.网口down，执行查询命令，查到的网口基本配置信息与规格相符
  4.重复步骤2-3多次
  5.遍历设备上各类型的网口
```

# Expected Result
```bash
  查询到的网口信息与规格相符
```
