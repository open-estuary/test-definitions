#!/bin/sh
# Copyright (C) 2017-12-28.
#search engine
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

install_deps "jmeter"
print_info $? install-jmeter

Check_Version "3.3"
print_info $? jmeter-version

Check_Repo "Estuary"
print_info $? jmeter-repo

pkgs="java nginx vim git expect"
install_deps "${pkgs}"
print_info $? install-depends

java -version
print_info $? java-version

systemctl restart nginx
print_info $? restart-web-server

jmeter -v
print_info $? jmeter-deploy

#./jmeter -n -t my_test.jmx -l test.jtl 2>&1 | tee jmeter.log
jmeter -n -t /opt/jmeter/bin/examples/CSVSample.jmx -l result.csv -j log.log
print_info $? run-jmeter

cat result.csv | grep false
if [ $? ] ; then
	print_info 0 run-sample-jmx
else
	print_info 1 run-sample-jmx
fi

systemctl stop nginx
print_info $? stop-web-server

remove_deps "jmeter"
print_info $? install-jmeter

pkgs="java nginx"
remove_deps "${pkgs}"
print_info $? install-depends

rm -f result.csv log.log
