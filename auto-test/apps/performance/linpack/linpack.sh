#!/bin/sh -e

set -x
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib

ARRAY_SIZE="200"
# Run Test.
#detect_abi
#wget http://www.netlib.org/benchmark/linpackc.new
#print_info $? wget-linpackc

#mv linpackc.new linpack.c
case $distro in
    "centos")
     yum install glibc-static -y
     yum install gcc -y
     yum install wget -y
     print_info $? install-package
     ;;
   "ubuntu|debian")
    apt-get install gcc -y
    apt-get install wget -y
    apt-get install buid-essential -y
    apt-get install glibc-source -y
    print_info $? install-package
esac
wget http://www.netlib.org/benchmark/linpackc.new
print_info $? wget-linpack
mv linpackc.new linpack.c

gcc -O3 -static -o linpack linpack.c -lm
print_info $? gcc-linpack

# shellcheck disable=SC2154
( echo "${ARRAY_SIZE}"; echo "q" ) \
  | ./linpack 2>&1 \
  | tee -a linpack.log
print_info $? run-linpack
# Parse output.
   # kill -9 $(ps -ef |grep linpack |awk'{print $2}'|head -1)
    #print_info $? kill-linpack
case $distro in
    "centos")
        yum remove glibc-static -y
        yum remove gcc -y
        print_info $? remove-package
        ;;

     "ubuntu")
      apt-get remove gcc -y
      apt-get remove glibc-source -y
      apt-get remove buid-essential -y
      print_info $? remove-package
      ;;

esac
rm -f linpack
rm -f linpack.c
rm -f linpack.log
