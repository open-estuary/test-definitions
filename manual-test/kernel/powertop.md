---
PowerTOP，是一款开源的命令行工具,用于诊断的功耗问题,查看系统中软件应用的活跃程度

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
  1. install package：yum install -y powertop
  2. run in "debug" mode: powertop --debug
  3. runs powertop in calibration mode: powertop -c
  4. Sets all tunable options to their GOOD setting: powertop --auto-tune
  5. generate a html report: powertop -r
  6. generate a csv report: powertop -C
  7. generate plain text report: powertop -d
  8. generate a report for 'x' seconds: powertop --debug -t 5
  9. run powertop: powertop
  10. suppress stderr output: powertop --quiet
  11. remove package: yum remove -y powertop

```

# Expected Result
```
  1. 能正常安装和卸载安装包
  2. 查询结果无报错信息
```
