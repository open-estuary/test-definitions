---
kdump，是在系统崩溃、死锁或者死机的时候用来转储内存运行参数的一个工具和服务

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-01-10
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 单板启动正常
  2. 系统正常启动
```

# Test Procedure
```
  1. 查看系统是否打开kdump: $ ulimit -c
  2. 设置系统打开kdump: $ ulimit -c unlimited
  3. 设置系统关闭kdump: $ ulimit -c 0
  4. 修改配置文件来打开/关闭kdump: $ vi /etc/profile 
     再文件末尾增加: ulimit -S -c unlimited> /dev/null 2>&1
     执行source /etc/profile,使修改配置生效
     查询kdump已经打开: $ ulimit -c
  5. 系统奔溃时kdump文件位置及查看方法:
     修改生成的日志文件的路径到/var/log下
　    $ echo “/var/log” > /proc/sys/kernel/core_pattern
　    kdump文件名为core.xxxx，执行gdb core.xxx进行调试
```

# Expected Result
```
  1. 能正常查询kdump状态
  2. 能修改kdump的状态
```
