#!/bin/bash
#insert some data into case table

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "INSERT INTO case_tbl
(case_title, case_author, submission_date)
VALUES
('samba', 'littlema', NOW());\r"
expect "OK"
send "INSERT INTO case_tbl
(case_title, case_author, submission_date)
VALUES
('ftp', 'littlefang', NOW());\r"
expect "OK"
send "INSERT INTO case_tbl
(case_title, case_author, submission_date)
VALUES
('dhcp', 'littlecai', NOW());\r"
expect "OK"
send "select * from case_tbl;\r"
expect "3 rows in set"
send "exit\r"
expect eof
EOF

