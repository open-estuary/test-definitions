#!/bin/bash
#create t1
#a(int) b(varchar)

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect "mysql>"
send "use db1;\r"
expect "Database changed"
send "CREATE TABLE t1(
a int unsigned auto_increment,
b varchar(100) not null,
PRIMARY KEY (a))ENGINE=InnoDB DEFAULT CHARSET=utf8;\r"
expect "OK"
send "use db2;\r"
expect "Database changed"
send "CREATE TABLE t1(
a int unsigned auto_increment,
b varchar(100) not null,
PRIMARY KEY (a))ENGINE=InnoDB DEFAULT CHARSET=utf8;\r"
expect "OK"
send "exit\r"
expect eof
EOF

