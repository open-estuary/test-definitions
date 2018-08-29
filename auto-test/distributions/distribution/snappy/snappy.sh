#!/bin/bash
#Snappy is a compression/decompression library
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
#distro=`cat /etc/redhat-release | cut -b 1-6`
case $distro in
    "centos"|"fedora"|"opensuse")
        pkgs="gcc gcc-c++ make cmake3 wget"
        install_deps "${pkgs}"
	print_info $? install-pkgs
	;;
	"ubuntu"|"debian")
	pkgs="gcc g++ make cmake3 wget"
        install_deps "${pkgs}"
        print_info $? install-pkgs
        ;;
esac
wget http://192.168.50.122:8083/test_dependents/google-snappy-1.1.7-15-gea660b5.tar.gz
        print_info $? get-snappy
tar -zxvf google-snappy-1.1.7-15-gea660b5.tar.gz
        print_info $? decompression

cd google-snappy-ea660b5
mkdir build 
cd build && cmake3 ../ && make 
make install
cd ../

cat << EOF >> ./testsnappy.cc
#include <snappy.h>
#include <string>
#include <iostream>
using namespace std;

int main() {
  string input = "Hello World";
  string output;
  for (int i = 0; i < 5; ++i) {
    input += input;
  }
  snappy::Compress(input.data(), input.size(), &output);
  cout << "input size:" << input.size() << " output size:"
       << output.size() << endl;
  string output_uncom;
  snappy::Uncompress(output.data(), output.size(), &output_uncom);
  if (input == output_uncom) {
    cout << "Equal" << endl;
  } else {
    cout << "ERROR: not equal" << endl;
  }
  return 0;
}

EOF
g++ testsnappy.cc -o testsnappy -lsnappy
	print_info $? compile-snappy
./testsnappy >runsnappy.log
	print_info $? run-snappy
input=`grep  "input" runsnappy.log`
output=`grep "ouput" runsnappy.log`
if [[ "$input" != ""]]&&[[ "$ouput" != ""]];then
	print_info 0 test-snappy
else
	print_info 1 test-snappy
fi
rm -f google-snappy-1.1.7-15-gea660b5.tar.gz
rm -rf google-snappy-ea660b5
case $distro in
    "centos"|"fedora"|"opensuse")
        pkgs="gcc gcc-c++ make cmake3 wget"
        remove_deps "${pkgs}"
        print_info $? install-pkgs
        ;;
        "ubuntu"|"debian")
        pkgs="gcc g++ make cmake3 wget"
        remove_deps "${pkgs}"
        print_info $? install-pkgs
        ;;
esac
