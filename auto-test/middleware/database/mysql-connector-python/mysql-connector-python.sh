#!/bin/bash
set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

! check_root && error_msg "Please run this script as root."

##################### Environmental preparation ###################

source ./mysql.sh
outDebugInfo
case "${distro}" in
    centos)
        yum erase -y mariadb-libs
        yum remove -y mariadb-libs
        yum update -y
        cleanup_all_database
        pkgs1="mysql-community-server mysql-community-devel expect"
	install_deps "${pkgs1}"
	print_info $? install_mysql
	pkgs2="MySQL-python python"
	install_deps "${pkgs2}"
	print_info $? install-python
        ;;
    ubuntu|debian)
        apt-get remove --purge mysql-server -y
        pkgs="mysql-server mysql-client python-mysqldb python expect"
        install_deps "${pkgs}"
	print_info $? install-mysql-community
	;;
esac

##################### the testing step ###########################

systemctl start mysql
print_info $? start-mysqld

mysqladmin -u root password "root"
print_info $? set-root-pwd

#Determine if the file exists
if !  test  -f "test.py" ;then
	echo "Error: Have not found test.py!!"
	exit 1
fi

python test.py | tee out.log
print_info $? build-mysql-python

cat out.log  | grep "success connect mysql"
print_info $? python-connect-db

cat out.log  | grep "success create test database"
print_info $? python-create-db

cat out.log  | grep "success choose database"
print_info $? python-choose-db

cat out.log  | grep "success create test table"
print_info $? python-create-table

cat out.log  | grep "success insert data"
print_info $? python-insert-data

cat out.log  | grep "success select data"
print_info $? python-select-data

cat out.log  | grep "success update data"
print_info $? python-update-data

cat out.log  | grep "success delete data"
print_info $? python-delete-data

cat out.log  | grep "success drop test table"
print_info $? python-drop-table

rm -f out.log

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysql -uroot -p
expect "password:"
send "root\r"
expect ">"
send "drop database test;\r"
expect "OK"
send "exit\r"
expect eof
EOF
print_info $? drop-database



####################  environment  restore ##############

systemctl stop mysql
print_info $? stop-mysqld

case "${distro}" in
    centos)
        remove_deps "${pkgs1}"
        print_info $? remove-mysql
        ;;
    ubuntu|debian)
        apt-get remove --purge mysql-server -y
        apt-get remove mysql-client -y
	apt-get remove python-mysqldb -y
        print_info $? remove-mysql
        ;;
esac

