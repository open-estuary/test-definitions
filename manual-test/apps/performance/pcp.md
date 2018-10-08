---
pcp.md - pcp 强大的性能分析工具
Hardware platform: D05 D03
Software Platform: CentOS Ubuntu Debian
Author: mahongxin <hongxin_228@163.com>
Date: 2018-1-8 15:38:05
Categories: Estuary Documents
Remark:
---
# Dependency
```
     关闭防火墙
	systemctl stop firewalld
	firewall-cmd --state #查看默认防火墙状态（关闭后显示not running，开启后显示running）
---
# Test
```bash
     (1)安装所需要的安装包
       
	$ yum install pcp pcp-system-tools
	$ systemctl enable pmcd 
	$ systemctl start pmcd 
	$ systemctl enable pmlogger 
	$ systemctl start pmlogger
	$ cd /var/lib/pcp/pmdas/proc
	$ ./Install
	
       
     (2)查看pcp路径
　　　    rpm -ql pcp-system-tools

     (3)pmatop
PRC | sys   19.42s | user   3m51s | #proc    264 | #zombie    0 | no  procacct |
CPU | sys	6% | user     59% | irq       1% | idle   1524% | wait     10% |
CPL | avg1    0.09 | avg5    0.49 | avg15   0.36 | csw   965287 | intr  798939 |
MEM | tot    31.9G | free   23.3G | cache 440.9M | buff    2.9M | slab  504.4M |
SWP | tot    15.9G | free   15.9G |              | vmcom  14.6G | vmlim  31.9G |
LVM |	   cl-root | busy      0% | read    8577 | write    926 | avio 0.00 ms |
LVM |	   cl-swap | busy      0% | read      45 | write      0 | avio 0.00 ms |
LVM |    cl00-swap | busy      0% | read      21 | write      0 | avio 0.00 ms |
LVM |	   cl-home | busy      0% | read      65 | write      1 | avio 0.00 ms |
DSK |          sda | busy      6% | read    8447 | write    917 | avio 2.71 ms |
DSK |          sdb | busy      0% | read     286 | write      0 | avio 4.78 ms |
NET | transport    | tcpi     512 | tcpo     560 | udpi    1632 | udpo    1705 |
NET | network	   | ipi     2354 | ipo     2317 | ipfrw      0 | deliv   2353 |
NET | eth0	0% | pcki    2266 | pcko    2009 | si 4486 Kbps | so 1166 Kbps |
NET | lo      ---- | pcki     332 | pcko     332 | si  

     (4) [root@k8s-node-1 ~]# pmcollectl 
#<--------CPU--------><----------Disks-----------><----------Network---------->
#cpu sys inter  ctxsw KBRead  Reads KBWrit Writes KBIn  PktIn  KBOut  PktOut
   0   0   690    690     0      0     32      1    0      4      0      4
   0   0   719    720     0      0      0      0    1      7      0      4
   0   0   676    684     0      0      0      0    0      4      0      4
   0   0   737    728     0      0    277     22    0      5      0      4
   0   0   808    803     0      0      0      0    0      6      0      6

     (5)[root@k8s-node-1 ~]# pmiostat 
# Device      rrqm/s  wrqm/s     r/s    w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await   %util
sda             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00
sdb             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00
sda             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00
sdb             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00
sda             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00
sdb             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00

　  (6)/usr/libexec/pcp/bin/pcp-atop

ATOP - k8s-node-1      2018/01/09  10:58:27      ----x--------        1s elapsed
PRC | sys   29.60s | user   4m01s | #proc    270 | #zombie    0 | no  procacct |
CPU | sys	1% | user      9% | irq       0% | idle   1588% | wait      1% |
CPL | avg1    0.01 | avg5    0.02 | avg15   0.00 | csw  2518895 | intr 2112431 |
MEM | tot    31.9G | free   23.2G | cache 458.3M | buff    2.9M | slab  562.4M |
SWP | tot    15.9G | free   15.9G |              | vmcom  14.7G | vmlim  31.9G |
LVM |	   cl-root | busy      0% | read    8685 | write   2661 | avio 0.00 ms |
LVM |	   cl-swap | busy      0% | read      50 | write      0 | avio 0.00 ms |
LVM |    cl00-swap | busy      0% | read      26 | write      0 | avio 0.00 ms |
LVM |	   cl-home | busy      0% | read      70 | write      1 | avio 0.00 ms |
DSK |          sda | busy      1% | read    8578 | write   2664 | avio 2.77 ms |
DSK |          sdb | busy      0% | read     314 | write      0 | 

　  (7)/usr/libexec/pcp/bin/pcp-collectl
[root@k8s-node-1 bin]# ./pcp-collectl 
#<--------CPU--------><----------Disks-----------><----------Network---------->
#cpu sys inter  ctxsw KBRead  Reads KBWrit Writes KBIn  PktIn  KBOut  PktOut
   0   0   749    727     0      0      0      0    0      5      0      4
   0   0   682    683     0      0      0      0    0      5      0      4
   0   0   653    693     0      0      0      0    0      5      0      4
   0   0   646    659     0      0      0      0    0      5      0      4

    (8)/usr/libexec/pcp/bin/pcp-dmcache
[root@k8s-node-1 bin]# ./pcp-dmcache 
pcp-dmcache: pmLookupName: Unknown metric name ['dmcache.metadata.total', 'dmcache.write_misses', 'dmcache.cache.total', 'dmcache.cache.used', 'dmcache.write_hits', 'dmcache.read_hits', 'dmcache.metadata.used', 'dmcache.read_misses']


　　(9)/usr/libexec/pcp/bin/pcp-free


[root@k8s-node-1 bin]# ./pcp-free 
             total       used       free     shared    buffers     cached
Mem:      33417024    9099904   24317120          0       3008     478144
-/+ buffers/cache:    8618752   24798272
Swap      16711616          0   16711616

    (10)/usr/libexec/pcp/bin/pcp-mpstat
[root@k8s-node-1 bin]# ./pcp-mpstat 
Linux  4.12.0-estuary.3.aarch64  (k8s-node-1)  01/09/18  aarch64    (16 CPU)

Timestamp 	CPU	%usr 	%nice 	%sys 	%iowait 	%irq 	%soft 	%steal 	%guest 	%nice 	%idle 
11:04:09  	all	0.06 	0.0   	0.12 	0.0     	0.06 	0.0   	0.0    	0.0    	0.0   	99.74 
11:04:10  	all	0.18 	0.0   	0.43 	0.0     	0.06 	0.06  	0.0    	0.0    	0.0   	99.22 
11:04:11  	all	0.06 	0.0   	0.06 	0.0     	0.0  	0.0   	0.0    	0.0    	0.0   	99.88 
11:04:12  	all	0.06 	0.0   	0.06 	0.0     	0.0  	0.0   	0.0    	0.0    	0.0   	99.88 
   (11)/usr/libexec/pcp/bin/pcp-numastat
[root@k8s-node-1 bin]# ./pcp-numastat 
                           node0
numa_hit                  486622
                           node0
numa_miss                      0
                           node0
numa_foreign                   0
                           node0
interleave_hit              3504
                           node0
local_node                486622
                           node0
other_node                     0

   (12)/usr/libexec/pcp/bin/pcp-pidstat
[root@k8s-node-1 bin]# ./pcp-pidstat 
Linux  4.12.0-estuary.3.aarch64  (k8s-node-1)  01/09/18  aarch64    (16 CPU)
Timestamp	UID	PID	usr	system	guest	%CPU	CPU	Command
11:04:56	0	1	0.0	0.0	0.0	0.0	9	systemd
11:04:56	0	2	0.0	0.0	0.0	0.0	15	kthreadd
11:04:56	0	4	0.0	0.0	0.0	0.0	0	kworker/0:0H
11:04:56	0	5	0.0	0.0	0.0	0.0	5	kworker/u32:0
11:04:56	0	6	0.0	0.0	0.0	0.0	0	mm_percpu_wq
11:04:56	0	7	0.0	0.0	0.0	0.0	0	ksoftirq

  (13)/usr/libexec/pcp/bin/pcp-uptime
[root@k8s-node-1 bin]# ./pcp-uptime 
 11:06:08 up 54 min, 1 user,  load average: 0.06, 0.03, 0.00

(14)/usr/libexec/pcp/bin/pcp-iostat
[root@k8s-node-1 bin]# ./pcp-iostat 
# Device      rrqm/s  wrqm/s     r/s    w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await   %util
sda             0.00    0.00    0.00   2.00     0.00    75.82   38.000    0.000    0.00    0.00    0.00    0.00
sdb             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00
sda             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00
sdb             0.00    0.00    0.00   0.00     0.00     0.00    0.000    0.000    0.00    0.00    0.00    0.00


 (15)卸载安装包
　　　　　yum remove pcp pcp-system-tools
　　　　
```
