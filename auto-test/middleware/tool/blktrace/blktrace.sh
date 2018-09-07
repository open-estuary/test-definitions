
#!/bin/bash 
# Copyright (C) 2018-9-6, estuary Limited.
##Author:mahongxin
##blktrace是一个用户态的工具，用来收集磁盘IO信息中当IO进行到块设备层时的详细信息
set -x
#### Test user id################
check_root
####加载外部文件################
cd ../../../../utils
source       ./sys_info.sh
source       ./sh-test-lib
cd -
##################### Environmental preparation  #######################
pkgs="blktrace"
install_deps "${pkgs}"
print_info $? install-blktrace
 
#######################  testing the step ###########################

# 对进行sda写操作并打印信息
blktrace -d /dev/sda -w 5
print_info $? default_file

###把blktrace采集的信息用blkparse分析好打印出来#####
blktrace -d /dev/sda -w 5 -o - |blkparse -i -
print_info $? display

###把blktrace采集的信息用blkparse分析好打印到指定文件trace中#####
blktrace -d /dev/sda -w 10 -o trace | blkparse -i -
print_info $? output

####将trace文件作为blkparse的输入结果输出到屏幕#####
blkparse -i trace
print_info $? data_analysis



######################  environment  restore ##########################
remove_deps "${pkgs}"
print_info $? remove

rm -rf trace.blktrace.*
rm -rf sda.blktrace.*
