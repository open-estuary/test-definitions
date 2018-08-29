#!/bin/sh 

# The purpose of UnixBench is to provide a basic indicator of the
# performance of a Unix-like system

# shellcheck disable=SC1091

. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh


if [ `whoami` != 'root' ]; then
        echo "YOu must be the root to run this script" >$2
        exit 1
fi

#install package
pkgs="gcc perl wget make unzip"
install_deps "${pkgs}"
print_info $? install-package

#Download UnixBench5.1.3
wget http://192.168.50.122:8083/test_dependents/unixbench.zip
print_info $? download_unixbench

unzip unixbench.zip && rm -rf unixbench.zip
cd byte-unixbench-master/UnixBench/

# -march=native and -mtune=native are not included in Linaro ARM toolchian
# that older than v6. Comment they out here.
cp Makefile Makefile.bak
sed -i 's/OPTON += -march=native -mtune=native/#OPTON += -march=native -mtune=native/' Makefile


#run unixbench
make
./Run -c 1
echo  "======= running 1 parallel copy of tests ======= "
print_info $? run_results

today=`date --date='0 days ago' +%Y-%m-%d`
host_name=`hostname`
cd results
cat ${host_name}-${today}-01|grep "Dhrystone 2 using register variables"
print_info $? Dhrystone_test

cat ${host_name}-${today}-01|grep "Double-Precision Whetstone"
print_info $? Double-Precision_test

cat ${host_name}-${today}-01|grep "Execl Throughput"
print_INFO $? Execl-Throughput_test

cat ${host_name}-${today}-01|grep "File Copy"
print_info $? File-Copy_test

cat ${host_name}-${today}-01|grep "Pipe Throughput"
print_info $? Pipe-Throughput_test

cat ${host_name}-${today}-01|grep "Pipe-based Context Switching"
print_info $? Pipe-based_test

cat ${host_name}-${today}-01|grep "Process Creation"
print_info $? Process-Creation_test

cat ${host_name}-${today}-01|grep "Shell Scripts"
print_info $? Shell-Scripts_test

cat ${host_name}-${today}-01|grep "System Call Overhead"
print_info $? System-Call-Overhead_test

score=`cat ${host_name}-${today}-01|grep "System Benchmarks Index Score"|awk '{print $5}'`
echo "the sore of 1 parallel copies is ${score}"
print_info $? score_1

# Run the number of CPUs copies.
cd ../
NPROC=$(nproc)
if [ "${NPROC}" -gt 1 ]; then
	./Run -c "${NPROC}"

	echo  "======= running ${NPROC} parallel copy of tests ======= "
fi

cd results
score=`cat ${host_name}-${today}-02|grep "System Benchmarks Index Score"|awk '{print $5}'`
echo "the sore of ${NPROC} parallel copies is ${score}"
print_info $? score_${NPROC}


cd ../../../
rm -rf byte-unixbench-master
print_info $? delete_Unixbench

