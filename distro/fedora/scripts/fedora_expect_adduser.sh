#!/usr/bin/expect

set timeout 600
set USERNAME [lindex $argv 0]

spawn passwd $USERNAME
expect "New password:"
send "$USERNAME\r"
expect "Retype new password:"
send "$USERNAME\r"
expect eof

