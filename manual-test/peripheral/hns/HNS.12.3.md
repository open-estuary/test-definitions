---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是GE光口重新自协商.

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-16
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
  1.网口模块加载后，输入重新自协商命令
  2.网口up，ping对端成功
  3.输入重新自协商命令，ping对端成功，重复两次
  4.网口down，输入重新自协商命令，重复两次
  5.网口up，ping对端成功
  6.重复步骤2-5多次
```

# Expected Result
```bash
  重新自协商命令执行成功，ping包成功
```
