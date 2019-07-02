#!/usr/bin/expect
set vmachine [lindex $argv 0]
set timeout 3700
spawn virsh console $vmachine
expect {
" is ^]" {send "\r";exp_continue} 
"login:" {send "root\r";exp_continue}
"Password:" {send "root\r"}
}
expect {
"]#" {send "scp root@192.168.122.1:/root/stress_1.0.1.orig.tar.gz .\r";exp_continue}
"password:" {send "root\r"}
}
expect "]#" {send "tar -xzvf stress_1.0.1.orig.tar.gz\r"}
expect "]#" {send "yum install -y gcc make\r"}
expect "]#" {send "cd stress-1.0.1\r"}
expect "]#" {send "./configure\r"}
expect "]#" {send "make\r"}
expect "]#" {send "make install\r"}
expect "]#" {send "stress -c 4 -i 4 --vm 14 --vm-bytes 512M -hdd 15 --hdd-bytes 1G –t 1h\r"}
expect eof
