#!/usr/bin/expect

set timeout 150
spawn scp zhangwangqun@192.168.1.107:/home/zhangwangqun/debian.qcow2 .
expect {
")?" {send "yes\r";exp_continue}
"password:" {send "zhang12\r"}
}
expect eof