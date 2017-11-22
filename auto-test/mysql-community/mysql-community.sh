#!/bin/bash

set -x

cd ../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

pkgs="mysql-community-common mysql-community-server 
	mysql-community-client mysql-community-devel expect"
install_deps "${pkgs}"
print_info $? install-mysql-community

systemctl start mysqld
systemcrl status mysqld | grep running
print_info $? start-mysqld

mysqladmin --version | grep 5.6
print_info $? test-mysql-version

./nonelogin.sh
if [ $? -ne 0 ]; then
    echo 'anonymous login mysql ok'
	print_info $? anonymous-login
else
	print_info $? anonymous-login
fi

mysqladmin -u root password "root"
print_info $? set-root-pwd

./rootlogin.sh
if [ $? -ne 0 ]; then
    echo 'root login mysql ok'
	print_info $? root-login
else
	print_info $? root-login
fi

ifconfig docker0
print_info $? setup-bridge-port

pipework docker0 test1 172.17.0.20/24@172.17.0.1
print_info $? pipework-set-ip

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 10000
spawn docker exec -it test1 bash
expect "/]#"
send "yum install -y net-tools\r"
expect "Complete"
send "ifconfig\r"
expect "/]#"
send "exit\r"
expect eof
EOF

cat ./out.log | grep "/]# ifconfig"
print_info $? exec-container

cat ./out.log | grep "Complete"
print_info $? download-net-tools

cat ./out.log | grep '172.17.0.20'
print_info $? test-pipework-ip

docker stop test1
print_info $? stop-container

docker start test1
print_info $? restart-container

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn docker exec -it test1 bash
expect "/]#"
send "ifconfig\r"
expect "/]#"
send "exit\r"
expect eof
EOF

cat ./out.log | grep '172.17.0.20'
if [ $? ];then
	print_info 0 pipework-none
else
	print_info 1 pipework-none
fi

pipework docker0 test1 172.17.0.21/24@172.17.0.1
print_info $? pipework-reset-ip

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn docker exec -it test1 bash
expect "/]#"
send "ifconfig\r"
expect "/]#"
send ping baidu.com -c 3
expect "/]#"
send "exit\r"
expect eof
EOF

cat ./out.log | grep '172.17.0.21'
print_info $? retest-pipework-ip

cat ./out.log | grep '0% packet loss'
print_info $? test-container-network

yum remove -y pipework
print_info $? remove-pipework

rm -f ./out.log
