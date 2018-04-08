#! /usr/bin/expect
spawn scp -r chenshuangsheng@192.168.1.106:/home/chenzhihui/spec .
expect "password:"
send "123456\r"
#interact
