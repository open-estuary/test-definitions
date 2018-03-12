---
内存(Memory)也被称为内存储器，其作用是用于暂时存放CPU中的运算数据，以及与硬盘等外部存储器交换的数据。
本用例主要是验证降低频率后内存的性能

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-03-12
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 服务器1台且能正常启动系统
```

# Test Procedure
```
  1. 单板下电
  2. 设备满配内存
  3. 单板上电，系统正常启动
  4. 在uefi下降低频率，reboot单板
  5. 系统起来后，测试内存的性能
```

# Expected Result
```
  1. 设备能正常启动进入BIOS
  2. 启动日志无异常报错信息
  3. 内存性能测试正常
```
