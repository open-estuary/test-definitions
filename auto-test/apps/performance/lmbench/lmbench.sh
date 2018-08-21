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

wget http://192.168.50.122:8083/test_dependents/lmbench3.tar.gz
print_info $? download_lmbench3

tar zxf lmbench3.tar.gz && rm -rf lmbench3.tar.gz

cd lmbench3
url=`pwd`
mkdir log.txt


mkdir SCCS && cd SCCS 
touch s.ChangeSet
cd ../

sed -i "s%$O/lmbench : ../scripts/lmbench bk.ver%$O/lmbench : ../scripts/lmbench%g" src/Makefile

cp ./gns-os /scripts

make build
print_info $? build_lmbench3

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn make results
expect "MULTIPLE COPIES [default 1]"
send "1\r"
expect "Job placement selection:"
send "1\r"
expect "MB [default 180375]"
send "512\r"
expect "SUBSET (ALL|HARWARE|OS|DEVELOPMENT) [default all]"
send "\r"
expect "FASTMEM [default no]"
send "\r"
expect "SLOWFS [default no]"
send "\r"
expect "DISKS [default none]"
send "\r"
expect "REMOTE [default none]"
send "\r"
expect "Processor mhz [default 2398 MHz, 0.4170 nanosec clock]"
send "\r"
expect "FSDIR [default /var/tmp]"
send "\r"
expect "Status output file [default /dev/tty]"
send "\r"
expect "Mail results [default yes]"
send "n\r"
expect "make[1]: Leaving directory '${url}/src'"

expect eof
EOF

print_info $? Confguration_do

make see |tee log.txt
results=`cat log.txt|grep "Communication bandwidths"`
if [ "results"x != ""x ];then
	print_info 0 run_pass
else
	print_info 1 run_fail


cd ../
rm -rf lmbench3
print_info $? delete_lmbench3







