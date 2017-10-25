#!/usr/bin/expect -f
spawn fdisk /dev/nbd0
set timeout 4
expect "help)"
send "g\n"
expect "help)"
send "n\n"
expect "default"
send "\n"
expect "default"
send "\n"
expect "default"
send "\n"
expect "help"
send "w\n"
set timeout 120
expect eof
