#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../utils
    . ./sys_info.sh
cd -

# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "centos")
        yum install java-1.8.0-openjdk.aarch64 -y
        print_info $? install_java-openjdk
        java -version
        print_info $? java-version
        yum install mysql-community-server.aarch64 -y
        print_info $? install_mysql-server
        mysql -V
        print_info $? mysql-version
        yum install expect -y
        print_info $? install-expect

        yum install mycat -y
        print_info $? install mycat

         ;;
esac
service mysqld start
systemctl status mysqld.service |grep "active (running)"
print_info $? mysql-start

#修改密码
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysqladmin -uroot -p password
expect "Enter"
send "123456\n"
expect "New"
send "123456\n"
expect "Confirm"
send "123456\n"
expect eof
EOF
print_info $? mysql-password

#登录mysql并创建3个库
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysql -uroot -p
expect "Enter password"
send "123456\n"
expect "mysql>"
send "create database db1;\n"
expect "mysql>"
send "create datebase db2;\n"
expect "mysql>"
send "create datebase db3;\n"
expect "mysql>"
send "exit;\n"
expect eof
EOF
#添加mycat组
groupadd mycat
print_info $? groupadd-mycat
#添加mycat用户
adduser -r -g mycat mycat
print_info $? adduser-mycat
#把mycat包放在/usr/local路径下面
cd /usr/share/
cp -r mycat ../../usr/local/
print_info $? cp-usr-local
cat /usr/local/mycat/version.txt |grep "MavenVersion"
print_info $? mycat-version
#修改mycat所属组
chown -R mycat.mycat /usr/local/mycat

#修改此项是为了解决mycat登录失败报错：java.lang.outofmemoryerror:direct buff
#memory
sed -i 's/wrapper.java.additional.5=-XX:MaxDirectMemorySize=2G/wrapper.java.additional.5=-XX:MaxDirectMemorySize=4G/g' /usr/local/mycat/conf/wrapper.conf

#启动mycat
cd /usr/local/mycat/bin
./mycat start

#TCID="mycat-start"
#查看mycat是否正常启动
ps -ef |grep mycat 2>&1 | tee mycat.log
str=`grep -Po "/usr/local/mycat/bin" mycat.log`
if [ "$str" != "" ] ; then
    lava-test-case $TCID --pass
else
    lava_test_case $TCID  --fail
fi

#通过mysql连接mycat
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysql -uroot -p -h127.0.0.1 -P8066 -DTESTDB
expect "Enter password"
send "123456\n"
expect "mysql>"
send "create table employee (id int not null primary key,name varchar(100),sharding_id int not null);\n"
expect "mysql>"
send "insert into employee(id,name,sharding_id) values(1,'leader us',10000);\n"
expect "mysql>"
send "explain create table company(id int not null primary key,name varchar(100));\n"
expect "mysql>"
send "explain insert into company(id,name) values(1,'hp');\n"
expect "mysql>"
send "exit;\n"
expect eof
EOF

count1=`ps -aux| grep mysql|wc -l`
if [ $count1 -gt 0 ]; then
    kill -9 $(pidof mysql)
    print_info $? kill-mysql
fi
count2=`ps -aux|grep mycat|wc -l`
if [ $count2 -gt 0 ]; then
    kill -9 $(pidof mycat)
    print_info $? kill-mycat
fi
yum remove expect -y
print_info $? remove-expect
yum remove java-1.8.0-openjdk.aarch64 -y
print_info $? remove-java
yum remove mycat -y
print_info $? remove-mycat
yum remove mysql-community-server.aarch64 -y
print_info $? remove-mysql

