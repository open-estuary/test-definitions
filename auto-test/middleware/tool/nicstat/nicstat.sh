

#!/bin/bash
### 2018-9-13 estuary Limited
###Author:mahongxin
###nicstat:网络流量统计工具
set -x
#########加载公共函数文件######
cd ../../../../utils
    source        ./sys_info.sh
    source        ./sh-test-lib
cd -
##########判断当前用户是否是root#####
! check_root && error_msg "Please run this script"
###########nicstat选项#############
### -s：显示摘要信息
### -x: 显示扩展的输出
### -M：以Mbps显示吞吐量，而不是默认的kB/s
### -p: 以解析后的输出格式显示
### -t: tcp流量统计
### -u: ucp流量统计
### -a: 等同于'-x -t -u'
### -l: 只显示端口状态
### -i：指定端口

########################Environmental preparation #######
version="1.95"
from_repo="Estuary"
pkgs="nicstat"

case $distro in
    "centos"|"debian"|"fedora"|"ubuntu")
        install_deps "${pkgs}"
        print_info $? nicstat 
         ;;
 esac

##################testing tht stp#####################
###每一秒显示一次显示5次
nicstat 1 5
print_info $? statistics

###测试tcp
nicstat -t 1 5
print_info $? tcp

###测试udp 
nicstat -u 1 5
print_info $? udp

###只显示正在使用的网口的流量 
inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|awk '{print$1}'|head -1`
nicstat -i $inet
print_info $? network

###以Mbits/sec为单位显示吞吐量
nicstat -M
print_info $? Mbits/sec

###显示端口状态
nicstat -l
print_info $? list_interface

###显示摘要信息（只是接收和发送的数据量）
nicstat -s
print_info $? summary
##############举例说明#######
#nicstat 1 5
#Time          Int   rKB/s   wKB/s   rPk/s   wPk/s    rAvs    wAvs %Util    Sat
#15:30:40  docker0    0.00    0.00    0.00    0.00    0.00    0.00  0.00   0.00
#15:30:40       lo    0.00    0.00    0.00    0.00    0.00    0.00  0.00   0.00
#15:30:40 enahisic2i0    0.23    1.34    3.00    6.00   79.67   228.7  0.00   0.00
#Time列：表示当前采样的响应时间
#lo and enahisisic2i0 : 网卡名称
#rkB/s:每秒接收的千字节数
#wKB/s:每秒写的千字节数
#rPk/s：每秒接收的数据包数目
#wPk/s:每秒写的数据包的数目
#rAvs:接收数据包的平均大小
#wAvs:传输的数据包平均大小
#%Utils:网卡利用率（百分比）
#Sat:网卡每秒的错误数
######################## environment restore##############
remove_deps "${pkgs}"
print_info $? remove-pkgs
