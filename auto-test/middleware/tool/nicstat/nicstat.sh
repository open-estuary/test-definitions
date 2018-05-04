

#!/bin/sh 
set -x
cd ../../../../utils
    .        ./sys_info.sh
             ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="1.95"
from_repo="Estuary"
package="nicstat"

for P in ${package};do
    echo "$P install"
# Install package
case $distro in
    "centos" )
        #wget http://sourceforge.net/projects/nicstat/files/nicstat-1.92.tar.gz
        #tar -zxvf nicstat-1.92.tar.gz 
        #cd nicstat-1.92
        #cp Makefile.Linux  Makefile
        #sed -i 's/-m32//g' Makefile
        #make
        #make install
        yum install -y $P
        print_info $? nicstat 
         ;;
 esac

# Check the package version && source
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
     print_info 0 version
else
    print_info 1 version
fi
done

# Statistic ethernet flux 5 times
nicstat 1 5
print_info $? statistics

# Statistic ethernet tcp flux
nicstat -t 1 5
print_info $? tcp

# Statistic ethernet udp flux
nicstat -u 1 5
print_info $? udp

# track interface 
nicstat -i eth0
print_info $? eth0

#output in Mbits/sec
nicstat -M
print_info $? Mbits/sec

#list interface(s)
nicstat -l
print_info $? list_interface

#summary output
nicstat -s
print_info $? summary

# Remove package
yum remove -y $P
print_info $? remove
