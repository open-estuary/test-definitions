---
cpu_hotplug.md - cpu_hotplug 测试cpu热插拔
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-15-02 11:38:05  
Categories: Estuary-kernel  
Remark:
---
#测试步骤
```
1.启动单板进入发行版
2.查看cpu状态lscpu
3.拔掉cpu0 echo 0 >> /sys/devices/system/cpu/cpu0/online，再查看cpu
4.插上cpu0 echo 1 >> /sys/devices/system/cpu/cpu0/online，再查看cpu
5.换cpu盘，重复步骤3、4
```
