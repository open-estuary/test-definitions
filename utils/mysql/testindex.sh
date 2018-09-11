#!/bin/bash
#choose database test

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "CREATE INDEX casename ON case_tbl(case_title);\r"
expect "OK"
send "SHOW INDEX FROM case_tbl;\r"
expect "2 rows in set"
send "ALTER TABLE case_tbl ADD UNIQUE (case_title);\r"
expect "OK"
send "SHOW INDEX FROM case_tbl;\r"
expect "3 rows in set"
send "drop index case_title on case_tbl;\r"
expect "OK"
send "drop index casename on case_tbl;\r"
expect "OK"
send "exit\r"
expect eof
EOF

