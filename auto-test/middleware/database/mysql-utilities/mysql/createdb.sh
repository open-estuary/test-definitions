#!/bin/bash
# create database db1 db2


db1=$1
mysql -uroot -proot -e "create database if not exists $db1"


if false ;then 
set dbname [lindex $argv 0]

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect "mysql>"
send "create database $dbname;\r"
expect "OK"
send "show databases;\r"
expect "$dbname"
send "exit\r"
expect eof
EOF
fi
