---
RAID是英文Redundant Array of Independent Disks的缩写，翻译成中文即为独立磁盘冗余阵列，或简称磁盘阵列。简单的说，RAID是一种把多块独立的硬盘（物理硬盘）按不同方式组合起来形成一个硬盘组（逻辑硬盘），从而提供比单个硬盘更高的存储性能和提供数据冗余的技术。RAID卡就是用来实现RAID功能的板卡，通常是由I/O处理器、硬盘控制器、硬盘连接器和缓存等一系列零组件构成的。
本用例是验证BMC网页上查询RAID卡的相关信息。

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
  1.登陆服务器的iBMC侧
  2.观测BMC网页上是否能查询到RAID卡信息：
    信息-->系统信息-->存储
```

# Expected Result
```bash
  华为服务器BMC侧能查询RAID卡的相关信息
```
