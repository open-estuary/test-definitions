#!/bin/sh 
set -x
cd ../../../../utils
.  ./sys_info.sh
.  ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="6.2.1"
from_repo="Estuary"
#package="liblsan"
#for P in ${package};do
#    echo "$P install"

case $distro in
    "centos" )
         package="liblsan"
         install_deps "${package}"
         print_info $? install-package
         ;;
     "ubuntu"|"opensuse")
	 package="liblsan0"
	 install_deps "${package}"
	 print_info $? install-package
         ;;
      "fedora")
	  package="liblsan.aarch64"
	  install_deps "${package}"
	  print_info $? install-package
	  ;;
 esac
case $distro in
     "centos")
# Check the package version && source
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
case $distro in
     "ubuntu")
      from=$(apt show $package|grep Source|head -1|awk '{print $2}')
      print_info $? $from
      vers=$(apt show $package|grep Version|awk '{print $2}')
      print_info $? $vers
	;;
esac
case $distro in
     "opensuse")
	     from=$(zypper info $package | grep "Repo" | awk '{print $3}')
	     if [ "$from" = "$from_repo"  ];then
		         print_info 0 repo_check
		 else
	     rmflag=1
	     if [ "$from" != "Estuary"  ];then
	     zypper remove -y $package
	     zypper install -y $package
	     from=$(zypper info $package | grep "From repo" | awk '{print $4}')
	     if [ "$from" = "$from_repo"   ];then
	        print_info 0 repo_check
	     else
		print_info 1 repo_check
		fi													      					
             fi
     fi
      vers=$(zypper info $package|grep Version|awk '{print $3}')
      print_info $? $vers
	 ;;
    	     
esac
case $distro in
     "fedora")
	 from=$(yum info $package|grep "From repo"|awk '{print $4}')
	 print_info $? $from
	 vers=$(yum info $package|grep Version|awk '{print $3}')
	 print_info $? $vers
	     ;;
esac

#done
case $distro in 
    "centos"|"ubuntu"|"fedora"|"opensuse")
       remove_deps "${package}"
       print_info $? remove_package
       ;;
esac


