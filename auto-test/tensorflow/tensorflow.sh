#!/bin/bash

set -x

cd ../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

version=`python -V`
if [ $version > 2 && $version < 3 ];then
	print_info 0 python-version
else
	install_deps python
	python -V
	print_info $? python-version
fi

wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
print_info $? install-pip

pkgs="expect tensorflow"
install_deps "${pkgs}"
print_info $? install-tensorflow


remove_deps tensorflow
print_info $? remove-tensorflow
