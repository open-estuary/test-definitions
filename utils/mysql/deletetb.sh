#!/bin/bash
#delete database test

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "drop table case_tbl;\r"
expect "OK"
send "drop table alter_tbl;\r"
expect "OK"
send "drop table author_tbl;\r"
expect "OK"
send "drop table case_test;\r"
expect "OK"
send "show tables;\r"
expect "Empty"
send "exit\r"
expect eof
EOF

