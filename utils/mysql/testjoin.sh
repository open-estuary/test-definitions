#!/bin/bash
#test join

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "SELECT a.case_title,a.case_author, b.author_home
FROM case_tbl a
INNER JOIN author_tbl b
ON a.case_author = b.author_name;\r"
expect "3 rows in set"
send "exit\r"
expect eof
EOF
