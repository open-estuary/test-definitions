---
本用例主要是单板上usb设备的热拔插功能验证

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
  2. 单板上有usb设备
```

# Test Procedure
```
  1. 单板上电，系统正常启动
  2. 在os上下发usb查询命令: lsusb，查询结果有u盘
  3. 拔出单板上的u盘，查询结果无u盘
  4. 在把拔出的u盘插入单板，查询结果有u盘
```

# Expected Result
```
  1. 打印信息与实际相符
```
