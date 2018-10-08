#!/bin/bash
#update some data for case table

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
send "UPDATE case_tbl SET case_title='dns' WHERE case_id=3;\r"
expect "OK"
send "select * from case_tbl where case_id=3;\r"
expect "dns"
send "exit\r"
expect eof
EOF

