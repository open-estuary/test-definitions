#!/usr/bin/expect -f
spawn fdisk /dev/nbd0
set timeout 4
expect "help)"
set timeout 1
send "g"
send "\n"
expect "help)"
set timeout 1
send "n"
send "\n"
expect "default"
set timeout 1
send "\n"
expect "default"
set timeout 1
send "\n"
expect "default"
set timeout 1
send "\n"
expect "help"
send "w"
send "\n"
set timeout 120
expect eof
