#!/bin/bash 
# cyclictest measures event latency in Linux kernel by measuring the amount of
# time that passes between when a timer expires and when the thread which set
# the timer actually runs.

set -x
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh
cd -


case "$distro" in 
    centos|fedora)
	pkgs="gcc git numactl-devel make"
	install_deps "${pkgs}"
	print_info $? install_pkgs
	
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git
	print_info $? download_rt-test

	cd rt-tests
	make all
	cp ./cyclictest /usr/bin/
	;;
    ubuntu|debian)
	pkgs="gcc git libnuma-dev rt-tests make"
	install_deps "${pkgs}"
        print_info $? install_pkgs
	;;
    opensuse)
	pkgs="gcc git libnuma-devel make"
	install_deps "${pkgs}"
        print_info $? install_pkgs
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git
        print_info $? download_rt-test

        cd rt-tests
        make all
        cp ./cyclictest /usr/bin/
        ;;


esac

#The realtime thread that creates five SCHED_FIFO policies by default, with priority 80, runs in 1000,1500,2000,2500,3000 microseconds
cyclictest -p 80 -t5 -n -l 1000 -q | tee cyc_log1.txt
print_info $? cyc_t5-test

#With all memory locked, each kernel runs a measuring thread
cyclictest --smp -p95 -m -l 1000 -q | tee cyc_log2.txt
print_info $? cyc_smp

#Thread priority is 80, the result of different time intervals
cyclictest -t1 -p 80 -n -i 10000 -l 1000 -q |tee cyc_log3.txt
print_info $? cyc_time-interval-10000

cyclictest -t1 -p 80 -n -i 500 -l 1000 -q |tee cyc_log4.txt
print_info $? cyc_time-interval-500


cat cyc_log3.txt |grep "Min"
print_info $? Min_delay

cat cyc_log3.txt |grep "Act"
print_info $? Act_delay

cat cyc_log3.txt |grep "Avg"
print_info $? Avg_delay

cat cyc_log3.txt |grep "Max"
print_info $? Max_delay

#remove the packgs
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
















