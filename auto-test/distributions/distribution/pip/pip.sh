#!/bin/sh
# Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
. ./sys_info.sh
cd -

#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "centos")
        yum install python2-pip.noarch -y
        print_info $? install-pip
        ;;
    "ubuntu")
        apt-get install python-pip -y
        print_info $? install-pip
        ;;
esac
pip install -U pip
print_info $? pip-update
pip install requests
print_info $? pip-install-package
pip uninstall requests -y
print_info $? pip-remove-package
pip list
print_info $? pip-list
pip list --outdated
print_info $? pip-list-outdate
pip install --upgrade anymarkup
print_info $? pip-upgrade
pip show anymarkup
print_info $? pip-show
pip search "jquery"
print_info $? pip-search

case $distro in
    "centos")
        yum remove python2-pip -y
        print_info $? remove-pip
        ;;
    "ubuntu")
        apt-get remove python-pip -y
        print_info $? remove-pip
        ;;
esac
