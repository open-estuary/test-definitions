---
CoreMark.md - CoreMark 是用来衡量嵌入式系统中中心处理单元（CPU，或叫做微控制器MCU）性能的标准
Hardware platform: D05 D03 
Software Platform: CentOS  
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-10-28 10:38:05  
Categories: Estuary Documents  
Remark:
---
- **Source code:**
  *Openlab:192.168.1.101:/home/chenzhihui/All-test/coremark/coremark_v1.0.tgz*

- **Test:**
  ```bash
  cd coremark_v1.0
  make
  ```
- **Result:**
  ```bash
[root@CentOS coremark_v1.0]# make
make: Warning: File `linux64/core_portme.mak' has modification time 1251141642 s in the future
make XCFLAGS=" -DPERFORMANCE_RUN=1" load run1.log
make[1]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[1]: Warning: File `linux64/core_portme.mak' has modification time 1251141642 s in the future
make port_prebuild
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141642 s in the future
make[2]: Nothing to be done for `port_prebuild'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make link
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141642 s in the future
gcc -O2 -Ilinux64 -I. -DFLAGS_STR=\""-O2 -DPERFORMANCE_RUN=1  -lrt"\" -DITERATIONS=0 -DPERFORMANCE_RUN=1 core_list_join.c core_main.c core_matrix.c core_state.c core_util.c linux64/core_portme.c -o ./coremark.exe -lrt
Link performed along with compile
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make port_postbuild
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141642 s in the future
make[2]: Nothing to be done for `port_postbuild'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make port_preload
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141642 s in the future
make[2]: Nothing to be done for `port_preload'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
echo Loading done ./coremark.exe
Loading done ./coremark.exe
make port_postload
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141642 s in the future
make[2]: Nothing to be done for `port_postload'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make port_prerun
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141642 s in the future
make[2]: Nothing to be done for `port_prerun'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
./coremark.exe  0x0 0x0 0x66 0 7 1 2000 > ./run1.log
make port_postrun
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141628 s in the future
make[2]: Nothing to be done for `port_postrun'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[1]: warning:  Clock skew detected.  Your build may be incomplete.
make[1]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make XCFLAGS=" -DVALIDATION_RUN=1" load run2.log
make[1]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[1]: Warning: File `linux64/core_portme.mak' has modification time 1251141628 s in the future
make port_prebuild
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141628 s in the future
make[2]: Nothing to be done for `port_prebuild'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make link
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141628 s in the future
gcc -O2 -Ilinux64 -I. -DFLAGS_STR=\""-O2 -DVALIDATION_RUN=1  -lrt"\" -DITERATIONS=0 -DVALIDATION_RUN=1 core_list_join.c core_main.c core_matrix.c core_state.c core_util.c linux64/core_portme.c -o ./coremark.exe -lrt
Link performed along with compile
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make port_postbuild
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141627 s in the future
make[2]: Nothing to be done for `port_postbuild'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make port_preload
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141627 s in the future
make[2]: Nothing to be done for `port_preload'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
echo Loading done ./coremark.exe
Loading done ./coremark.exe
make port_postload
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141627 s in the future
make[2]: Nothing to be done for `port_postload'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make port_prerun
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141627 s in the future
make[2]: Nothing to be done for `port_prerun'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
./coremark.exe  0x3415 0x3415 0x66 0 7 1 2000  > ./run2.log
make port_postrun
make[2]: Entering directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[2]: Warning: File `linux64/core_portme.mak' has modification time 1251141613 s in the future
make[2]: Nothing to be done for `port_postrun'.
make[2]: warning:  Clock skew detected.  Your build may be incomplete.
make[2]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
make[1]: warning:  Clock skew detected.  Your build may be incomplete.
make[1]: Leaving directory `/lmbench-3.0-a9/bin/coremark_v1.0'
Check run1.log and run2.log for results.
See readme.txt for run and reporting rules.
make: warning:  Clock skew detected.  Your build may be incomplete.
  ```
