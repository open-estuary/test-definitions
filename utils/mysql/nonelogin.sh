#!/bin/bash
#anonymous login mysql

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql
expect ">"
send "show databases;\r"
expect "mysql"
send "exit\r"
expect eof
EOF

