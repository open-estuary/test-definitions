#!/bin/sh -e

set -x
. ../../../../utils/sys_info.sh
. ../../../../lib/sh-test-lib
cd -
ARRAY_SIZE="200"
# Run Test.
#detect_abi
wget http://www.netlib.org/benchmark/linpackc.new
print_info $? wget-linpackc

mv linpackc.new linpack.c
case $distro in
    "centos")
     yum install glibc-static -y
     yum install gcc -y
     print_info $? install-package
     ;;
   "ubuntu|debian")
    apt-get install gcc -y
    apt-get install buid-essential -y
    apt-get install glibc-source -y
    print_info $? install-package
esac

gcc -O3 -static -o linpack linpack.c -lm
print_info $? gcc-linpack

# shellcheck disable=SC2154
( echo "${ARRAY_SIZE}"; echo "q" ) \
  | ./linpack 2>&1 \
  | tee -a linpack.log
print_info $? run-linpack
# Parse output.
count=`ps -aux | grep linpack | wc -l`
if [ $count -gt 0 ]; then
    kill -9 $(pidof linpack)
    print_info $? kill-linpack
fi
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
