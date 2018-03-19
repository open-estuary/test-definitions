#!/bin/bash

#set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -
source ../percona/mysql.sh 
outDebugInfo
yum erase -y mariadb-libs
yum remove -y mariadb-libs
yum update -y

cleanup_all_database

pkgs="mysql-community-common mysql-community-server 
	mysql-community-client mysql-community-devel expect"
install_deps "${pkgs}"
print_info $? install-mysql-community

pkgs="gcc-c++ boost-devel"
install_deps "${pkgs}"
print_info $? install-c++

pkgs="mysql-connector-c++ mysql-connector-c++-devel mysql-connector-c++-debuginfo"
install_deps "${pkgs}"
print_info $? install-mysql-connector-c++

systemctl start mysqld
print_info $? start-mysqld

mysqladmin -u root password "root"
print_info $? set-root-pwd

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysqladmin -uroot -p create test
expect "password:"
send "root\r"
expect eof
EOF
print_info $? create-database

find . -name "test.cpp"
if [ $? -ne 0 ];then
	echo "Error: Have not found test.cpp!!"
	exit 1
fi

g++ -o test test.cpp -lmysqlcppconn -L/usr/local/lib
./test | tee out.log
print_info $? build-mysql-cpp

cat out.log  | grep "success connect mysql"
print_info $? c++-connect-db

cat out.log  | grep "success use test database"
print_info $? c++-use-db

cat out.log  | grep "success create test table"
print_info $? c++-create-table

cat out.log  | grep "success insert data"
print_info $? c++-insert-data

cat out.log  | grep "success select data"
print_info $? c++-select-data

cat out.log  | grep "success update data"
print_info $? c++-update-data

cat out.log  | grep "success delete data"
print_info $? c++-delete-data

cat out.log  | grep "success drop test table"
print_info $? c++-drop-table

rm -f out.log

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysql -uroot -p
expect "password:"
send "root\r"
expect "mysql>"
send "drop database test;\r"
expect "OK"
send "exit\r"
expect eof
EOF
print_info $? drop-database

systemctl stop mysqld
print_info $? stop-mysqld

yum remove -y mysql-connector-c++ mysql-connector-c++-devel mysql-connector-c++-debuginfo
print_info $? remove-mysql-connector-c++

yum remove -y gcc-c++ boost-devel
print_info $? remove-c++

yum remove -y mysql-community-server mysql-community-common mysql-community-client mysql-community-devel
print_info $? remove-mysql-community

