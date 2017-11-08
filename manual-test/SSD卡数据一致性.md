---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡数据一致性。
 
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
  1.在SSD设备上创建文件系统； 
  2.在本地磁盘中创建文件，并计算MD5值； 
  3.将文件复制到SSD盘对应的磁盘中，并计算MD5值； 
  4.比较前后MD5值是否一致
  5.实际执行大压力fio命令，测试完成后通过lspci –vv –d 19e5:0123查看SSD建链信息,查看CESta:RxErr- BadTLP- BadDLLP- Rollover- Timeout-是否有误码，出现+号即为误码
```

# Expected Result
```bash
  1.Fio运行过程无异常中断，结束无error
  2.IO测试结束时查看SSD的建链信息，无误码
```
