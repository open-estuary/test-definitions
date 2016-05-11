#!/bin/bash

USERNAME="testing"
. ./sys_info.sh

function auto_login()
{
/usr/bin/expect << EOF
set timeout 60
spawn ssh ${USERNAME}@localhost
  expect {
    "password:" 
    {
      send "${USERNAME}\r"
    }
    "(yes/no)?"
    {
      send "yes\r"
      expect "password:"
      send "${USERNAME}\r"
    }
expect "testing@"
send "pwd\r"
expect "/home/testing"
send "exit\r"
expect eof
}
EOF
}

auto_login
if [ $? -ne 0 ]; then
    echo "login user $USERNAME fail"
    lava-test-case login-user-in-$distro --result fail
else
    echo "login user $USERNAME success"
    lava-test-case login-user-in-$distro --result pass
fi

