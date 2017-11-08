---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡稳定性。
 
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
  1.使用fio工具对SSD设备进行写带宽测试，参数设置为numjobs=4，iodepth=64，bs=4K，读写方式和比例为随机7:3，连续测试24小时以上； 
  2.监测读写性能、系统资源占用状态、SSD盘相关日志是否正常
  3.与一致性一起，IO压力测试24小时 ，数据一致性跑24小时
  4.实际执行大压力fio命令，测试完成后通过lspci –vv –d 19e5:0123查看SSD建链信息,查看CESta:RxErr- BadTLP- BadDLLP- Rollover- Timeout-是否有误码，出现+号即为误码
```

# Expected Result
```bash
  1.Fio运行过程无异常中断，结束无error
  2.IO测试结束时查看SSD的建链信息，无误码
```
