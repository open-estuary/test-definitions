#!/usr/bin/expect

set timeout 600
set mysql_password [lindex $argv 0]

spawn apt-get install -y mysql-server
expect "New password for the MySQL"
send "$mysql_password\r"
expect "Repeat password for the MySQL"
send "$mysql_password\r"
expect eof

