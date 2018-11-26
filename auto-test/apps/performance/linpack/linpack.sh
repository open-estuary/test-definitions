#!/bin/bash 

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi


set -x
source ../../../../utils/sys_info.sh
source ../../../../utils/sh-test-lib

cd -

ARRAY_SIZE="200"

case "$distro" in
    centos|fedora)
	pkgs="glibc-static gcc wget"
	install_deps "${pkgs}"
	print_info $? install_pkgs
        ;;
   ubuntu|debian)
	pkgs="glibc-source gcc wget"
        install_deps "${pkgs}"
        print_info $? install_pkgs
	;;
    opensuse)
	pkgs="glibc-devel-static gcc wget"
        install_deps "${pkgs}"
        print_info $? install_pkgs
        ;;

esac

#download linpack
wget http://www.netlib.org/benchmark/linpackc.new
print_info $? wget-linpack

mv linpackc.new linpack.c

#compile linpack.c
gcc -O3 -static -o linpack linpack.c -lm
print_info $? gcc-linpack

#run linpack
( echo "${ARRAY_SIZE}"; echo "q" ) \
  | ./linpack 2>&1 \
  | tee -a linpack.log
print_info $? run-linpack

#remove packgs
remove_deps "${pkgs}"
print_info $? remove-package

rm -f linpack
rm -f linpack.c
rm -f linpack.log
