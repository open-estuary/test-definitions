#!/bin/sh
#Boots is a standard library for c++,portable,and available source code
#Author mahongxin <hongxin_228@163.com>
set -x
cd ../../utils
. ./sys_info.sh
cd -

#Test user id
if [ `whoami` != 'root' ]; then
    echo "You must be the superuser to run this script" >$2
    exit 1
fi
case $distro in
    "ubuntu")
        apt-get install gcc -y
        apt-get install g++ -y
        wget http://192.168.1.107/boost_1_63_0.tar.gz
        tar -zxvf boost_1_63_0.tar.gz
        cd boost_1_63_0
        sudo ./bootstrap.sh
        ./b2 install
        ;;
esac
touch test_boost.cpp
chmod 777 test_boost.cpp
cat <<EOF >> test_boost.cpp
#include <boost/version.hpp>
#include <boost/config.hpp>
#include <boost/lexical_cast.hpp>
#include <iostream>
using namespace std;
int main()
{
    using boost::lexical_cast;
    int a=lexical_cast<int>("123456");
    double b=lexical_cast<double>("123.456");
    std::cout << a << std::endl;
    std::cout << b << std::endl;
    return 0;
}
EOF
g++ -Wall -o test_boost test_boost.cpp
./test_boost >> boost.log
str=`grep -Po "123456" boost.log`
TCID="boost1.63.0 -test"
if [ "$str" != "" ]; then
    lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi

