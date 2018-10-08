---
Ftrace.md - ftrace是内核内置的跟踪器,可用于跟踪内核函数调用,中断延迟,调度延迟, 系统调用等,在debugfs下使用文本命令交互,很合适内核开发者使用  
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian Fedora Opensuse
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-10-31 10:38:05  
Categories: Estuary Documents  
Remark:
---

# Dependency
```
#查看系统没有自动挂载debugfs文件系统，如果没有手动挂载
  mount -t debugfs nodev /sys/kernel/debug

```

# Test
```bash
#查看当前是否可以使用fuction插件追踪器
  cd /sys/kernel/debug/tracing
  cat available_tracers | grep function
#能否设置函数过滤器，仅记录schedule
  echo schedule > set_ftrace_filter
#能否将函数追踪器function写入current_tracer文件
  echo function > current_tracer
#读取追踪结果是否成功
  head trace
#能否使用多个函数名称或通配符向过滤器指定模式
  echo 'irq*' > set_ftrace_filter
  head trace
#能否在参数前面加上:mod:，可以仅追踪指定模块中包含的函数（注意，模块必须已加载）
  echo 'write*:mod:ext3' > set_ftrace_filter
  head trace
#能否清空trace
  echo 0 > tracing_on
  echo 0 > trace
  cat trace
#能否使用fuction_graph追踪器
  echo function_graph > current_tracer
#查看fuction_graph跟踪结是否正常果
  cat trace | head -10
#启用某一事件追踪器
  echo sched_wakeup >> set_event
  cat set_event
#禁用某一事件追踪器
  echo '!sched_wakeup' >> set_event
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
