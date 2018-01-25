---
ktap.md - ktap 在过去是一款前景很好的 tracer，它使用内核中的 lua 虚拟机处理，在没有调试信息的情况下在嵌入式设备上运行的很好  
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-10-31 10:38:05  
Categories: Estuary Documents  
Remark:
---
# Dependence
```
yum install git gcc make libelf-dev
```
# Install
```
  yum install -y ktap
  yum info ktap

```

# Test
```bash
# List all probes:
ktap -le

# List syscall enter probes (or use grep):
ktap -le 'syscalls:sys_enter_*'

# Tracing connect() syscalls by process name:
ktap -e 'trace syscalls:sys_enter_connect { print("connect() by: ", execname); }'

# Tracing heap size changes via brk() syscall:
ktap -e 'trace syscalls:sys_enter_brk { printf("%s called %s", execname, argstr); }'

# Tracing process execution (if probe exists):
ktap -e 'trace sched:sched_process_exec { print("running: ", pid, execname); }'

# Syscall count by syscall:
ktap -e 'var s = {}; trace syscalls:sys_enter_* { s[probename] += 1 } trace_end { print_hist(s); }'

# Syscall count by syscall, with starting text:
ktap -e 'var s = {}; printf("Tracing... Ctrl-C to end.\n");
    trace syscalls:sys_enter_* { s[probename] += 1 } trace_end { print_hist(s); }'

# Syscall count by program:
ktap -e 'var s = {}; trace syscalls:sys_enter_* { s[execname()] += 1 } trace_end { print_hist(s); }'

# read() syscall by requested size distribution:
ktap -e 'var s = {}; trace syscalls:sys_enter_read { s[arg4] += 1 } trace_end { print_hist(s); }'

# read() syscall by returned size distribution:
ktap -e 'var s = {}; trace syscalls:sys_exit_read { s[arg2] += 1 } trace_end { print_hist(s); }'

# Stack profiling at 100 Hz, unsorted (see ktap's stack_profile.kp):
ktap -e 'var s = {}; profile-10ms { s[stack()] += 1 }
    trace_end { for (k, v in pairs(s)) { print(k, v, "\n"); } }'

# Dynamic tracing of tcp_sendmsg() with stack traces:
ktap -e 'var s = {}; trace probe:tcp_sendmsg { s[stack()] += 1 }
    trace_end { for (k, v in pairs(s)) { print(k, v, "\n"); } }'

# Tracing process execution, with simple (-s) info (currently broken):
ktap -s sched:sched_process_exec

yum remove ktap

```
# Result

Tracing heap size changes via brk() syscall:

# ktap -e 'trace syscalls:sys_enter_brk { printf("%s called %s", execname, argstr); }'
Tracing... Hit Ctrl-C to end.
date called sys_brk(brk: 0)
date called sys_brk(brk: 0)
date called sys_brk(brk: 1fdc000)
postgres called sys_brk(brk: 269d000)
postgres called sys_brk(brk: 26ca000)
postgres called sys_brk(brk: 26eb000)
postgres called sys_brk(brk: 270f000)
postgres called sys_brk(brk: 2730000)
postgres called sys_brk(brk: 2752000)
postgres called sys_brk(brk: 2774000)
[...]

Tracing process execution (if probe exists):

# ktap -e 'trace sched:sched_process_exec { print("running: ", pid, execname); }'
running: 	1271	man
running: 	1279	preconv
running: 	1280	tbl
running: 	1282	pager
running: 	1281	nroff
running: 	1283	locale
running: 	1284	groff
running: 	1285	troff
running: 	1286	grotty
[...]

Syscall by syscall name:

# ktap -e 'var s = {}; printf("Tracing... Ctrl-C to end.\n");
    trace syscalls:sys_enter_* { s[probename] += 1 } trace_end { print_hist(s); }'
Tracing... Ctrl-C to end.

                          value ------------- Distribution ------------- count
        sys_enter_rt_sigprocmask |@@@@@@@@@                              260    
          sys_enter_rt_sigaction |@@@@@                                  166    
                  sys_enter_read |@@@                                    107    
                 sys_enter_times |@@                                     80     
                sys_enter_select |@@                                     74     
                 sys_enter_ioctl |@@                                     71     
                 sys_enter_write |@@                                     64     
                  sys_enter_poll |@                                      43     
                  sys_enter_mmap |@                                      32     
                 sys_enter_close |                                       25     
               sys_enter_newstat |                                       25     
              sys_enter_newfstat |                                       16     
                  sys_enter_open |                                       16     
                sys_enter_access |                                       16     
              sys_enter_mprotect |                                       13     
                sys_enter_statfs |                                       11     
               sys_enter_getegid |                                       8      
                sys_enter_munmap |                                       8      
               sys_enter_geteuid |                                       8      
                sys_enter_getuid |                                       8      
                             ... |

read() syscall by returned size distribution:

# ktap -e 'var s = {}; trace syscalls:sys_exit_read { s[arg2] += 1 } trace_end { print_hist(s); }'

                          value ------------- Distribution ------------- count
                             -11 |@@@@@@@@@@@@@@@@@@@@@@@@               50     
                              18 |@@@@@@                                 13     
                              72 |@@                                     6      
                            1024 |@                                      4      
                               0 |                                       2      
                               2 |                                       2      
                             446 |                                       1      
                             515 |                                       1      
                              48 |                                       1  

