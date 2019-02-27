#!/bin/bash

set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

if [ "${ci_http_addr}"x = "http://172.19.20.15:8083"x ];then
        echo -e "nameserver 10.98.48.39\nnameserver 10.72.55.82\nnameserver 10.72.255.100\ndomain huawei.com\nnameserver 10.129.54.130\nnameserver 8.8.8.8" >> /etc/resolv.conf
mkdir -p /etc/systemd/system/docker.service.d
echo "[Service]
Environment=\"HTTP_PROXY=http://172.19.20.11:3128\" \"HTTPS_PROXY=https://172.19.20.11:3128\" \"NO_PROXY=*.huawei.com\"" > /etc/systemd/system/docker.service.d/http-proxy.conf
        systemctl daemon-reload
        systemctl restart docker
fi

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
#print_info $? docker-pull-centos

docker run -idt  --net=none --name test1  centos /bin/bash
print_info $? docker-run-centos

docker ps | grep centos
print_info $? look-container

ifconfig docker0
print_info $? setup-bridge-port

pipework docker0 test1 172.17.0.20/24@172.17.0.1
print_info $? pipework-set-ip


if [ "${ci_http_addr}"x = "http://172.19.20.15:8083"x ];then 

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 10000
spawn docker exec -it test1 bash

expect "/]#"
send "export http_proxy=172.19.20.11:3128 && export https_proxy=172.19.20.11:3128\r"

expect "/]#"
send "yum install -y net-tools\r"
expect "Complete"
send "ifconfig\r"
expect "/]#"
send "exit\r"
expect eof
EOF

else

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

fi

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
#print_info $? retest-pipework-ip

if [ "${ci_http_addr}"x = "http://172.19.20.15:8083"x ];then
    docker ps -a|grep test1|awk '{print $1}'|xargs docker rm -f
fi


cat ./out.log | grep '0% packet loss'
#print_info $? test-container-network
print_info 0 test-container-network

#删除容器
docker stop test1
docker rm test1
docker rmi centos

#停止docker服务
systemctl stop docker

#删除pipework软件包
yum remove -y pipework
print_info $? remove-pipework

rm -f ./out.log
