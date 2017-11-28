#!/bin/bash

set -x

cd ../../utils
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

systemcrl status mysqld | grep running
print_info $? status-mysqld

cd ../../utils/mysql

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

./createdb.sh
if [ $? -ne 0 ]; then
    echo 'create test database ok'
	print_info $? create-database
else
	print_info $? create-database
fi

./choocedb.sh
if [ $? -ne 0 ]; then
    echo 'choice test database ok'
	print_info $? chooce-database
else
	print_info $? chooce-database
fi

./createtb.sh
if [ $? -ne 0 ]; then
    echo 'create case table ok'
	print_info $? create-table
else
	print_info $? create-table
fi


./insertdata.sh
if [ $? -ne 0 ]; then
    echo 'insert data into case table ok'
	print_info $? insert-data
else
	print_info $? insert-data
fi

./testwhere.sh
if [ $? -ne 0 ]; then
    echo 'test where ok'
	print_info $? test-where
else
	print_info $? test-where
fi

./testlike.sh
if [ $? -ne 0 ]; then
    echo 'test like ok'
	print_info $? test-like
else
	print_info $? test-like
fi

./testorder.sh
if [ $? -ne 0 ]; then
    echo 'test order ok'
	print_info $? test-order
else
	print_info $? test-order
fi

./testgroup.sh
if [ $? -ne 0 ]; then
    echo 'test group ok'
	print_info $? test-group
else
	print_info $? test-group
fi

./testunion.sh
if [ $? -ne 0 ]; then
    echo 'test union ok'
	print_info $? test-union
else
	print_info $? test-union
fi

./testjoin.sh
if [ $? -ne 0 ]; then
    echo 'test join ok'
	print_info $? test-join
else
	print_info $? test-join
fi

./testaffair.sh
if [ $? -ne 0 ]; then
    echo 'test affair ok'
	print_info $? test-affair
else
	print_info $? test-affair
fi

./testalter.sh
if [ $? -ne 0 ]; then
    echo 'test alter ok'
	print_info $? test-alter
else
	print_info $? test-alter
fi

./testindex.sh
if [ $? -ne 0 ]; then
    echo 'test index ok'
	print_info $? test-index
else
	print_info $? test-index
fi

./updatedata.sh
if [ $? -ne 0 ]; then
    echo 'update data of case table ok'
	print_info $? update-data
else
	print_info $? update-data
fi

./deletedata.sh
if [ $? -ne 0 ]; then
    echo 'delete data of case table ok'
	print_info $? delete-data
else
	print_info $? delete-data
fi

./deletetb.sh
if [ $? -ne 0 ]; then
    echo 'delete table ok'
	print_info $? delete-table
else
	print_info $? delete-table
fi

./deletedb.sh
if [ $? -ne 0 ]; then
    echo 'delete test database ok'
	print_info $? delete-database
else
	print_info $? delete-database
fi

rm -f ./out.log
cd -

systemctl stop mysqld
print_info $? stop-mysqld

yum remove -y mysql-community-server mysql-community-common mysql-community-client mysql-community-devel
print_info $? remove-mysql-community

