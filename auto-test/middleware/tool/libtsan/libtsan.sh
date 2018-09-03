
#!/bin/sh 
set -x
cd ../../../../utils
    .        ./sys_info.sh
 .            ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="6.2.1"
from_repo="Estuary"
#package="libtsan"
#for P in ${package};do
#    echo "$P install"

case $distro in
    "centos")
        package="libtsan" 
        install_deps "${package}"
         print_info $? install-package
         ;;
    "ubuntu"|"opensuse")
        package="libtsan0" 
        install_deps "${package}"
	print_info $? install-package
	;;
    "fedora")
	package="libtsan.aarch64"
	install_deps "${package}"
	print_info $? install-package
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
if [ "$vers" = "$version"  ];then
     print_info 0 version
else
    print_info 1 version
fi
;;
esac

case $distro in
   "ubuntu")
	from=$(apt show $package | grep Source)
	    print_info $? from
	vers=$(apt show $package | grep Version)
            print_info $? vers
    ;;
esac
case $distro in 
     "opensuse")
     from=$(zypper info $package |grep Source)
           print_info $? from
           vers=$(zypper info $package |grep Vesion)
           print_info $? vers
	   ;;
esac	       
case $distro in
   "fedora")
      from=$(yum info $package |grep Source )
      print_info $? from
      vers=$(yum info $package |grep Version)
      print_info $? vers
  ;;
esac


# Remove package
case $distro in
     "centos"|"ubuntu"|"fedora"|"opensuse")
        remove_deps "${package}"
        print_info $? remove_package
        ;;
esac
#yum remove -y $P
#print_info $? remove
