#!/bin/bash 
set -x
# pmqtest start pairs of threads and measure the latency of interprocess
# communication with POSIX messages queues.
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib

LOOPS="10000"

! check_root && error_msg "Please run this script as root."

case "$distro" in
    centos|fedora)
	pkgs="gcc git numactl-devel"
	install_deps "${pkgs}"
	print_info $? install_pkgs

	git clone git://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git
	print_info $? download_rt-test

	cd rt-tests
	make all
	cp ./cyclictest /usr/bin/

	cyclictest -S -l "${LOOPS}" | tee runpmq.log
        print_info $? run-pmqtest
	;;
    ubuntu|debian)
	pkgs="rt-tests"
	install_deps "${pkgs}"
        print_info $? install_pkgs

	pmqtest -S -l "${LOOPS}" | tee runpmq.log
        print_info $? run-pmqtest
	;;
    opensuse)
	pkgs="gcc git libnuma-devel"
	install_deps "${pkgs}"
        print_info $? install_pkgs
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git
        print_info $? download_rt-test

        cd rt-tests
        make all
        cp ./cyclictest /usr/bin/

	cyclictest -S -l "${LOOPS}" | tee runpmq.log
        print_info $? run-pmqtest
        ;;
esac

# Parse test log.
tail -n "$(nproc)" runpmq.log \
    | sed 's/,//g' \
    | awk '{printf("t%s-min-latency pass %s us\n", NR, $(NF-6))};
           {printf("t%s-avg-latency pass %s us\n", NR, $(NF-2))};
           {printf("t%s-max-latency pass %s us\n", NR, $NF)};'  \
    | tee -a pmqresult.txt

for((i=0;i<$(nproc);i++));
do
    a=`expr $i + 1`
    if [ `cat pmqresult.txt|grep "t$a-min"|sed 's/ //g'` != "" ];then
        echo "$a-min-latency is pass"
    else
	print_info 1 posix-min
    fi
done
print_info $? posix-min

for((i=0;i<$(nproc);i++));
do
    a=`expr $i + 1`
    if [ `cat pmqresult.txt|grep "t$a-avg"|sed 's/ //g'` != "" ];then
        echo "$a-avg-latency is pass"
    else
        print_info 1 posix-avg
    fi
done
print_info $? posix-avg

for((i=0;i<$(nproc);i++));
do
    a=`expr $i + 1`
    if [ `cat pmqresult.txt|grep "t$a-max"|sed 's/ //g'` != " " ];then
        echo "$a-max-latency is pass"
    else
        print_info 1 posix-max
    fi
done
print_info $? posix-max

rm -f runpmq.log pmqresult.txt
case "$distro" in
    centos|fedora|opensuse)
	rm -rf rt-tests
	remove_deps "${pkgs}"
	print_info $? remove_pkgs
	;;
    ubuntu|debian)
	remove_deps "${pkgs}"
        print_info $? remove_pkgs
	;;
esac
