
#!/bin/sh 
set -x
cd ../../../../utils
.        ./sys_info.sh
.        ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="6.2.1"
from_repo="Estuary"
case $distro in
    "centos")
         pkgs="devtoolset-6-gcc"
         install_deps "${pkgs}" 
         print_info $? devtoolset-6-gcc
         ;;
    *)
     exit 1
        ;;
 esac

# Check the package version && source
from=$(yum info ${pkgs} | grep "From repo" | awk '{print $4}')
if [ "$from" = "$from_repo"  ];then
      print_info 0 repo_check
else
    rmflag=1
    if [ "$from" != "Estuary"  ];then
        yum remove -y ${pkgs}
        yum install -y ${pkgs}
        from=$(yum info ${pkgs} | grep "From repo" | awk '{print $4}')
        if [ "$from" = "$from_repo"   ];then
               print_info 0 repo_check
        else
              print_info 1 repo_check
        fi
    fi
fi

vers=$(yum info ${pkgs} | grep "Version" | awk '{print $3}')
if [ "$vers" = "$version"   ];then
      print_info 0 version
else
      print_info 1 version
fi

######################  environment  restore ##########################

case $distro in
       "centos") 
                 remove_deps "${pkgs}"
                 print_info $? remove-package    
         ;;
esac