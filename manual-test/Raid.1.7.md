---
RAID是英文Redundant Array of Independent Disks的缩写，翻译成中文即为独立磁盘冗余阵列，或简称磁盘阵列。简单的说，RAID是一种把多块独立的硬盘（物理硬盘）按不同方式组合起来形成一个硬盘组（逻辑硬盘），从而提供比单个硬盘更高的存储性能和提供数据冗余的技术。RAID卡就是用来实现RAID功能的板卡，通常是由I/O处理器、硬盘控制器、硬盘连接器和缓存等一系列零组件构成的。
本用例是验证RAID卡硬复位测试。

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-07
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.服务器1台且能正常启动系统
  2.RAID卡一块
```

# Test Procedure
```bash
  1.从连接RAID卡的硬盘启动系统后下拔插电源
  2.服务器起来后系统还能从硬盘启动
  3.重复以上步骤5次
```

# Expected Result
```bash
  1.服务器上电后系统还能从硬盘正常启动
  2.插拔电源多次之后系统启动无异常
```
