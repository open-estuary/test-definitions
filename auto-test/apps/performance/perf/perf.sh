# =====================
# Filename: perf
# Author:
# Email:
# Date:
# Description:
# ====================

###### specify interpeter path ######

#!/bin/bash

###### importing environment variable ######

cd ../../../../utils
   source ./sys_info.sh
   source ./sh-test-lib
cd -

###### check root ######

! check_root && error_msg "Please run this script as root."

###### importing variables ######

version="4.12.0"
from_repo="Estuary"
package="perf"

###### install ######

for P in ${package};do
    echo "$P install"

case $distro in
    "centos" )
         yum install -y "$P"
         print_info $? "$P"
         ;;
 esac

 ###### testing step ######

 ## Check the package version && source
 from=$(yum info $P | grep "From repo" | awk '{print $4}')
 if [ "$from" = "$from_repo" ];then
     echo "$P source is $from : [pass]" | tee -a ${RESULT_FILE}
 else
     rmflag=1
     if [ "$from" != "Estuary" ];then
         yum remove -y $P
         yum install -y $P
         from=$(yum info $P | grep "From repo" | awk '{print $4}')
        if [ "$from" = "$from_repo"  ];then
           echo "$P install  [pass]" | tee -a ${RESULT_FILE}
        else
           echo "$P source is $from : [failed]" | tee -a ${RESULT_FILE}
        fi
     fi
 fi

print_info $? source-perf
 vers=$(yum info $P | grep "Version" | awk '{print $3}')
 if [ "$vers" = "$version"  ];then
     echo "$P version is $vers : [pass]" | tee -a ${RESULT_FILE}
 else
     echo "$P version is $vers : [failed]" | tee -a ${RESULT_FILE}
 fi
done

print_info $? perf-version

## check the hisi perf 
perf list |grep hisi*
print_info $? hisi_*

## check the hisi_ddrc* perf
perf stat -a -e hisi_ddrc0_7/flux_read/ -i 200 sleep 9s &
print_info $? hisi_ddrc*

## check the hisi_l3c* perf
perf stat -a -e hisi_l3c3_7/read_hit/ -i 200 sleep 9s &
print_info $P hisi_l3c*

## check the hisi_mn* perf
perf stat -a -e hisi_mn_7/dvm_op_req/ -i 200 sleep 9s &
print_info $? hisi_mn*

###### restore environment ######

## remove the perf package
yum remove -y "$P"
print_info $? remove
