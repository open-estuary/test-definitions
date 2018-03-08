---
usb_hotplug.md - usb_hotplug 测试USB热插拔和不同型号usb是否能识别
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-11-02 10:38:05  
Categories: Estuary Documents  
Remark:
---
#测试步骤
```
1.启动单板进入发行版
2.查看usb设备ls /dev/USB*
3.插上u盘，再查看usb设备，是否能找到盘符
4.拔掉u盘，再查看usb设备，盘符是否消失
5.换u盘，重复步骤3、4
```
