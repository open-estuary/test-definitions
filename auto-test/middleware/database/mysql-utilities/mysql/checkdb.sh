#!/bin/bash
#insert some data into case table


dbname=$1
tbname=$2


mysql -uroot -proot -e "show databases" | grep $dbname 

if test ! $? ;then
    return 1
fi 

mysql -uroot -proot -e "use $dbname;select * from t1" | grep $tbname 







if false ;then

set dbname [lindex $argv 0]
set info [lindex $argv 1]

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect "mysql>"
send "show databases;\r"
expect "$dbname"
send "use $dbname;\r"
expect "Database changed"
send "show tables;\r"
expect "t1"
send "select * from t1;\r"
expect "$info"
send "exit\r"
expect eof
EOF
fi 
