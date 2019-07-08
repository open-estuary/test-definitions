#!/usr/bin/expect

set timeout 60
spawn scp zhangwangqun@192.168.1.107:/home/zhangwangqun/centos_VARS.fd .
expect {
")?" {send "yes\r";exp_continue}
"password:" {send "zhang12\r"}
}
expect eof
