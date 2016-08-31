#!/bin/bash

. ./sys_info.sh

add_user()
{
    local user=$1
    local password=$2

    case $distro in
        "centos" )
            adduser $user
            ;;
        *)
            useradd $user -d /home/$user
            ;;
    esac

    ./expect_adduser.sh $user $password
}

USER=${1:-$USERNAME}
PASSWORD=${2:-$PASSWD}

user_exists=$(cat /etc/passwd|grep ${USER})
if [ "$user_exists"x != ""x ]; then
    . ./del_user.sh $USER
fi

add_user $USER $PASSWORD

if [ $? -ne 0 ]; then
    echo "add user $USER fail"
    lava-test-case add-user-in-$distro --result fail
else
    echo "add user $USER success"
    lava-test-case add-user-in-$distro --result pass
fi

