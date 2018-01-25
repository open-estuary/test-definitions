---
OProfile，是Linux内核支持的一种性能分析机制，是用于 Linux 评测和性能监控的工具BCC（BPF编译器集合 ）是用于创建足智多谋内核跟踪和操作程序一套功能强大的适当的工具和示例文件。 它采用扩展BPF（ Berkeley包过滤器 ），最初被称为eBPF这是在Linux的3.15的新功能之一

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-01-17
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
  1. install package: yum install -y bcc-tools
  2. 查看安装包版本：yum info bcc-tools |grep Version
  3. 查看安装源：yum info bcc-tools |grep "From repo"
  4. 列出bcc工具：$ ls /usr/share/bcc/tools
  5. 跟踪open()系统调用: sudo ./opensnoop
  6. 总结块设备I / O延迟: sudo ./biolatecncy
  7. 通过exec()Syscalls跟踪新进程: sudo ./execsnoop
  8. 跟踪慢ext4操作: sudo ./execslower
  9. 跟踪块设备I / O，带PID和延迟: sudo ./biosnoop
  10. 跟踪页面缓存命中/未命中比率: $ sudo ./cachestat
  11. 跟踪TCP活动连接: sudo ./tcpconnect
  12. 跟踪失败exec()s Syscalls: sudo ./opensnoop -x
  13. remove package: yum remove -y bcc-tools
```

# Expected Result
```
  1. 能正常的安装与卸载
  2. 版本与安装源正确
  3. 能正常的使用bcc工具 
```
