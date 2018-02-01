#!/bin/bash
#insert some data into case table

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

