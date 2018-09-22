#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>


cd ../../../../utils
    . ./sys_info.sh
cd -

#set -x
outDebugInfo
# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi


source ../percona/mysql.sh 

case $distro in
    "centos")
        cleanup_all_database
        yum install java-1.8.0-openjdk.aarch64 -y
        yum install mysql-community-server.aarch64 -y
        yum install expect -y
        yum install mycat -y
        print_info $? install-package

         ;;
esac
service mysqld start
print_info $? start-mysqld
systemctl status mysqld.service |grep "active (running)"
print_info $? mysql-status

#修改密码
mysqladmin -uroot  password "123456"
print_info $? set-passwd

#登录mysql并创建3个库
EXPECT=$(which expect)
$EXPECT << EOF | tee -a out.log
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
grep "Welcome to the MySQL" out.log
print_info $? login-mysql
grep "Query OK" out.log
print_info $? create-db
#添加mycat组
groupadd -f  mycat
print_info $? groupadd-mycat
#添加mycat用户
id mycat 
if [ $? -eq 0 ];then
    userdel mycat 
fi 
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
print_info $? chown-mycat
#修改此项是为了解决mycat登录失败报错：java.lang.outofmemoryerror:direct buff
#memory
sed -i 's/wrapper.java.additional.5=-XX:MaxDirectMemorySize=2G/wrapper.java.additional.5=-XX:MaxDirectMemorySize=4G/g' /usr/local/mycat/conf/wrapper.conf
print_info $? modification-wrapper.conf

#启动mycat
cd /usr/local/mycat/bin
./mycat start

ps -ef | grep mycat | grep -v grep 
print_info $? start-mycat


./mycat status | grep "is running"
print_info $? "mycat_status_ok"

#通过mysql连接mycat
EXPECT=$(which expect)
$EXPECT << EOF | tee -a mycat.log
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
grep "Welcome to the MySQL monitor" mycat.log
#print_info $? mysql-mycat
count=`grep "Query OK" mycat.log|wc -l`
if [ "$count" -eq  4 ]; then
    print_info $? creat-table
    print_info $? insert-table
    print_info $? explain-create
    print_info $? explain-insert
fi 

systemctl stop mysql 
./mycat stop 
print_info $? "mycat_stop"


cd - 
yum remove expect -y
yum remove java-1.8.0-openjdk.aarch64 -y
yum remove mycat -y
yum remove mysql-community-server.aarch64 -y
print_info $? remove-package

