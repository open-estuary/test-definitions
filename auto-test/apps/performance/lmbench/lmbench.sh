#!/bin/bash

set -x

cd ../../../../utils
source ./sh-test-lib
source ./sys_info.sh

! check_root && error_msg "Please run this script as root."

##################### Environmental preparation ###################
url=`pwd`

case "${distro}" in
    centos|fedora)
	pkgs="expect wget gcc-c++ gcc"
	install_deps "${pkgs}"
	print_info $? install-package
	;;
    ubuntu|debian)
	pkgs="expect wget g++ gcc"
        install_deps "${pkgs}"
        print_info $? install-package
        ;;
    opensuse)
	pkgs="expect wget gcc"
        install_deps "${pkgs}"
        print_info $? install-package
        ;;

esac

wget http://120.31.149.194:18083/test_dependents/lmbench3.tar.gz
if [ $? -eq 0 ];then
	info_msg "download pass"
else
	info_msg "download fail"
fi

tar zxf lmbench3.tar.gz && rm -rf lmbench3.tar.gz


cd lmbench3

mkdir SCCS && cd SCCS 
touch s.ChangeSet
cd ../

sed -i "s%$O/lmbench : ../scripts/lmbench bk.ver%$O/lmbench : ../scripts/lmbench%g" src/Makefile

cp ../gnu-os scripts/
if [ $? -eq 0 ];then
        info_msg "cp_gnu-os pass"
else
        info_msg "cp_gnu-os fail"
fi


##################### the testing step ###########################
make build
print_info $? build_lmbench3

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 300000
spawn make results
expect "MULTIPLE COPIES"
send "1\r"
expect "Job placement selection"
send "1\r"
expect "MB"
send "512\r"
expect "SUBSET"
send "\r"
expect "FASTMEM"
send "\r"
expect "SLOWFS"
send "\r"
expect "DISKS"
send "\r"
expect "REMOTE"
send "\r"
expect "Processor mhz"
send "\r"
expect "FSDIR"
send "\r"
expect "Status output file"
send "\r"
expect "Mail results"
send "n\r"
expect "Leaving directory '${url}/src'"

expect eof
EOF

print_info $? make_results


make see |tee log.txt

results=`cat log.txt|grep "Communication bandwidths"`
if [ "${results}"x != ""x ];then
	print_info 0 run_pass
else
	print_info 1 run_fail
fi

cd ../

if [ ! -d "lmbench3-results" ];then
	mkdir lmbench3-results
fi

####################  environment  restore ##############
remove_deps "${pkgs}"
print_info $? remove_pkgs

cp -rf lmbench3/* lmbench3-results/
rm -rf lmbench3







