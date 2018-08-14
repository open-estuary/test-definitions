---
perf--是一款linux性能分析工具

Hardware platform: D06  
Software Platform: Ubuntu 
Author: Liu beijie<m15177445676@163.com>  
Date: 2018-08-09
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 已在D06单板上部署好Ubuntu系统，安装好perf工具
  2. 系统正常启动
```

# Test Procedure
```
  1. 查看系统能否触发所有perf采样点的事件：perf list 
  2. 查看L3C支持的事件：perf list | grep l3c
  3. L3C是否可以正常正确统计指定的事件：perf stat -a -e hisi_sccl3_l3c5/wr_spipe/ -I 200 sleep 3s &
  4. 查看HHA支持的事件：perf list | grep hha
  5. HHA是否可以正常正确统计指定的事件：perf stat -a -e hisi_sccl3_hha0/rx_wbi/ -I 200 sleep 3s &
  6. 查看DDRC支持的事件：perf list | grep ddrc
  7. DDRC是否可以正常正确统计指定的事件：perf stat -a -e hisi_sccl5_ddrc3/act_cmd/ -I 200 sleep 3s &
  8. 执行perf list | grep l3c查看L3C支持事件，与L3C驱动代码里面的事件是否一致：cd /kernel-dev/drivers/perf/hisilicon,cat hisi_uncore_l3c_pmu.c
  9. 执行perf list | grep hha查看HHA支持事件，与HHA驱动代码里面的事件是否一致：cd /kernel-dev/drivers/perf/hisilicon,cat hisi_uncore_hha_pmu.c
  10. 执行perf list | grep ddrc查看DDRC支持事件，与ddrc驱动代码里面的事件是否一致：cd /kernel-dev/drivers/perf/hisilicon,cat hisi_uncore_ddrc_pmu.c
  11. perf stat 统计到L3C的值总和：perf stat -a -e hisi_sccl3_l3c0/rd_spipe/ -I 200 sleep 3s &，是否等于devmem从寄存器读取的值：busybox devmem 0x90181e00 32
  12. perf stat 统计到HHA的值总和：perf stat -a -e hisi_sccl3_hha0/spill_num/ -I 200 sleep 3s &，是否等于devmem从寄存器读取的值：busybox devmem 0x90121e00 32
  13. perf stat 统计到DDRC的值总和：perf stat -a -e hisi_sccl7_ddrc0/flux_rd/ -I 200 sleep 3s &，是否等于devmem从寄存器读取的值：busybox devmem 0x94d21e00 32
  14. 两片的L3C事件是否都可以正常统计：perf stat -A -C 2 -e hisi_sccl7_l3c18/victim_num/ -I 200 sleep 3s &，perf stat -A -C 50 -e hisi_sccl7_l3c20/victim_num/ -I 200 sleep 3s &
  15. 两片的HHA事件都可以正常统计:perf stat -A -C 2 -e hisi_sccl7_hha4/sdir-hit/ -I 200 sleep 3s &
perf stat -A -C 50 -e hisi_sccl7_hha4/sdir-lookup/ -I 200 sleep 3s &
  16. 两片的DDRC事件都可以正常统计:perf stat -A -C 2 -e hisi_sccl5_ddrc3/act_cmd/ -I 200 sleep 3s &
perf stat -A -C 50 -e hisi_sccl7_ddrc1/flux_wr/ -I 200 sleep 3s &
  17. 两片下CPU支持的事件都可以正常统计，event_number小于1024：perf stat -a -e r6000 -I 200 sleep 3s &

  18. 两片下CPU支持的事件都可以正常统计，event_number大于1024：perf stat -a -e r6008 -I 200 sleep 3s &  
  19. 两片下CPU支持的事件都可以正常统计,指定不同的core进行统计：perf stat -A -C 50 -e r6008 -I 200 sleep 3s & 

  20. L3C是否初始化正常：perf list ，是否可以正常统计指定事件：perf stat -a -e hisi_sccl7_l3c19/back_invalid/ -I 200 sleep 3s &
  21. HHA是否初始化正常：perf list ，是否可以正常统计指定事件：perf stat -a -e hisi_sccl7_hha5/rd_ddr_64b/ -I 200 sleep 3s &
  22. DDRC是否初始化正常：perf list ，是否可以正常统计指定事件：perf stat -a -e hisi_sccl7_ddrc0/flux_rd/ -I 200 sleep 3s &





```

# Expected Result
```
  1. 能查看所有支持的事件，L3C，HHA，DDRC都可以正常正确统计指定的事件
  2. perf list出来的事件和L3C驱动代码里面的事件一致
  3. 两片的L3C，HHA，DDRC事件都可以正常统计
  4. 每个事件都可以正常统计
```
