#!/bin/bash
# Copyright (C) 2018-8-29, Estury
# Author: wangsisi

set -x
#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi

cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -

case $distro in
    "ubuntu"|"debian")
        pkgs="selinux-utils"
        install_deps "${pkgs}"
        print_info $? install_selinux
        ;;
    "opensuse")
        pkgs="selinux-tools"
        install_deps "${pkgs}"
        print_info $? install_selinux
        ;;
esac

#查询 selinux运行模式
getenforce|egrep "Permissive|Enforcing|Disabled" 
print_info $? selinux_mode

getenforce|egrep "Permissive|Enforcing"
status=$?
if test $status -eq 0;then
#设置为Enforcing模式
   setenforce 0
   setenforce 1
   getenforce|grep -i "Enforcing"
   print_info $? Selinux_EnforcingSet

#设置为Permissive模式
   setenforce 0
   getenforce|grep -i "Permissive"
   print_info $? Selinux_Permissive
else
   setenforce 1 2>&1|grep disabled
   print_info $? Selinux_EnforcingSet
   
   setenforce 0 2>&1|grep disabled
   print_info $? Selinux_Permissive
fi

#uninstall
remove_deps "${pkgs}" 
 if test $? -eq 0;then
    print_info 0 remove
 else
    print_info 1 remove
 fi 