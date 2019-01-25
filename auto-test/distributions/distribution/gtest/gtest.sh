#!/bin/bash
#gtest is Google's Unit test tool
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi

function install_baseTools()
{
    case $distro in
        "centos"|"fedora"|"opensuse")
            pkgs="gcc gcc-c++ git make wget"
            install_deps "${pkgs}"
            ;;
        "ubuntu"|"debian")
	    pkgs="gcc g++ git make wget cmake"
            install_deps "${pkgs}"
	    print_info $? install-baseTools
            ;;

   esac
}


function gtest_install(){
#wget https://github.com/google/googletest/archive/release-1.8.1.tar.gz
wget ${ci_http_addr}/test_dependents/release-1.8.1.tar.gz

tar -zxvf release-1.8.1.tar.gz && rm -rf release-1.8.1.tar.gz

cd googletest-release-1.8.1
mkdir build && cd build && cmake ..
print_info $? gtest_camke

make
make install
print_info $? gtest_install

cd ../../

}


function gtest_testing()
{
g++  test.cc -lgtest -lpthread
print_info $? gtest_compile1


./a.out > gtest.log
TESE1=`grep "PASSED" gtest.log`
if [ "$TESE1"x != ""x ];then
	print_info 0 gtest_testing
else
	print_info 1 gtest_testing
fi

}

function gtest_testSuit(){
g++  testSuit.cc -lgtest -lpthread
print_info $? gtest_compile2


./a.out > gtest.log
TEST2=`grep "PASSED" gtest.log`
if [ "$TEST2"x != ""x ];then
	print_info 0 gtest_testSuit
else
	print_info 1 gtest_testSuit
fi


}

function gtest_remove()
{
    case $distro in
        "centos"|"fedora"|"opensuse")
	    rm -rf googletest-release-1.8.1 
            print_info $? remove-gtest
            ;;
        "ubuntu"|"debian")
	    rm -rf googletest-release-1.8.1
	    print_info $? remove-gtest
esac

}


function main()
{
    install_baseTools
    gtest_install
    gtest_testing
    gtest_testSuit
    gtest_remove


}


main 





