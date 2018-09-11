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
send "create table testalter_tbl
(i INT,c CHAR(1));\r"
expect "OK"
send "ALTER TABLE testalter_tbl DROP i;\r"
expect "OK"
send "ALTER TABLE testalter_tbl ADD i INT;\r"
expect "OK"
send "ALTER TABLE testalter_tbl MODIFY c CHAR(10);\r"
expect "OK"
send "ALTER TABLE testalter_tbl CHANGE c j CHAR(10);\r"
expect "OK"
send "ALTER TABLE testalter_tbl
MODIFY i INT NOT NULL DEFAULT 100;\r"
expect "OK"
send "ALTER TABLE testalter_tbl ALTER i DROP DEFAULT;\r"
expect "OK"
send "ALTER TABLE testalter_tbl RENAME TO alter_tbl;\r"
expect "OK"
send "show tables;\r"
expect "alter_tbl"
send "show columns from alter_tbl;\r"
expect "char(10)"
send "exit\r"
expect eof
EOF

