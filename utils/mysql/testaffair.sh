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
send "CREATE TABLE case_test( id int(5) ) engine=innodb;\r"
expect "OK"
send "select * from case_test;\r"
expect "Empty set"
send "begin;\r"
expect "OK"
send "insert into case_test value(5);\r"
expect "1 row affected"
send "insert into case_test value(6);\r"
expect "1 row affected"
send "commit;\r"
expect "0 rows affected"
send "select * from case_test;\r"
expect "2 rows in set"
send "begin;\r"
expect "OK"
send "insert into case_test value(7);\r"
expect "1 row affected"
send "rollback;\r"
expect "0 rows affected"
send "select * from case_test;\r"
expect "2 rows in set"
send "exit\r"
expect eof
EOF

