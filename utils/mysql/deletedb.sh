#!/bin/bash
#delete database test

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "drop database test;\r"
expect "OK"
send "exit\r"
expect eof
EOF

