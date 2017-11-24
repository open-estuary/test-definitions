#!/bin/bash
#delete some data for case table

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect "mysql>"
send "DELETE FROM case_tbl WHERE case_id=3;\r"
expect "1 rows in set"
send "select * from case_tbl;\r"
expect "2 rows in set"
send "exit\r"
expect eof
EOF

