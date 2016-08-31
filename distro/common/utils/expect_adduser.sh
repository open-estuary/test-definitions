#!/usr/bin/expect

set timeout 60

set USERNAME [lindex $argv 0]
set PASSWD [lindex $argv 1]

spawn passwd $USERNAME
expect "password:"
send "${PASSWD}\r"
expect "password:"
send "${PASSWD}\r"
expect eof
