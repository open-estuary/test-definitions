---
HNS，海思网络子系统（Hisilicon Network Subsystem），主要是验证设备上网口的性能。
本用例验证的是设备收发包过程中多次打开和关闭网口。

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
  1.分别打开各个网口，正确配置ip
  2.对端ping包,ping包过程中关闭网口，查看收发统计
  3.重新打开网口，查看收发包统计
  4.多次执行步骤1-3，直到出现因开关网口导致CRC错误的统计
```

# Expected Result
```bash
  关闭网口后，网口不能收发包，收发统计不增加
  打开网口后，网口可以正常收发包，收发统计增加
  协议栈检查报文内容正确
```
