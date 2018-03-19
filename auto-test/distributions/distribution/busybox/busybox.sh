#!/bin/sh
# Busybox smoke tests.

# shellcheck disable=SC1091
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
        yum install gcc -y
        yum install make -y
        yum install bzip2 -y
        yum install wget -y
        wget https://busybox.net/downloads/busybox-1.27.2.tar.bz2
        print_info $? download-busybox
        tar -jxf busybox-1.27.2.tar.bz2
        print_info $? tar-busybox

        cd busybox-1.27.2/
        make defconfig
        make
        print_info $? make-busybox
        ;;
esac
case $distro in
    "centos")
     commond="./busybox"
     ;;
    "debian")
     commond="busybox"
     ;;
esac

$commond pwd
print_info $? busybox-pwd


$commond mkdir dir
print_info $? busybox-mkdir

$commond touch dir/file.txt
print_info $? busybox-touch

$commond ls dir/file.txt
print_info $? busybox-ls

$commond cp dir/file.txt dir/file.txt.bak
print_info $? busybox-cp

$commond rm dir/file.txt.bak
print_info $? busybox-rm

$commond echo 'busybox test' > dir/file.txt
print_info $? busybox-echo

$commond cat dir/file.txt
print_info $? busybox-cat

$commond grep 'busybox' dir/file.txt
print_info $? busybox-grep

# shellcheck disable=SC2016
$commond awk '{printf("%s: awk\n", $0)}' dir/file.txt
print_info $? busybox-awk

$commond free
print_info $? busybox-free

$commond df
print_info $? busybox-df

case $distro in
    "centos")
     yum remove gcc -y
     yum remove make -y
     yum remove bzip2 -y
     print_info $? remove-package
     ;;
esac
