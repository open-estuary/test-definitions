#!/bin/bash
#test union

EXPECT=$(which expect)
$EXPECT << EOF | tee out.log
set timeout 500
spawn mysql -u root -p
expect "password:"
send "root\r"
expect ">"
send "use test;\r"
expect "Database changed"
send "CREATE TABLE IF NOT EXISTS author_tbl(
author_id INT UNSIGNED AUTO_INCREMENT,
author_name VARCHAR(40) NOT NULL,
author_home VARCHAR(100) NOT NULL,
PRIMARY KEY ( author_id  )
)ENGINE=InnoDB DEFAULT CHARSET=utf8;\r"
expect "OK"
send "INSERT INTO author_tbl
(author_name, author_home)
VALUES('littlema', 'henan');\r"
expect "OK"
send "INSERT INTO author_tbl
(author_name, author_home)
VALUES('littlefang', 'hunan');\r"
expect "OK"
send "INSERT INTO author_tbl
(author_name, author_home)
VALUES('littlecai', 'hunan');\r"
expect "OK"
send "select case_author from case_tbl
union
select author_name from author_tbl
order by case_author;\r"
expect "3 rows in set"
send "select case_author from case_tbl
union all
select author_name from author_tbl
order by case_author;\r"
expect "6 rows in set"
send "exit\r"
expect eof
EOF

