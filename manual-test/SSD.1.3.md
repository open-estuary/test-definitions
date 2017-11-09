---
固态硬盘（Solid State Drives），简称固盘，固态硬盘（Solid State Drive）用固态电子存储芯片阵列而制成的硬盘，由控制单元和存储单元（FLASH芯片、DRAM芯片）组成。本用例是为验证SSD卡驱动的安装与卸载功能。
 
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
  1.获取最新版本的rpm自研驱动包，上传到服务器任意目录并执行命令 rpm -Uvh <驱动软件包名称> 命令安装驱动包； 
  2.查看驱动信息是否正确：
    a)  Linux环境，在终端下通过“modinfo nvme”命令查看； 
    b)  Windows环境，在 计算机管理–设备管理器–存储控制器 中，右键点击SSD设备选择 属性 ，在 驱动程序 栏查看； 
  3.执行 rpm -e <驱动软件包名称> 命令卸载自研驱动，再次用modinfo nvme查看驱动信息
```
# Expected Result
```bash
  1.正常上传自研驱动包到服务器目录并成功安装
  2.可查询到升级后的驱动信息
```
