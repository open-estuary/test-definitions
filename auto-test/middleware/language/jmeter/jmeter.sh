#!/bin/bash
# Copyright (C) 2017-12-28.
#search engine
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -
case $distro in
    centos)
    install_deps "jmeter java-1.8.0-openjdk"
    jm=jmeter
    print_info $? install-jmeter
    ;;
    debian|ubuntu)
    install_deps "nginx jmeter openjdk-8-jdk"
    jm=jmeter
    print_info $? install-jmeter
    ;;
    fedora)
    install_deps "java-1.8.0-openjdk jmeters"
    jm=jmeters
    print_info $? install-jmeter
    ;;
esac
jmeter -v 
print_info $? jmeter-version

#Check_Repo "Estuary"
#print_info $? jmeter-repo
which java
if [ $? eq 0 ];then
	install_deps "java"
	print_info $? install-java
fi

pkgs="nginx vim git expect"
install_deps "${pkgs}"
print_info $? install-depends

java -version
print_info $? java-version

systemctl restart nginx
print_info $? restart-web-server

$jm -v
print_info $? jmeter-deploy

${jm}  -n -t my_test.jmx -l test.jtl 2>&1 | tee jmeter.log
${jm} -n -t /opt/jmeter/bin/examples/CSVSample.jmx -l result.csv -j log.log
print_info $? run-jmeter

cat result.csv | grep false
if [ $? ] ; then
	print_info 0 run-sample-jmx
else
	print_info 1 run-sample-jmx
fi

systemctl stop nginx
print_info $? stop-web-server
case $distro in
  centos|debian|ubuntu)
     remove_deps "jmeter"
     print_info $? remove-jmeter
     ;;
   fedora)
     remove_deps "jmeters"
     print_info $? remove-jmeter
     ;;
esac
pkgs="nginx"
remove_deps "${pkgs}"
print_info $? remove-depends

rm -f result.csv log.log
