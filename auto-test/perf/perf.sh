#!/bin/sh -e
set -x
cd ../../utils
    . ./sys_info.sh
      ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="4.12.0"
from_repo="Estuary"
package="perf"

for P in ${package};do
    echo "$P install"
# Install package
case $distro in
    "centos" )
         yum install -y "$P"
         print_info $? "$P"
         ;;
 esac
# Check the package version && source
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

 vers=$(yum info $P | grep "Version" | awk '{print $3}')
 if [ "$vers" = "$version"  ];then
     echo "$P version is $vers : [pass]" | tee -a ${RESULT_FILE}
 else
     echo "$P version is $vers : [failed]" | tee -a ${RESULT_FILE}
 fi
done

# check the hisi perf 
perf list |grep hisi*
print_info $? hisi_*

# check the hisi_ddrc* perf
perf stat -a -e hisi_ddrc0_7/flux_read/ sleep 9
print_info $? hisi_ddrc*

# check the hisi_l3c* perf
perf stat -a -e hisi_l3c3_7/read_hit/ sleep 9
print_info $P hisi_l3c*

# check the hisi_mn* perf
perf stat -a -e hisi_mn_7/dvm_op_req/ sleep 9
print_info $? hisi_mn*

# remove the perf package
yum remove -y "$P"
print_info $? remove
