#!/bin/bash
#order data for case table by desc of id

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "SELECT * from case_tbl ORDER BY case_id DESC;\r"
expect "3 rows in set"
send "exit\r"
expect eof
EOF

