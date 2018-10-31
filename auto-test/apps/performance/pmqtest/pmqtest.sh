#!/bin/bash
### Copyright (C) 2018-9-11, estuary Limited.
### Author:xuexing
### decription: pmqtest启动线程对，并用POSIX消息队列来测量进程间通信的等待时间
set -x
##################加载外部文件######################
source ../../../../utils/sys_info.sh
source ../../../../utils/sh-test-lib

#################### Test user id######################
! check_root && error_msg "Please run this script as root."

#set variable
LOOPS="10000"

##################### Environmental preparation  #############
case "$distro" in
    centos|fedora)
	pkgs="gcc git numactl-devel"
	install_deps "${pkgs}"
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git
	print_info $? download_rt-test

	cd rt-tests
	make all
        #以SMP模式运行进行10000次循环测试
	./pmqtest -S -l "${LOOPS}" | tee runpmq.log
        print_info $? run-pmqtest
	;;
    ubuntu|debian)
	pkgs="rt-tests"
	install_deps "${pkgs}"
        print_info $? install_pkgs
        #以SMP模式运行进行10000次循环测试
	pmqtest -S -l "${LOOPS}" | tee runpmq.log
        print_info $? run-pmqtest
	;;
    opensuse)
	pkgs="gcc git libnuma-devel"
	install_deps "${pkgs}"
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/clrkwllms/rt-tests.git
        print_info $? download_rt-test

        cd rt-tests
        make all
        #以SMP模式运行进行10000次循环测试
	./pmqtest -S -l "${LOOPS}" | tee runpmq.log
        print_info $? run-pmqtest
        ;;
esac

# 提取日志文件
tail -n "$(nproc)" runpmq.log \
    | sed 's/,//g' \
    | awk '{printf("t%s-min-latency pass %s us\n", NR, $(NF-6))};
           {printf("t%s-avg-latency pass %s us\n", NR, $(NF-2))};
           {printf("t%s-max-latency pass %s us\n", NR, $NF)};'  \
    | tee -a pmqresult.txt

# 查看每个CPU是否都有最小延迟
for((i=0;i<$(nproc);i++));
do
    a=`expr $i + 1`
    if [ `cat pmqresult.txt|grep "t$a-min"|sed 's/ //g'` != "" ];then
        echo "$a-min-latency is pass"
    fi
done
print_info $? posix-min

# 查看每个CPU是否都有平均延迟
for((i=0;i<$(nproc);i++));
do
    a=`expr $i + 1`
    if [ `cat pmqresult.txt|grep "t$a-avg"|sed 's/ //g'` != "" ];then
        echo "$a-avg-latency is pass"
    fi
done
print_info $? posix-avg

# 查看每个CPU是否都有最大延迟
for((i=0;i<$(nproc);i++));
do
    a=`expr $i + 1`
    if [ `cat pmqresult.txt|grep "t$a-max"|sed 's/ //g'` != " " ];then
        echo "$a-max-latency is pass"
    fi
done
print_info $? posix-max

############# environment restore ###############
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
