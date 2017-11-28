---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡常温散热功能。
 
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
  1.查看SSD温度是否正常： 
    a) Linux或VMware环境，在终端下通过“hioadm temperature”命令查看； 
    b) Windows环境，使用SSD盘驱动提供的命令行工具“hioadm.exe temperature”查看
  2.使用fio工具对SSD设备进行最大压力的写测试，连续测试30分钟以上
    大压力fio命令说明：fio -direct=1 -ioengine=libaio -bs=4k -rw=randrw -rwmixread=70 -numjobs=32 -size=100% -iodepth=256 -runtime=200000 -time_base -filename=/dev/nvme0n1 -name=nvme03、再次执行“hioadm temperature”命令查看SSD盘的温度信息，对比IO测试前后exceed temperature threshold count和exceed temperature threshold time的数值是否有增加，确认IO过程中是否有超温问题
  3.重复上述步骤，遍历服务器的PCIe盘/卡槽位
```

# Expected Result
```bash
  1.IO测试前后SSD温度信息正常
  2.遍历所有的SSD，对比温度信息中的超温次数和超温时间，均没有增加
```
