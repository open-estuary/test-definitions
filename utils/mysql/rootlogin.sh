#!/bin/bash
#root login mysql

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "show databases;\r"
expect "mysql"
send "exit\r"
expect eof
EOF

