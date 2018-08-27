#!/bin/bash
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh
case $distro in
    "centos"|"fedora")
	pkgs="pcre-devel gcc-c++"
	install_deps "${pkgs}"
	print_info $? install-pcre
	;;
    "ubuntu"|"debian")
	apt install aptitude -y
        pkgs="libpcre3 libpcre3-dev g++"
        install_deps "${pkgs}"
        print_info $? install-pcre
        ;;
    "opensuse")
	pkgs="pcre-devel gcc"
        install_deps "${pkgs}"
        print_info $? install-pcre
        ;;

esac

#pcre build
g++ -o pcre test_pcre.cpp -lpcre
print_info $? pcre_build

#run test_pcre.cpp
./pcre > log 2>&1
print_info $? run-cpp

cat log  | grep "PCRE compilation pass"
print_info $? regular-comilation

cat log  | grep "OK, has matched"
print_info $? regular-matches

cat log  | grep "free ok"
print_info $? regular-release

case $distro in
    "ubuntu"|"debian")
	aptitude remove libpcre3 -y
	aptitude remove libpcre3-dev -y
	#aptitude remove g++ -y
	print_info $? remove-pkgs
        ;;
    "centos"|"fedora"|"opensuse")
	remove_deps  "${pkgs}"
	print_info $? remove-pkgs
	;;
esac
rm -rf pcre
