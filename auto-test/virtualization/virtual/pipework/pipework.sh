#!/bin/bash

set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

pkgs="docker expect net-tools"
install_deps "${pkgs}"
print_info $? install-package

pkgs="pipework"
install_deps "${pkgs}"
print_info $? install-pipework

pipework -h | grep Syntax
print_info $? pipework-help

systemctl start docker

docker pull centos
print_info $? docker-pull-centos

docker run -idt  --net=none --name test1  centos /bin/bash
print_info $? docker-run-centos

docker ps | grep centos
print_info $? look-container

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

systemctl stop docker

yum remove -y pipework
print_info $? remove-pipework

rm -f ./out.log
