#!/bin/sh 
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="0.5.3"
from_repo="Estuary"
#package="devtoolset-4-yaml-cpp"

#for P in ${package};do
 #   echo "$P install"
case $distro in
    "centos" )
        package="devtoolset-4-yaml-cpp"
        install_deps "${package}" 
        print_info $? devtoolset-4-yaml-cpp
        ;;
esac
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
esac

# Remove package
yum remove -y $package
print_info $? remove
