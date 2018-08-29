#!/bin/sh 
set -x
cd ../../../../utils
    .        ./sys_info.sh
    .         ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

version="1.0.5"
from_repo="base"
pkgs="blktrace"
#case $distro in
 #   "centos" )
         install_deps "${pkgs}"
         print_info $? install-blktrace
  #       ;;
 #esac
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
remove_deps "${pkgs}"
print_info $? remove

rm -rf trace.blktrace.*
rm -rf sda.blktrace.*
