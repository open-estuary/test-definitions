#!/bin/bash
. ./sys_info.sh

del_user()
{
    local user=$1
    userdel -r $user

    if [ ! -d /home/$user ]; then
        echo "del user $user success"
        lava-test-case del-user-in-$distro --result pass
    else
        echo "del user $user fail"
        lava-test-case del-user-in-$distro --result fail
    fi
}

USER=${1:-$USERNAME}
del_user $USER
