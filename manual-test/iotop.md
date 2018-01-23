---
iotop.md - iotop 用来看某个进程的系统调用以及所接收到的信号
Hardware platform: D05 D03
Software Platform: CentOS Ubuntu Debian
Author: mahongxin <hongxin_228@163.com>
Date: 2018-1-4 15:38:05
Categories: Estuary Documents
Remark:
---
#命令说明
```
         iotop命令可以用来监控系统中各个进程对IO的使用量，它和top一样可以在非batch模式下运行时进行与用户交互。它主要可以用于监控:
        1.各个进程占用的IO带宽;
        2.进程在进行swapin/进行IO时占用的时间比例;
        3.顶端显示了单个运行周期内的读写总量
      　4.按ctrl+c强制退出命令
```
#选项
---
　　　　
            -o            　　　　　仅显示产生(产生过)IO的进程;
            -b            　　　　　批量模式,无法进行交互模式，多次的输出依次刷新;
            -n <num>      　　　　　设置退出前执行的次数，可以结合-b方便日志输出;
            -u <user>     　　　　　表示控制仅显示user用户的相关进程;
            -a            　　　　　显示累积流量，方便查看发生IO的总量
            -t            　　　　　在每行上输出当前的时间戳,以batch模式输出
　　　　　　-q　　　　　--quiet 　　禁止头几行，非交互模式。有三种指定方式。
                 　   　-q　　　　　只在第一次监测时显示列名
               　　　 　-qq 　　　　永远不显示列名。
            　　　　　　-qqq   　 　永远不显示I/O汇总
　　　　　  -d SEC　　　--d         设置每次监测的间隔,默认为１秒，接受非整形数据如1.1

---
# Test
```bash
    　(1)安装iotop:
        centos:yum install iotop
        ubuntu:apt-get install iotop

     (2)$iotop    查看当前系统进程的磁盘读写情况
        TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO> 0.00       BMAND
    1 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.001982.52 K
    2 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]
   16 ?sys root        0.00 B/s    0.00 B/s  0.00 % 99.99 % [ksoftirqd/1]
    4 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kworker/0:0H]
    6 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [mm_percpu_wq]
    7 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [ksoftirqd/0]
    8 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcu_sched]
    9 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [rcu_bh]
   10 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [migration/0]
   11 ?sys root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [watchdog/0]

    (3)iostat 4　　　表示每隔４秒刷新一次
    (4)iotop -o  查看较高磁盘的读写程序
       TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
  787 ?sys syslog      0.00 B/s    7.77 K/s  0.00 %  0.00 % rsyslogd ~ain Q:Reg]
  341 ?sys root        0.00 B/s    7.77 K/s  0.00 %  0.00 % [jbd2/sda2-8]
  860 ?sys root        0.00 B/s    3.88 K/s  0.00 %  0.00 % dhclient ~nahisic2i0
　　　(5)卸载安装包
　　　 　centos:yum remove iotop
         ubuntu:apt-get remove iotop
```

