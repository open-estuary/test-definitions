#!/usr/bin/expect 

set timeout 60

set USERNAME [lindex $argv 0]

spawn adduser $USERNAME
expect "password:"
send "${USERNAME}\r"
expect "password:"
send "${USERNAME}\r"
expect "Full Name"
send "\r"
expect "Room Number"
send "\r"
expect "Work Phone"
send "\r"
expect "Home Phone"
send "\r"
expect "Other"
send "\r"
expect "information correct?"
send "Y\r"
expect eof
