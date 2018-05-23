---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡的上电功能。
 
Hardware platform: D03 D05 
Software Platform: CentOS Ubuntu Debian
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-06
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.服务器1台且已安装操作系统
  2.设备上有SSD盘
```

# Test Procedure
```bash
  1.被测盘/卡插入服务器相应槽位
  2.服务器上电，查看是否能识别到SSD
```

# Expected Result
```bash
  1.能正常安装，无结构干涉
  2.SSD能上电，正常被识别
```
