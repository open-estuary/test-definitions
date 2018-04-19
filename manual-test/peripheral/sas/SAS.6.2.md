---
SAS(Serial Attached SCSI)即串行连接SCSI，是新一代的SCSI技术，和现在流行的Serial ATA(SATA)硬盘相同，都是采用串行技术以获得更高的传输速度，并通过缩短连结线改善内部空间等。SAS是并行SCSI接口之后开发出的全新接口。此接口的设计是为了改善存储系统的效能、可用性和扩充性，并且提供与SATA硬盘的兼容性。
本用例是验证SAS盘的fio写性能
 
Hardware platform: D03 D05 
Software Platform: CentOS Ubuntu Debian
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-03-07
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.服务器1台且已安装操作系统
  2.设备上有SAS盘
```

# Test Procedure
```
  1.系统正常启动
  2.在系统OS下下发fio写命令，获取SAS盘的写速率
    fio -name=write -numjobs=32 -filename=/dev/sda -rw=write -iodepth=128 -direct=1 -sync=0 -norandommap -group_reporting -runtime=30 -time_base -bs=4kash
  3.重复以上步骤5次，对比SAS盘读速率的平均值是否正常
```

# Expected Result
```
  1.SAS盘的写速率正常
```
