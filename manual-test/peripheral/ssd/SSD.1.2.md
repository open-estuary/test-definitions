---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡的安装功能。
 
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
  1.将SSD盘插入服务器8639槽位上，SSD卡插入服务器PCIE标准插槽上
  2.将服务器上电，查看系统是否可以检测到SSD设备，在终端下通过“lspci | grep 0123”命令查看
  3.查看服务器PCIe连接速率，在终端下通过“lspci -vv -d 19e5:0123”，查看PCIe速率 是否为speed 8GT/s,width x4
  4.重复上述步骤，遍历服务器的PCIe插糟
```

# Expected Result
```bash
  1.能正常插入服务器8639槽位/标准PCIE插槽上
  2.服务器上电后能正常检测到SSD设备
  3.PCIe速率为speed 8GT/s,width x4
  4.遍历服务器的PCIe插糟,均无异常
```
