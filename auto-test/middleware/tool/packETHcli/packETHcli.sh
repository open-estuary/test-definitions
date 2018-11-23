#!/bin/sh 
#date:2018-9-12
##Author：fangyuanzheng<fyuanz_2010@163.com>
##PACKETH是一个支持GUI和CLI的以太网数据包生成器,可以生成和发送任何以太网数据包,测试包的源和版本号

set -x

#####加载外部文件################
cd ../../../../utils
source  ./sys_info.sh
source  ./sh-test-lib
cd -

#############################  Test user id       #########################
! check_root && error_msg "Please run this script as root."

######################## Environmental preparation   ######################
version="1.8"
from_repo="Estuary"
case $distro in
    "centos")
         package="packETHcli"
         install_deps "${package}"
         print_info $? packETHcli
         ;;
    "ubuntu"|"debian")
	 package="packeth"
	 install_deps "${package}"
         print_info $? packeth
	 ;;
     "fedora")
         package="packETH.aarch64"
	 install_deps "${package}"
	 print_info $? packeth
	 ;;
   "opensuse")
	 package="packETH"
	 install_deps "${package}"
	 print_info $? package
	 ;;
 esac

#######################  testing the step ###########################
# Check the package version && source
case $distro in
     "centos")
from=$(yum info $package | grep "From repo" | awk '{print $4}')
if [ "$from" = "$from_repo"  ];then
        print_info 0 repo_check
else
     rmflag=1
      if [ "$from" != "Estuary"  ];then
           yum remove -y $package
            yum install -y $package
             from=$(yum info $package | grep "From repo" | awk '{print $4}')
             if [ "$from" = "$from_repo"   ];then
                    print_info 0 repo_check
            else
                    print_info 1 repo_check
               fi
        fi
fi

vers=$(yum info $package | grep "Version" | awk '{print $3}')
if [ "$vers" = "$version"   ];then
        print_info 0 version
else
        print_info 1 version
fi
;;
     "ubuntu")
from=$(apt show $package|grep "Source"|awk '{print $2}')
print_info $? $from
vers=$(apt show $package|grep "Version"|awk '{print $2}')
print_info $? $vers
;;
     "debian")
from=$(apt show $package|grep "Source"|awk '{print $3}'|head -1)
print_info $? $from
vers=$(apt show $package|grep "Version"|awk '{print $2}')
print_info $? $vers
;;
     "fedora")
from=$(dnf info $package|grep Source|awk '{print $3}')
print_info $? $from
vers=$(dnf info $package|grep Version|awk '{print $3}')
print_info $? $vers
;;
     "opensuse")
from=$(zypper info $package|grep Repo|awk '{print $3}')
print_info $? $from
vers=$(zypper info $package|grep Version|awk '{print $3}')
print_info $? $vers
;;
esac

######################  environment  restore ##########################
# Remove package
case $distro in
     "centos"|"ubuntu"|"debian"|"fedora"|"opensuse")
     remove_deps "${package}"
     print_info $? remove_package
     ;;
esac
