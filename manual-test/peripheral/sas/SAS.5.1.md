---
SAS(Serial Attached SCSI)即串行连接SCSI，是新一代的SCSI技术，和现在流行的Serial ATA(SATA)硬盘相同，都是采用串行技术以获得更高的传输速度，并通过缩短连结线改善内部空间等。SAS是并行SCSI接口之后开发出的全新接口。此接口的设计是为了改善存储系统的效能、可用性和扩充性，并且提供与SATA硬盘的兼容性。
本用例是验证SAS盘的热插拔功能
 
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
  1.系统起来后，被测SAS盘插入服务器相应槽位，设备能正常识别到SAS盘
  2.拔插SAS盘，系统有信息提示，设备能正常识别到SAS盘
  3.重复拔插操作10次，看系统能否正常识别SAS盘
```

# Expected Result
```
  1.多次热拔插SAS盘后，系统还能正常识别
```
