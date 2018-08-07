cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -
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
    "centos"|"ubuntu")
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
        print_info 0 read-test
else
        print_info 1 read-test
fi
rm -f sameread.log diffread.log
