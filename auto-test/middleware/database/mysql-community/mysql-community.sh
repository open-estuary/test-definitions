#!/bin/bash

set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

yum erase -y mariadb-libs
yum remove -y mariadb-libs
yum update -y

pkgs="mysql-community-common mysql-community-server 
	mysql-community-client mysql-community-devel expect"
install_deps "${pkgs}"
print_info $? install-mysql-community

mysqladmin --version | grep 5.6
print_info $? test-mysql-version

systemctl start mysqld
print_info $? start-mysqld

systemctl status mysqld | grep running
print_info $? status-mysqld

cd ../../utils/mysql

./nonelogin.sh
if [ $? -eq 0 ]; then
    echo 'anonymous login mysql ok'
	print_info 0 anonymous-login
else
	print_info 1 anonymous-login
fi

mysqladmin -u root password "root"
print_info $? set-root-pwd

./rootlogin.sh
if [ $? -eq 0 ]; then
    echo 'root login mysql ok'
	print_info 0 root-login
else
	print_info 1 root-login
fi

./createdb.sh
if [ $? -eq 0 ]; then
    echo 'create test database ok'
	print_info 0 create-database
else
	print_info 1 create-database
fi

./choosedb.sh
if [ $? -eq 0 ]; then
    echo 'choice test database ok'
	print_info 0 choose-database
else
	print_info 1 choose-database
fi

./createtb.sh
if [ $? -eq 0 ]; then
    echo 'create case table ok'
	print_info 0 create-table
else
	print_info 1 create-table
fi


./insertdata.sh
if [ $? -eq 0 ]; then
    echo 'insert data into case table ok'
	print_info 0 insert-data
else
	print_info 1 insert-data
fi

./selectdata.sh
if [ $? -eq 0 ]; then
    echo 'select data from case table ok'
	print_info 0 select-data
else
	print_info 1 select-data
fi

./testwhere.sh
if [ $? -eq 0 ]; then
    echo 'test where ok'
	print_info 0 test-where
else
	print_info 1 test-where
fi

./testlike.sh
if [ $? -eq 0 ]; then
    echo 'test like ok'
	print_info 0 test-like
else
	print_info 1 test-like
fi

./testorder.sh
if [ $? -eq 0 ]; then
    echo 'test order ok'
	print_info 0 test-order
else
	print_info 1 test-order
fi

./testgroup.sh
if [ $? -eq 0 ]; then
    echo 'test group ok'
	print_info 0 test-group
else
	print_info 1 test-group
fi

./testunion.sh
if [ $? -eq 0 ]; then
    echo 'test union ok'
	print_info 0 test-union
else
	print_info 1 test-union
fi

./testjoin.sh
if [ $? -eq 0 ]; then
    echo 'test join ok'
	print_info 0 test-join
else
	print_info 1 test-join
fi

./testaffair.sh
if [ $? -eq 0 ]; then
    echo 'test affair ok'
	print_info 0 test-affair
else
	print_info 1 test-affair
fi

./testalter.sh
if [ $? -eq 0 ]; then
    echo 'test alter ok'
	print_info 0 test-alter
else
	print_info 1 test-alter
fi

./testindex.sh
if [ $? -eq 0 ]; then
    echo 'test index ok'
	print_info 0 test-index
else
	print_info 1 test-index
fi

./updatedata.sh
if [ $? -eq 0 ]; then
    echo 'update data of case table ok'
	print_info 0 update-data
else
	print_info 1 update-data
fi

./deletedata.sh
if [ $? -eq 0 ]; then
    echo 'delete data of case table ok'
	print_info 0 delete-data
else
	print_info 1 delete-data
fi

./deletetb.sh
if [ $? -eq 0 ]; then
    echo 'delete table ok'
	print_info 0 delete-table
else
	print_info 1 delete-table
fi

./deletedb.sh
if [ $? -eq 0 ]; then
    echo 'delete test database ok'
	print_info 0 delete-database
else
	print_info 1 delete-database
fi

rm -f ./out.log
cd -

systemctl stop mysqld
print_info $? stop-mysqld

yum remove -y mysql-community-server mysql-community-common mysql-community-client mysql-community-devel
print_info $? remove-mysql-community

