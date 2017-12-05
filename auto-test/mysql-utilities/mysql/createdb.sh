#!/bin/bash
# create database db1 db2

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

