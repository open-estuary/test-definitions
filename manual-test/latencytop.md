---
Latencytop.md - Strace 报告系统和应用程序中与等待时间相关的统计信息
Hardware platform: D05 D03
Software Platform: CentOS Ubuntu Debian
Author: Chen Shuangsheng <hongxin_228@163.com>
Date: 2017-12-8 14:38:05
Categories: Estuary Documents
Remark:
---
#语法
```
     latencytop [  -t interval ] [ -o log_file] [ -k log_level]
        [ -f [no]feature,.... ] [-l log_interval] ...  [ -h] [ -s pid=PID|pgid=PGID]

```
#选项
---
    -f 在latencytop中启用/禁用功能.
    -h 显示命令的用法.
    -k 指定日志文件中的日志记录的级别,有效值包括：
        0  none(缺省值）
        1  unknown
        2  all
    -l 每log_interval秒向日志文件写入一次数据;必须大于60.
    -o 指定输出将写入的日志文件。缺省日志文件为/var/log/latencytop.log.
    -s 仅跟踪指定的进程或指定的进程组,并仅显示与此进程或进程组相关的数据.
    -t 指定此工具从系统收集统计信息的时间间隔.
---
# Test
```安装```
    centos:yum install latencytop -y
    debian|ubuntu:apt-get install latencytop -y
```
```测试命令
    $latencytop 启动此工具,并且使用各个选项的缺省值
    $latencytop -t 2

    -t 时间间隔2秒

    $latencytop -o /tmp/latencytop.log 将日志文件设置为/tmp/latencytop.log
    $latencytop -1 2 将日志级别设置为all
    $latencytop -f sobj 启用对同步对象导致的等待时间的跟踪
　　$latencytop -s pgid=630 显示进程组为630的进程的跟踪日期
```
```结束latencytop进程```
    ps -ef |grep latencytop|kill
```
```卸载latencytop```
    centos:yum remove latencytop -y
    ubuntu|debian:apt-get remove latencytop -y
```
