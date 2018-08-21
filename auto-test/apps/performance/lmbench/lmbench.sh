#!/bin/sh

. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh

if [ `whoami` != "root" ];then
	echo "YOu must be the root to run this script" >$2
	exit 1
fi

pkgs="expect"
install_deps "${pkgs}"
print_info $? install-package

wget http://120.31.149.194:18083/test_dependents/lmbench3.tar.gz
print_info $? download_lmbench3

tar zxf lmbench3.tar.gz && rm -rf lmbench3.tar.gz

cd lmbench3
url=`pwd`
touch log.txt


mkdir SCCS && cd SCCS 
touch s.ChangeSet
cd ../

sed -i "s%$O/lmbench : ../scripts/lmbench bk.ver%$O/lmbench : ../scripts/lmbench%g" src/Makefile

cp ../gnu-os scripts/
print_info $? gnu-os_conf

make build
print_info $? build_lmbench3

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 3000
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

print_info $? Confguration_do

make see |tee log.txt

results=`cat log.txt|grep "Communication bandwidths"`
if [ "${results}"x != ""x ];then
	print_info 0 run_pass
else
	print_info 1 run_fail
fi

cd ../

cp -rf lmbench3/* lmbench3-results/
rm -rf lmbench3
print_info $? delete_lmbench3







