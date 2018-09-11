#!/bin/bash
#select data from case table

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
send "select case_id, case_title, case_author, submission_date from case_tbl;\r"
expect "3 rows in set"
send "exit\r"
expect eof
EOF

