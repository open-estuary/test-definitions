cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -
set -x
#Verify that the system supports NUMA
if [ `dmesg | grep -i numa` == "No NUMA configuration found" ];then
	print_info 1 support-numa
else
	print_info 0 support-numa
fi

#Test user id
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

#install numactl
case $distro in
    "centos"|"ubuntu"|"debian"|"opensuse"|"fedora")
        pkgs="numactl"
        install_deps "${pkgs}"
        print_info $? install-numactl
esac

#Show inventory of available nodes on the system
available=`numactl -H|grep "available"`
cpus=`numactl -H|grep "cpus"`
size=`numactl -H|grep "size"`
free=`numactl -H|grep "free"`
distances=`numactl -H|grep "distances"`
if [[ $available != "" ]]&&[[ $cpus != "" ]]&&[[ $size != "" ]]&&[[ $free != "" ]]&&[[ $distances != "" ]];then
	print_info 0 shownuma
else
	print_info 1 shownuma
fi
numnodes=`numactl -H|grep -o -P '(?<=available: ).*(?= nodes)'`
for((i=0;i<$numnodes;i++));
do
nodecpu="numactl -H|grep -o -P '(?<=node $i cpus:).*'"
nodecpus=`eval $nodecpu`
if [ "$nodecpus" != "" ];then
        print_info 0 node${i}cpu
else
        print_info 1 node${i}cpu
fi

nodesize="numactl -H|grep -o -P '(?<=node $i size: ).*(?= MB)'"
nodesizes=`eval $nodesize`
if [[ "$nodesizes" -gt 0 ]];then
        print_info 0 node${i}size
else
        print_info 1 node${i}size
fi
nodefree="numactl -H|grep -o -P '(?<=node $i free: ).*(?= MB)'"
nodefrees=`eval $nodefree`
if [[ "$nodefrees" -gt 0 ]];then
        print_info 0 node${i}free
else
        print_info 1 node${i}free
fi
done

#Verify the total number of CPU and memory
numcpus=`cat /proc/cpuinfo| grep "processor"| wc -l`
nummems=`free -m |grep Mem | awk '{print $2}'`
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
if [ $numcpus -eq $sumcpus ]&&[ `expr $nummems - $summems` -lt 5 ];then
        print_info 0 summary
else
        print_info 1 summary
fi
#Show NUMA policy settings of the current process
policy=`numactl -s|grep "policy"`
preferred=`numactl -s|grep "preferred"`
physcpubind=`numactl -s|grep "physcpubind"`
cpubind=`numactl -s|grep "cpubind"`
nodebind=`numactl -s|grep "nodebind"`
membind=`numactl -s|grep "membind"`
if [[ $policy != "" ]]&&[[ $preferred != "" ]]&&[[ $physcpubind != "" ]]&&[[ $cpubind != "" ]]&&[[ $nodebind != "" ]]&&[[ $membind != "" ]];then
	print_info 0 numapolicy
else
	print_info 1 numapolicy
fi

#View the current policy after setting up--default preferred interleave bind
if [ `numactl -s|grep "policy"|awk '{print $2}'` = "default" ];then
	print_info 0 default-policy
else
	print_info 1 default-policy
fi

if [ `numactl --preferred 1 numactl --show |grep "policy"|awk '{print $2}'` = "preferred" ];then
	print_info 0 preferred-policy
else
        print_info 1 preferred-policy
fi

if [ `numactl --interleave=all numactl --show|grep "policy"|awk '{print $2}'` = "interleave" ];then
	print_info 0 interleave-policy
else
	print_info 1 interleave-policy
fi

if [ `numactl -m 0 numactl --show|grep "policy"|awk '{print $2}'` = "bind" ];then
	print_info 0 bind-policy
else
	print_info 1 bind-policy
fi
#Verify that access memory in the same node is faster than the different nodes--write
numactl --cpubind=0 --membind=0 dd if=/dev/zero of=/dev/shm/A bs=1M count=1000 2>> samewrite.log
numactl --cpubind=0 --membind=1 dd if=/dev/zero of=/dev/shm/A bs=1M count=1000 2>> diffwrite.log
SW=`grep -o -P '(?<=s, ).*(?= GB/s)' samewrite.log`
DW=`grep -o -P '(?<=s, ).*(?= GB/s)' diffwrite.log`
if [ `expr $SW \> $DW` -eq 1 ];then
	print_info 0 write-test
else
	print_info 1 write-test
fi
rm -f samewrite.log diffwrite.log

#Verify that access memory in the same node is faster than the different nodes--read
numactl --cpubind=0 --membind=0 dd if=/dev/shm/A of=/dev/zero bs=1M count=1000 2>> sameread.log
numactl --cpubind=0 --membind=1 dd if=/dev/shm/A of=/dev/zero bs=1M count=1000 2>> diffread.log
SR=`grep -o -P '(?<=s, ).*(?= GB/s)' sameread.log`
DR=`grep -o -P '(?<=s, ).*(?= GB/s)' diffread.log`
if [ `expr $SR \> $DR` -eq 1 ];then
        #print_info 0 read-test
else
        #print_info 1 read-test
fi
rm -f sameread.log diffread.log

#remove the numactl
case $distro in
    "centos"|"ubuntu"|"debian"|"opensuse"|"fedora")
        pkgs="numactl"
        remove_deps "${pkgs}"
        print_info $? remove-numactl
esac
