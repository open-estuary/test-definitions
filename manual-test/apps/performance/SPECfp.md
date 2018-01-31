---
SPECfp.md - SPECfp是计算机基准规范(SPEC)标准测试套件的组件，用于测试CPU浮点数处理能力
Hardware platform: D05  
Software Platform: CentOS  
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2016-12-29 10:38:05  
Categories: Estuary Documents  
Remark:
---
- **Dependency:**
  ```bash
  yum install automake
  yum install numactl
  yum install gcc*
  yum install libgfortran
  yum install *cmp
  yum install cmp*

  ```
- **Source code:**
  *Openlab:192.168.1.101:/home/chenzhihui/Ali-test/speccpu2006*

- **Build:**
  ```bash
  export FORCE_UNSAFE_CONFIGURE=1
  SPEC_DIR=speccpu2006
  cd  $SPEC_DIR/tools/src && echo y | ./buildtools

  ```
- **Test:**
  ```bash
  SPEC_DIR=speccpu2006
  cd $SPEC_DIR
  . ./shrc
  ./bin/runspec -c config/lemon-2cpu.cfg fp --rate 1 -n 1 -noreportable
  ./bin/runspec -c config/lemon-2cpu.cfg fp --rate 32 -n 1 -noreportable
  ./bin/runspec -c config/lemon-2cpu.cfg fp --rate 64 -n 1 -noreportable
  ```
- **Result:**
  ```bash
[root@CentOS speccpu2006]# ./bin/runspec -c config/lemon-2cpu.cfg fp --rate 1 -n   1 -noreportable
runspec v6674 - Copyright 1999-2011 Standard Performance Evaluation Corporation
Using 'unknown' tools
Reading MANIFEST... 19896 files
Loading runspec modules................
Locating benchmarks...found 31 benchmarks in 6 benchsets.
Neither config file 'config/lemon-2cpu.cfg' nor 'config/lemon-2cpu.cfg.cfg' exist in /root/speccpu2006/config!

There is no log file for this run.

*
* Temporary files were NOT deleted; keeping temporaries such as
* /root/speccpu2006/tmp
* (These may be large!)
*
runspec finished at Thu Jan 12 15:58:16 2017; 2 total seconds elapsed
[root@CentOS speccpu2006]# ./bin/runspec -c config/lemon-2cpu.cfg fp --rate 32 -n 1 -noreportable
runspec v6674 - Copyright 1999-2011 Standard Performance Evaluation Corporation
Using 'unknown' tools
Reading MANIFEST... 19896 files
Loading runspec modules................
Locating benchmarks...found 31 benchmarks in 6 benchsets.
Neither config file 'config/lemon-2cpu.cfg' nor 'config/lemon-2cpu.cfg.cfg' exist in /root/speccpu2006/config!

There is no log file for this run.

*
* Temporary files were NOT deleted; keeping temporaries such as
* /root/speccpu2006/tmp
* (These may be large!)
*
runspec finished at Thu Jan 12 15:58:24 2017; 2 total seconds elapsed
[root@CentOS speccpu2006]# ./bin/runspec -c config/lemon-2cpu.cfg fp --rate 64 -n 1 -noreportable 
runspec v6674 - Copyright 1999-2011 Standard Performance Evaluation Corporation
Using 'unknown' tools
Reading MANIFEST... 19896 files
Loading runspec modules................
Locating benchmarks...found 31 benchmarks in 6 benchsets.
Neither config file 'config/lemon-2cpu.cfg' nor 'config/lemon-2cpu.cfg.cfg' exist in /root/speccpu2006/config!

There is no log file for this run.

*
* Temporary files were NOT deleted; keeping temporaries such as
* /root/speccpu2006/tmp
* (These may be large!)
*
runspec finished at Thu Jan 12 15:58:30 2017; 1 total seconds elapsed

  ```
