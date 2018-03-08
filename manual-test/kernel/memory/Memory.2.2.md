---
内存(Memory)也被称为内存储器，其作用是用于暂时存放CPU中的运算数据，以及与硬盘等外部存储器交换的数据。本用例主要是为了验证内存条插在设备上不同的槽位对系统启动的影响

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2017-11-06
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1.服务器1台且能正常启动系统
```

# Test Procedure
```bash
  1.单板下电
  2.一根内存插入设备主CPU的A槽位、另外一根插入从CPU的任意槽位
  3.单板上电
```

# Expected Result
```bash
  1.设备能正常启动进入BIOS
  2.启动日志无异常报错信息
```
