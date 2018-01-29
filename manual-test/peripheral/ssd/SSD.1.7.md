---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡读写功能验证。
 
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
  1.使用fio工具对SSD设备进行读写测试，参数设置为numjobs=4， iodepth=64，连续测试30分钟以上，查看测试结果； 
  2.重复上述测试，遍历纯读、纯写、读写7:3等不同读写比例； 
  3.重复上述测试，遍历顺序、随机不同读写方式； 
  4.重复上述测试，遍历512B、4K、16K、1M等不同数据块大小
  5.实际执行大压力fio命令，测试完成后通过lspci –vv –d 19e5:0123查看SSD建链信息,查看CESta:RxErr- BadTLP- BadDLLP- Rollover- Timeout-是否有误码，出现+号即为误码
```

# Expected Result
```bash
  1.Fio运行过程无异常中断，结束无error；
  2.IO测试结束时查看SSD的建链信息，无误码；
```
