---
Ftrace.md - ftrace是内核内置的跟踪器,可用于跟踪内核函数调用,中断延迟,调度延迟, 系统调用等,在debugfs下使用文本命令交互,很合适内核开发者使用  
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-10-31 10:38:05  
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  mount -t debugfs nodev /sys/kernel/debug

```

# Test
```bash
  cd /sys/kernel/debug/tracing
  cat available_tracers
  echo schedule > set_ftrace_filter
  echo function > current_tracer
  head trace
  echo ‘irq*’ > set_ftrace_filter
  head trace
  echo 'write*:mod:ext3' > set_ftrace_filter
  head trace
  echo function_graph > current_tracer
  cat trace | head -10
  echo sys_enter_nice >> set_event
  cat set_event
  echo '!sys_enter_nice' >> set_event
  cat set_event
```

# Result
```bash
# tracer: function

#

#           TASK-PID    CPU#   TIMESTAMP  FUNCTION

#              | |       |          |         |

           bash-29903 [003] 262746.977929: schedule <-sysret_careful

    kworker/3:1-239   [003]262746.977937: schedule <-worker_thread

         <idle>-0     [000]262746.977940: schedule <-cpu_idle

           bash-29903 [003] 262746.977943: schedule <-schedule_timeout

           sshd-2562  [000] 262746.977994:schedule <-schedule_hrtimeout_range_clock

         <idle>-0     [003]262746.979523: schedule <-cpu_idle
```
