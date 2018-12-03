# ====================
# Filename: numa
# Author: 
# Email:
# Date: 
# Description: NUMA--Non Uniform Memory Access Architecture
# ====================

###### specify interpeter bath ######

#!/bin/bash

###### importing environment variable ######

cd ../../../../utils
   source ./sys_info.sh
   source ./sh-test-lib
cd -

###### check root ######

! check_root && error_msg "Please run the script as root."

## Verify that the system supports numa

support_numa ()
{
    if [ `dmesg | grep -i numa` == "No numa configuration found" ];then
        print_info 1 support-numa
	exit 1
    else
        print_info 0 support-numa
    fi
}

support_numa

###### install ######

case $distro in
    "centos"|"debian")
        pkgs="numactl"
        install_deps "${pkgs}"
        print_info $? numactl-install
esac

###### test step ######

## Show numa
numactl --hardware
print_info $? numa-info

## Show numastat
numastat
print_info $? numastat

## Show numa bind info
numactl -s
print_info $? numa-bind-info

## Verify the total number of CPU and memory
cat /proc/cpuinfo |grep "processor" |wc -l
free -g |grep Mem |awk '{print $2}'

## Show NUMA policy settings of the current process
numa_policy ()
{
    policy=`numactl -s|grep "policy"`
    preferred=`numactl -s|grep "preferred"`
    physcpubind=`numactl -s|grep "physcpubind"`
    cpubind=`numactl -s|grep "cpubind"`
    nodebind=`numactl -s|grep "nodebind"`
    membind=`numactl -s|grep "membind"`
    if [[ $policy != "" ]]&&[[ $preferred != "" ]]&&[[ $physcpubind != "" ]]&&[[ $cpubind != "" ]]&&[[ $nodebind != "" ]]&&[[ $membind != "" ]];then
    	print_info 0 numa-policy
    else
    	print_info 1 numa-policy
    fi
}

numa_policy

## View the current policy after setting up--default preferred interleave bind
setup_policy ()
{
    if [ `numactl -s|grep "policy"|awk '{print $2}'` = "default" ];then
        if [ `numactl --preferred 1 numactl --show |grep "policy"|awk '{print $2}'` = "preferred" ];then
            if [ `numactl --interleave=all numactl --show|grep "policy"|awk '{print $2}'` = "interleave" ];then
                if [ `numactl -m 0 numactl --show|grep "policy"|awk '{print $2}'` = "bind" ];then
                	print_info 0 setup-policy
                else
                	print_info 1 setup-policy
		fi
	    fi
	fi
    fi
}
 
setup_policy

## Verification of cpu binding and memory binding functions 
##print_info $? mem-bind
##print_info $? cpu-bind

###### restore environment ######

## remove the numactl
case $distro in
    "centos"|"debian")
        pkgs="numactl"
        remove_deps "${pkgs}"
        print_info $? remove-numactl
esac
