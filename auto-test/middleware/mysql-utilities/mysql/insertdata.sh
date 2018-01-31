#!/bin/bash
#insert some data into case table

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect "mysql>"
send "use db1;\r"
expect "Database changed"
send "INSERT INTO t1(b)
VALUES('test123');\r"
expect "OK"
send "INSERT INTO t1(b)
VALUES('test456');\r"
expect "OK"
send "INSERT INTO t1(b)
VALUES('test789');\r"
expect "OK"
send "INSERT INTO t1(b)
VALUES('now row - db1');\r"
expect "OK"
send "use db2;\r"
expect "Database changed"
send "INSERT INTO t1(b)
VALUES('test123');\r"
expect "OK"
send "INSERT INTO t1(b)
VALUES('test456');\r"
expect "OK"
send "INSERT INTO t1(b)
VALUES('test789');\r"
expect "OK"
send "INSERT INTO t1(b)
VALUES('now row - db2');\r"
expect "OK"
send "exit\r"
expect eof
EOF

