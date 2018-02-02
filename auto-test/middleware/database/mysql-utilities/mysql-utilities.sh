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

pkgs="mysql-utilities"
install_deps "${pkgs}"
print_info $? install-mysql-utilities

systemctl start mysqld
print_info $? start-mysqld

mysqladmin -u root password "root"
print_info $? set-root-pwd

cd mysql
echo "now create db1,db2 and compare them"
./createdb.sh db1
./createdb.sh db2
print_info $? create-databases

./createtb.sh
print_info $? create-tables

./insertdata.sh
print_info $? insert-datas

mysqldbcompare --server1=root:root@localhost db1:db2 --run-all-tests | tee out.log
cat out.log | grep 'done'
print_info $? utility-compare-db

mysqldbcopy --source=root:root@localhost --destination=root:root@localhost db1:db1_copy | tee out.log
cat out.log | grep 'done'
print_info $? utility-copy-db

./checkdb.sh db1_copy db1
print_info $? check-copy-db

mysqldbexport --server=root:root@localhost db1 --output-file=data
cat data | grep 'done'
print_info $? utility-export-db

./deletedb.sh db1
print_info $? delete-export-db

mysqldbimport  --server=root:root@localhost data | tee out.log
cat out.log | grep 'done'
print_info $? utility-import-db

./checkdb.sh db1 Empty
print_info $? check-import-db

mysqldiff --server1=root:root@localhost --server2=root:root@localhost db1:db2 | tee out.log
cat out.log | grep 'Success'
print_info $? utility-diff-same-db

#create tb2 to make difference
./createtb2.sh

mysqldiff --server1=root:root@localhost --server2=root:root@localhost db1:db2 | tee out.log
cat out.log | grep 'Compare failed'
print_info $? diff-different-db

mysqlserverclone --server=root:root@localhost --new-data=/tmp/data/ \
	--new-port=3310 --new-id=3310 --root-password=3310 --user=mysql -vvv | tee out.log
cat out.log | grep 'done'
print_info $? clone-server-3310

ps -ef | grep 3310
print_info $? check-server-3310

mysqlserverinfo --server=root:root@localhost --format=grid -vvv  --show-defaults  --no-headers | tee out.log
cat out.log | grep 'done'
print_info $? single-server-info

mysqlserverinfo --server=root:root@localhost  -d --format=vertical --show-defaults \
   	--no-headers  --server=root:3310@localhost:3310 --show-servers | tee out.log
cat out.log | grep 'done'
print_info $? all-server-info

mysqldiskusage --server=root:root@localhost --all | tee out.log
cat out.log | grep 'done'
print_info $? all-databases-size

mysqldiskusage --server=root:root@localhost --format=g -a -vvv | tee out.log
cat out.log | grep 'done'
print_info $? grid-db-log-size

mysqldiskusage --server=root:root@localhost --format=t -a -vvv | tee out.log
cat out.log | grep 'done'
print_info $? tab-db-log-size

mysqlindexcheck --server=root:root@localhost db1 --show-drops --show-indexes \
	--stats  --report-indexes  -vvv ttlsa_com | tee out.log
cat out.log | grep 'done'
print_info $? check-index

mysqlmetagrep --server=root:root@localhost --pattern='d_'
print_info $? grep-meta

mysqlprocgrep  --match-user=root  --kill-connection \
	--match-state=sleep  --print-sql  -vvv
print_info $? grep-proc

mysqluserclone --source=root:root@localhost --list -vvv --format=v
print_info $? list-mysql-users

mysqluserclone --source=root:root@localhost --destination=root:root@localhost \
	root@localhost guest:guest@localhost
print_info $? clone-user

./checkuser.sh
print_info $? check-clone-user

mysqluc -e "help utilities"
print_info $? uc-help-utilities

sudo env PYTHONPATH=$PYTHONPATH mysqldiskusage --server=root:root@localhost --all
print_info $? mysql-disk-usage

echo "set SRV=root:root@localhost; mysqldiskusage --server=\$SRV" | mysqluc -vvv
print_info $? uc-use-pipe

mysqluc SRV=instance_3306 SITE=www.ttlsa.com -e "show variables"
print_info $? uc-list-var

./deletedb.sh db1
./deletedb.sh db1_copy
./deletedb.sh db2
print_info $? drop-database

systemctl stop mysqld
print_info $? stop-mysqld

yum remove -y mysql-utilities
print_info $? remove-mysql-utilities

yum remove -y mysql-community-server mysql-community-common mysql-community-client mysql-community-devel
print_info $? remove-mysql-community

