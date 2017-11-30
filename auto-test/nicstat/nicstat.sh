

#!/bin/sh -e
set -x
cd ../../utils
    . ./sys_info.sh
cd -
SERVER="127.0.0.1"

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

#while getopts "c:t:p:v:s:h" o; do
 # case "$o" in
  #  c) SERVER="${OPTARG}" ;;
   # t) TIME="${OPTARG}" ;;
    #p) THREADS="${OPTARG}" ;;
    #v) VERSION="${OPTARG}" ;;
    #s) SKIP_INSTALL="${OPTARG}" ;;
   # h|*) usage ;;
 # esac
# done
# distro=`cat /etc/redhat-release | cut -b 1-6`
# Install package
case $distro in
    "centos")
        wget http://sourceforge.net/projects/nicstat/files/nicstat-1.92.tar.gz
        tar -zxvf nicstat-1.92.tar.gz 
        cd nicstat-1.92
        cp Makefile.Linux  Makefile
        sed -i 's/-m32//g' Makefile
        make
        make install
      #  yum install -y nicstat 
         ;;
 esac
# Statistic ethernet flux 5 times
nicstat 1 5

# Statistic ethernet tcp flux
nicstat -t 1 5

# Statistic ethernet udp flux
nicstat -u 1 5

# Parse logfile.

# Remove package
yum remove nicstat -y
