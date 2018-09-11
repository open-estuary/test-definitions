#!/bin/bash
#select data from case table where author name ~= littlem

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "select * from case_tbl WHERE case_author LIKE 'littlem%';\r"
expect "samba"
send "exit\r"
expect eof
EOF

