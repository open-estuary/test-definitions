#!/bin/bash
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
       "ubuntu"|"debian"|"fedora"|"opensuse")
        pkgs="busybox"
        install_deps "${pkgs}"
        print_info $? busybox_install
        ;;
        *)
        exit 1
        ;;
esac

commond="busybox"

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

#uninstall
remove_deps "${pkgs}"
print_info $? remove-package
rm -rf dir
