---
setpci，设置pci设备的属性

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-01-10
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 单板启动正常
  2. 系统正常启动
```

# Test Procedure
```bash
  1. 列出pci设备的地址: lspci
  2. 修改pci设备的属性: sudo setpci -s 00:02.0 F4.B=FF
     -s 表示接下来输入的是设备的地址。
     00:02.0 VGA设备地址（<总线>:<接口>.<功能>）。
     F4 要修改的属性的地址，这里应该表示“亮度”。
     .B 修改的长度（B应该是字节（Byte），还有w（应该是Word，两个字节）、L（应该是Long，4个字节））。
     =FF 要修改的值（可以改）
```

# Expected Result
```bash
  1. 能正常列出pci设备
  2. 能修改pci设备的属性
```
