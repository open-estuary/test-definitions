#!/bin/bash
# create database test

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "create database test;\r"
expect "OK"
send "show databases;\r"
expect "test"
send "exit\r"
expect eof
EOF

