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

version="1.0.5"
from_repo="base"
package="blktrace"
for P in ${package};do
    echo "$P install"
# Install package
case $distro in
    "centos" )
         yum install -y "$P"
         print_info $? "$P"
         ;;
 esac
# Check the package version && source
 from=$(yum info $P | grep "From repo" | awk '{print $4}')
 if [ "$from" = "$from_repo" ];then
        print_info 0 repo_check
 else
     rmflag=1
     if [ "$from" != "base" ];then
         yum remove -y $P
         yum install -y $P
         from=$(yum info $P | grep "From repo" | awk '{print $4}')
        if [ "$from" = "$from_repo"  ];then
        print_info 0 repo_check
    else
           print_info 1 repo_check
        fi
     fi
 fi

 vers=$(yum info $P | grep "Version" | awk '{print $3}')
 if [ "$vers" = "$version"  ];then
       print_info 0 version
 else
      print_info 1 version
 fi
done

# Display the blktrace result on screen.
blktrace -d /dev/sda -w 5 -o - |blkparse -i -
print_info $? display

# Output the blktrace result on file.
blktrace -d /dev/sda -w 10 -o trace | blkparse -i -
print_info $? output

#data analysis of sda
blkparse -i trace
print_info $? data_analysis

# save to default file
blktrace -d /dev/sda -w 5
print_info $? default_file

# Remove the blktrace package
yum remove -y "$P"
print_info $? remove

rm -rf trace.blktrace.*
rm -rf sdb.blktrace.*
