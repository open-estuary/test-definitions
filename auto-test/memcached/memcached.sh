#! /bin/bash

basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../lib/sh-test-lib
. ../../utils/sys_info.sh
dist=`dist_name`
echo $dist

yum install -y memcached
print_info $? "memcacehd install"

yum install -y libevent python-pip
print_info $? "memcacehd preinstall"

pip install -q python-memcached
print_info $? "memcached client install"

su - postgres -c "memcached -d -p 11211 -m 64m"
ps -ef |grep "memcached -d -p" | grep -v grep
print_info $? "memcached start"

res=`echo "stats" | nc localhost 11211`
if [ $? = 0 ];then
    lava-test-case "memcache connect" --result pass
else
    lava-test-case "memcache connect" --result fail
fi
python ./mc.py

yum remove -y memcached
print_info $? "memcached uninstall"

