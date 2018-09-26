#!/bin/bash
# Copyright (C) 2018-9-7, Estuary
# Author: wangsisi
# slabtop命令以实时的方式显示内核“slab”缓冲区的细节信息
:<<!
slabtop
参数说明：
   --delay=n, -d n：每n秒更新一次显示的信息，默认是每3秒；
   --once, -o：显示一次后退出；
   --version, -V：显示版本；
   --help：显示帮助信息
!

! check_root && error_msg "Please run this script as root." 
source ../../../../utils/sys_info.sh
source ../../../../utils/sh-test-lib

###################  Environmental preparation  ######################
check_list="OBJS ACTIVE USE SLABS OBJ/SLAB CACHE SIZE NAME"

#####################    testing the step    ##########################
# run slabtop
for p in ${check_list};do
slabtop -o|egrep -i $p
print_info $? slabtop_${p}
done
slabtop -o|egrep -i "OBJ SIZE"
print_info $? slabtop_OBJ_SIZE

# adjust delay time
slabtop --delay=5 -o
print_info $? delay

# output one time
slabtop --once |tee log.txt 
count=$(grep -i OBJS  log.txt|wc -l )
if [ "$count" = "1" ]; then
   print_info 0 once
else
   print_info 1 once
fi

# check version
slabtop --version|grep -i "slabtop from"
print_info $? version

# help options
slabtop --help|grep -i "Usage"
print_info $? help
