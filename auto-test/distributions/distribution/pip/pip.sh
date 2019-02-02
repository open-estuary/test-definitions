# ====================
# Filename: pip
# Author:
# Email:
# Date:
# Description:
# ====================

###### specify interpeter bath ######

#!/bin/bash

###### importing environment variable ######

cd ../../../../utils
   source  ./sys_info.sh
   source  ./sh-test-lib
cd -

###### check root ######

! check_root && error_msg "You must run this script as root."

###### install ######

case $distro in
    "centos")
        yum install python2-pip -y
        print_info $? install-pip
        ;;
    "debian")
        apt-get install python-pip -y
        print_info $? install-pip
        ;;
esac

###### testing step ######

## install pip ##

pip install -U pip
print_info $? pip-update

## install requests ##

pip install requests --ignore-installed requests
print_info $? pip-install-package

## uninstall requests ##

pip uninstall requests -y
print_info $? pip-remove-package

## pip list ##

pip list
print_info $? pip-list

pip list --outdated
print_info $? pip-list-outdate

## pip install anymarkup ##

pip install --upgrade anymarkup
print_info $? pip-upgrade

## show anymarkup ##

pip show anymarkup
print_info $? pip-show

## search jquery ##

if [ "${ci_http_addr}"x = "http://172.19.20.15:8083"x ];then
    export http_proxy="http://172.19.20.11:3128"
    export https_proxy="http://172.19.20.11:3128"
fi
pip search "jquery"
print_info $? pip-search
if [ "${ci_http_addr}"x = "http://172.19.20.15:8083"x ];then
    export http_proxy=""
    export https_proxy=""
fi

###### restore environment ######

case $distro in
    "centos")
        yum remove python2-pip -y
        print_info $? remove-pip
        ;;
    "debian")
        apt-get remove python-pip -y
        print_info $? remove-pip
        ;;
esac
