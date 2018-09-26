#!/bin/bash
#test where syntax

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "select * from case_tbl;\r"
expect "3 rows in set"
send "select * from case_tbl where case_title='samba';\r"
expect "littlema"
send "select * from case_tbl where binary case_title='SAMBA';\r"
expect "Empty"
send "exit\r"
expect eof
EOF

