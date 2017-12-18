#!/bin/bash
#check guest have root database or not

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u guest -p
expect "password:"
send "guest\r"
expect "mysql>"
send "show databases;\r"
expect "db1"
send "exit\r"
expect eof
EOF

