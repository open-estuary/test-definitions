# ====================
# Filename: open-lldp
# Author:
# Email:
# Date:
# Description:
# ====================

###### specify interpeter path ######

#!/bin/bash 

###### importing environment variable ######

set -x
cd ../../../../utils
    source  ./sys_info.sh
    source  ./sh-test-lib
cd -

###### check root ######

! check_root && error_msg "Please run this script as root."

###### importing variables ######

version="1.0.1"
from_repo="Estuary"
package="open-lldp"

###### install ######

for P in ${package};do
    echo "$P install"

case $distro in
    "centos" )
         yum install -y $P
         print_info $? install-open-lldp 
         ;;
 esac

###### testing step ######

## Check the package version && source
from=$(yum info $P | grep "From repo" | awk '{print $4}')
if [ "$from" = "$from_repo"  ];then
     print_info 0 repo_check
else
   rmflag=1
   if [ "$from" != "Estuary"  ];then
   yum remove -y $P
   yum install -y $P
   from=$(yum info $P | grep "From repo" | awk '{print $4}')
      if [ "$from" = "$from_repo"   ];then
          print_info 0 repo_check
      else
          print_info 1 repo_check
      fi
    fi
fi

vers=$(yum info $P | grep "Version" | awk '{print $3}')
if [ "$vers" = "$version"   ];then
     print_info 0 version_check
else
    print_info 1 version_check
fi
done

###### restore environment ######

## Remove package
yum remove -y $P
print_info $? remove-open-lldp
