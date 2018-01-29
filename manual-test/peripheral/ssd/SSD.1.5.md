---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡固件升级。
 
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
  1.升级SSD FW，选择立即激活，测试10次以上；
  2.升级SSD FW，选择复位激活  
  3.重启服务器
  4.服务器重启完成后，查看盘片是否升级成功，测试10次以上
  5.遍历不同容量规格的SSD；
    升级命令说明：hioadm updatefw -d devicename -f fwimagefile [-s slot] [-a activeflag]
    devicename为待升级的SSD设备名称；
    fwimagefile为FW版本的镜像文件路径；
    slot为槽位号，可选2或3，slot1是只读固件，不允许用户修改
    activeflag为固件激活方式，值为1时立即激活，值为0时复位激活
```

# Expected Result
```bash
  1.选择立即激活方式升级SSD FW，可通过hioadm updatefw –d devicename查询到升级版本的FW信息
  2.选择复位激活方式升级SSD FW，重启服务器后，可通过hioadm updatefw –d devicename查询到升级版本的FW信息
  3.盘片反复升级回退无异常，可正常使用
```
