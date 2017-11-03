#! /bin/bash

basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../lib/sh-test-lib
dist=`dist_name`
echo $dist


yum install -y memcached
yum install -y libevent python-pip
pip install -y python-memcached
su - postgres -c memcached -d -p 11211 -m 64m
res=`echo "stats" | nc localhost 11211`
if [ $? = 0 ];then
    lava-test-case "memcache connect" --result pass
else
    lava-test-case "memcache connect" --result fail
fi

