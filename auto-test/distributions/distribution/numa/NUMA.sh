#!/bin/bash

# Filename: NUMA.sh
# Author: xuexing4@hisilicon.com
# Description: NUMA--Non Uniform Memory Access Architecture
# Latest: 2018-08-30

cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -
set -x

#Test user id
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

numcpus=`cat /proc/cpuinfo| grep "processor"| wc -l`
nummems=`free -m |grep Mem | awk '{print $2}'`

#Verify that the system supports NUMA
support_numa ()
{
    if [ `dmesg | grep -i numa` == "No NUMA configuration found" ];then
        print_info 1 support-numa
	exit 1
    else
        print_info 0 support-numa
    fi
}

support_numa

#install numactl
case $distro in
    "centos"|"ubuntu"|"debian"|"opensuse"|"fedora")
        pkgs="numactl"
        install_deps "${pkgs}"
        print_info $? install-numactl
esac

numnodes=`numactl -H|grep -o -P '(?<=available: ).*(?= nodes)'`

#Show inventory of available nodes on the system
show_numa ()
{
    available=`numactl -H|grep "available"`
    cpus=`numactl -H|grep "cpus"`
    size=`numactl -H|grep "size"`
    free=`numactl -H|grep "free"`
    distances=`numactl -H|grep "distances"`
    if [[ $available != "" ]]&&[[ $cpus != "" ]]&&[[ $size != "" ]]&&[[ $free != "" ]]&&[[ $distances != "" ]];then
	    for((i=0;i<$numnodes;i++));
	    do
	        nodecpu="numactl -H|grep -o -P '(?<=node $i cpus:).*'"
                nodecpus=`eval $nodecpu`
		nodesize="numactl -H|grep -o -P '(?<=node $i size: ).*(?= MB)'"
                nodesizes=`eval $nodesize`
		nodefree="numactl -H|grep -o -P '(?<=node $i free: ).*(?= MB)'"
                nodefrees=`eval $nodefree`
		if [[ $nodecpus != "" ]]&&[[ $nodesizes -gt 0 ]]&&[[ $nodefrees -gt 0 ]];then
		    echo " node$i is pass "	
		fi
            done
    fi

    print_info $? show-numa
}

show_numa

#Verify the total number of CPU and memory
total_number ()
{
    sumcpus=0
    summems=0
    for((i=0;i<$numnodes;i++));
    do	
        numcpu=`numactl -H|grep "node ${i} cpus"|awk -F ":" '{print $2}'|wc -w`
        nummem=`numactl -H|grep "node ${i} size"|grep -o -P '(?<=size: ).*(?= MB)'`
        a=$sumcpus
        b=$summems
        declare -i sumcpus=$a+$numcpu
        declare -i summems=$b+$nummem
    done
    if [ $numcpus -eq $sumcpus ]&&[ `expr $nummems - $summems` -lt 3 ];then
            print_info 0 total-number
    else
            print_info 1 total-number
    fi
}

total_number

#Show NUMA policy settings of the current process
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

#View the current policy after setting up--default preferred interleave bind
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

# Verification of cpu binding and memory binding functions 
mem_bind ()
{
    for((i=0;i<$numnodes;i++));
    do
        if [ `numactl -m $i numactl -s|grep "membind"|awk '{print $2}'` = "$i" ];then
            a=`expr $i + 2`
            numahit1=`numastat -c|grep "Numa_Hit"|awk '{print $'$a'}'`
            numactl -m $i dd if=/dev/zero of=/dev/shm/b bs=100M count=100
            numahit2=`numastat -c|grep "Numa_Hit"|awk '{print $'$a'}'`
            if [ `expr $numahit2 - $numahit1` -gt 999 ];then
            	echo " bindmems${i} is pass "
	    fi
        fi
    done

    print_info $? mem-bind
}

mem_bind

cpu_bind ()
{
    for((i=0;i<$numnodes;i++));
    do
        if [ `numactl -N $i numactl -s|grep -w "cpubind"|awk '{print $2}'` = "$i" ];then
            a=`expr $i + 2`
            numahit1=`numastat -c|grep "Numa_Hit"|awk '{print $'$a'}'`
            numactl -m $i dd if=/dev/zero of=/dev/shm/b bs=100M count=100
            numahit2=`numastat -c|grep "Numa_Hit"|awk '{print $'$a'}'`
            if [ `expr $numahit2 - $numahit1` -gt 999 ];then
                    echo " bindcpus${i} is pass "
	    fi
        fi    
    done

    print_info $? cpu-bind
}

cpu_bind

#remove the numactl
case $distro in
    "centos"|"ubuntu"|"debian"|"opensuse"|"fedora")
        pkgs="numactl"
        remove_deps "${pkgs}"
        print_info $? remove-numactl
esac
