#!/bin/sh
# Author: mahongxin <hongxin_228@163.com>
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
case $distro in
    "centos"|"ubuntu")
        yum install wget -y
        yum install unzip -y
        yum install zip -y
        pkg="wget unzip zip"
        install_deps "${pkg}"
        print_info $? install-pkg
        ;;
esac
wget http://192.168.50.122:8083/test_dependents/netperf-2.7.0.tar.gz

tar -zxvf netperf-2.7.0.tar.gz
print_info $? tar-compressedpackage

rm -f netperf-2.7.0.tar.gz

tar -cvzf netperf-2.7.0.tar.gz netperf-2.7.0
print_info $? tar-packaging

wget http://192.168.50.122:8083/test_dependents/cryptopp-CRYPTOPP_5_6_5.zip
mv cryptopp-CRYPTOPP_5_6_5.zip cryp.zip
unzip cryp.zip
print_info $? unzip-compressedpackage

rm -f cryp.zip
zip cryp.zip cryptopp-CRYPTOPP_5_6_5
print_info $? zip-packaging

rm -rf netperf*
rm -rf cryp*
