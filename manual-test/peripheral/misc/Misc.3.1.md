---
本用例主要是单板上iic设备的查询

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
  1. 单板上电，系统正常启动
  2. 在os上下发usb查询命令: ls -l /sys/class/i2c-dev/*/device/firmware_node |grep HISI
  3. 查看打印信息是否与实际相符
```

# Expected Result
```
  1. 打印信息与实际相符
```
