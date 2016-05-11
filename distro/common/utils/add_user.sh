#!/bin/bash

USERNAME="testing"
#distro="ubuntu"
. ./sys_info.sh

function add_user()
{
/usr/bin/expect << EOF
set timeout 60

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
EOF
}

user_exists=$(cat /etc/passwd|grep ${USERNAME})
if [ "$user_exists"x != ""x ]; then
    . ./del_user.sh
fi

add_user
if [ $? -ne 0 ]; then
    echo "add user $USERNAME fail"
    lava-test-case add-user-in-$distro --result fail
else
    echo "add user $USERNAME success"
    lava-test-case add-user-in-$distro --result pass
fi

