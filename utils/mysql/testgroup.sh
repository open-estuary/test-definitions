#!/bin/bash
#select data for case table by group

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "SELECT case_author, COUNT(*) FROM case_tbl GROUP BY case_author;\r"
expect "3 rows in set"
send "exit\r"
expect eof
EOF

