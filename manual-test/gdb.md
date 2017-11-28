---
gdb.md - gdb 是GNU开源组织发布的一个强大的UNIX下的程序调试工具
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-11-02 14:38:05  
Categories: Estuary Documents  
Remark:
---
#测试程序test.c
```
    1 #include <stdio.h>
     2
     3 int func(int n)
     4 {
     5         int sum=0,i;
     6         for(i=0; i<n; i++)
     7         {
     8                 sum+=i;
     9         }
    10         return sum;
    11 }
    12
    13
    14 main()
    15 {
    16         int i;
    17         long result = 0;
    18         for(i=1; i<=100; i++)
    19         {
    20                 result += i;
    21         }
    22
    23        printf("result[1-100] = %d /n", result );
    24        printf("result[1-250] = %d /n", func(250) );
    25 }
```
#编译:要-g才有调试信息
```
    gcc -g test.c -o test
```
#调试
```
[root@localhost ~]# gdb test
GNU gdb (GDB) Red Hat Enterprise Linux 7.6.1-100.el7
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "aarch64-redhat-linux-gnu".
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>...
Reading symbols from /root/tst...done.
(gdb) l
8	                sum+=i;
9	        }
10	         return sum;
11	 }
12	
13	
14	main()
15	{
16	 	int i;
17	 	long result = 0;
(gdb) l
18		 for(i=1; i<=100; i++)
19		 {
20			 result += i;
21		 }
22	
23		 printf("result[1-100] = %d /n", result );
24		 printf("result[1-250] = %d /n", func(250) );
25	}
(gdb) 
Line number 26 out of range; test.c has 25 lines.
(gdb) break 16
Breakpoint 1 at 0x400654: file test.c, line 16.
(gdb) break func 
Breakpoint 2 at 0x400608: file test.c, line 5.
(gdb) info breakpoints 
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000400654 in main at test.c:16
2       breakpoint     keep y   0x0000000000400608 in func at test.c:5
(gdb) r
Starting program: /root/tst 

Breakpoint 1, main () at test.c:17
17	 	long result = 0;
Missing separate debuginfos, use: debuginfo-install glibc-2.17-196.el7.aarch64
(gdb) n
18		 for(i=1; i<=100; i++)
(gdb) n
20			 result += i;
(gdb) n
18		 for(i=1; i<=100; i++)
(gdb) n
20			 result += i;
(gdb) n
18		 for(i=1; i<=100; i++)
(gdb) c
Continuing.

Breakpoint 2, func (n=250) at test.c:5
5	        int sum=0,i;
(gdb) n
6	        for(i=0; i<n; i++)
(gdb) p i
$1 = -796159856
(gdb) n
8	                sum+=i;
(gdb) n
6	        for(i=0; i<n; i++)
(gdb) n
8	                sum+=i;
(gdb) p sum
$2 = 0
(gdb) bt
#0  func (n=250) at test.c:8
#1  0x00000000004006a4 in main () at test.c:24
(gdb) finish 
Run till exit from #0  func (n=250) at test.c:8
0x00000000004006a4 in main () at test.c:24
24		 printf("result[1-250] = %d /n", func(250) );
Value returned is $3 = 31125
(gdb) c
Continuing.
result[1-100] = 5050 /nresult[1-250] = 31125 /n[Inferior 1 (process 33393) exited with code 030]
(gdb) q

```
