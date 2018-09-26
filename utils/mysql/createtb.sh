#!/bin/bash
#create table
#runoob_tbl: runoob_id,runoob_title,runoob_author,submission_date

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "CREATE TABLE case_tbl(
case_id INT NOT NULL AUTO_INCREMENT,
case_title VARCHAR(100) NOT NULL,
case_author VARCHAR(40) NOT NULL,
submission_date DATE,
PRIMARY KEY ( case_id  ))ENGINE=InnoDB DEFAULT CHARSET=utf8;\r"
expect "OK"
send "exit\r"
expect eof
EOF

