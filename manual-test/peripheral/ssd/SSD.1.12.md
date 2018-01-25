---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡系统启动。
 
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
  1.查询服务器支持OS列表与huawei SSD支持的bootable列表OS取交集
  2.在SSD卡上安装交集的OS
  3.安装完成后，重启OS，查看是否成功启动
  4.交集OS依次验证
```

# Expected Result
```bash
  OS能成功安装和启动
```
