#!/bin/bash
#DNS is the server responsibel for domain name resolution
#Author:mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -
#Test user id
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

case $distro in
    "centos")
      ./centos_dns.sh
     ;;
     "ubuntu")
      ./ubuntu_dns.sh
     ;;
     "debian")
      ./debian_dns.sh
     ;;
     "fedora")
     ./fedora_dns.sh
     ;;
    "opensuse")
     ./opensuse_dns.sh
     ;;
esac
      
