---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡面板点灯功能。
 
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
  1.服务器上电后查看SSD点灯是否正常
    a) 绿色常亮：PCIe SSD盘在位绿色
    b) 绿色闪烁（2HZ）：PCIe SSD盘进行IO 
    c) 绿色灭：PCIe SSD盘不在位
    d) 橙色，常亮：PCIe SSD盘故障
    e) 橙色，闪烁（2HZ）：PCIe SSD盘定位，或者正在进行热插拔
    f) 橙色，闪烁（0.5HZ）：PCIe SSD盘已经完成热插拔流程，允许拔出
    g) 橙色，灭：PCIe SSD盘无故障
  2.查看现有服务器是否满足以上点灯要求
```

# Expected Result
```bash
  SSD盘/卡点灯正常，满足规范
```
