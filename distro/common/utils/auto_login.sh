#!/bin/bash

. ./sys_info.sh

auto_login()
{
    local user=$1
    local password=$2

/usr/bin/expect << EOF
set timeout 60
spawn ssh ${user}@localhost
  expect {
    "password:"
    {
      send "${password}\r"
    }
    "(yes/no)?"
    {
      send "yes\r"
      expect "password:"
      send "${password}\r"
    }
expect "testing@"
send "pwd\r"
expect "/home/testing"
send "exit\r"
expect eof
}
EOF
}

USER=${1:-$USERNAME}
PASSWORD=${2:-$PASSWD}
auto_login $USER $PASSWORD

if [ $? -ne 0 ]; then
    echo "login user $USER fail"
    lava-test-case login-user-in-$distro --result fail
else
    echo "login user $USER success"
    lava-test-case login-user-in-$distro --result pass
fi

