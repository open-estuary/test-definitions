#!/bin/sh -e
set -x
cd ../../utils
    . ./sys_info.sh
      ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

# Install blktrace package
case $distro in
    "centos" )
         yum install -y "${pkgs}"
         ;;
 esac
print_info $? install

# Display the blktrace result on screen.
blktrace -d /dev/sda -w 5 -o - |blkparse -i -
print_info $? display

# Output the blktrace result on file.
blktrace -d /dev/sda -w 10 -o trace | blkparse -i -
print_info $? output

# Remove the blktrace package
yum remove -y blktrace
print_info $? remove-blktrace
