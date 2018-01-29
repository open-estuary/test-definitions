硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡的容量规格。
 
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
  1.查看SSD设备的容量是否与规格相符：
    在终端下发lsblk命令查看 
  2.重复步骤1，遍历不同容量规格的SSD和服务器的PCIe槽位
```

# Expected Result
```bash
  1.SSD容量与规格相符
  2.遍历所有的nvme SSD设备，各类状态信息均无异常
```
