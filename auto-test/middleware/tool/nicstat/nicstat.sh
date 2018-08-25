

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

version="1.95"
from_repo="Estuary"
pkgs="nicstat"

case $distro in
    "centos"|"debian"|"fedora"|"ubuntu")
        install_deps "${pkgs}"
        print_info $? nicstat 
         ;;
 esac


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
inet=`ip link|grep "state UP"|awk '{print $2}'|sed 's/://g'|awk '{print$1}'|head -1`
nicstat -i $inet
print_info $? network

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
remove_deps "${pkgs}"
print_info $? remove-pkgs
