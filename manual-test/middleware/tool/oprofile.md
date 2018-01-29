---
OProfile，是Linux内核支持的一种性能分析机制，是用于 Linux 评测和性能监控的工具

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-01-12
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 单板启动正常
  2. 系统启动正常
```

# Test Procedure
```
  1. install oprofile: yum install -y oprofile
  2. 指示oprofile启动检测后，不记录内核模块、内核代码相关统计数据：$ opcontrol --no-vmlinux
  3. 加载oprofile模块、oprofile驱动程序：$ opcontrol --init
  4. 指示oprofile启动检测：$ opcontrol --start 
  5. 指示将oprofile检测到的数据写入文件：$ opcontrol --dump
  6. 清空之前检测的数据记录：$ opcontrol --reset
  7. 关闭oprofile进程：$ opcontrol -h
  8. 以镜像(image)的角度显示检测结果，进程、动态库、内核模块属于镜像范畴：$ opreport
  9. 以函数的角度显示检测结果：$ opreport -l
  10. 以函数的角度，针对test进程显示检测结果：$ opreport -l test
  11. 以代码的角度，针对test进程显示检测结果：$ opannotate -s test
  12. remove oprofile：yum remove -y oprofile

```

# Expected Result
```
  1. 能正常安装和卸载oprofile
  2. 能正常的显示检测结果
```
