---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡复位测试。
 
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
  2.设备上有SSD卡至少2块
```

# Test Procedure
```bash
  1.重启服务器，查看SSD设备是否还能正常使用
  2.重启后查看PCIE建链状态是否正常
  3.进行数据一致性测试5分钟，查看测试结果是否正常
  4.实际执行采用reboot脚本，设置100次，给脚本reboot.sh加可执行权限，执行./reboot.sh命令即可
```

# Expected Result
```bash
  reboot测试后全部盘片状态无异常，建链状态正常
```
