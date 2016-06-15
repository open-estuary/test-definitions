#!/bin/bash

USERNAME="testing"
#distro="ubuntu"
. ./sys_info.sh

function add_user()
{
    case $distro in
        "ubuntu" | "debian" )
            ./../../ubuntu/scripts/ubuntu_expect_adduser.sh $USERNAME
            ;;
        "fedora" )
            useradd $USERNAME -d /home/$USERNAME
            ./../../fedora/scripts/fedora_expect_adduser.sh $USERNAME
            ;;
        "opensuse" )
            ;;
        "centos" )
            adduser $USERNAME
            PASSWD="open1234asd"
            ./../../centos/scripts/centos_expect_adduser.sh $USERNAME $PASSWD
            ;;
    esac
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

