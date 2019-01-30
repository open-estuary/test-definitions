# Copyright (C) 2017-11-08, Linaro Limited.
# Author: mahongxin <hongxin_228@163.com>
# Test user idcd -  bandwidth and latencyqperf is a tool for testing

#!/bin/bash
set -x

cd ../../../../utils

 . ./sys_info.sh
 . ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
"centos")
     yum remove phantomjs -y
     pkgs="gcc gcc-c++ make openssl-devel freetype-devel fontconfig-devel phantomjs"
     install_deps "${pkgs}"
     print_info $? install-phantomjs
     ;;
 "ubuntu")
     apt-get install phantomjs -y
     print_info $? install-phantomjs
     ;;
esac

#验证hello world功能
phantomjs hello.js > phantomjs.log 2>&1
sleep 3

grep "hello,world!" phantomjs.log
print_info $? phantomjs-helloword


#验证截图功能
if [ -d test/ ];then
    rm -rf test/
fi

phantomjs a.js > phantomjs.log 2>&1
sleep 3

if [ -d test/ ];then
    print_info 0 phantomjs-screenshots
else
    print_info 1 phantomjs-screenshots
fi


#验证传递参数功能
phantomjs arguments.js foo bar baz > phantomjs.log 2>&1
sleep 3

grep "foo" phantomjs.log
print_info $? phantomjs-parameters


#加载页面的时间
phantomjs loadspeed.js https://baidu.com > phantomjs.log 2>&1
sleep 3

grep "Loading" phantomjs.log
print_info $? phantomjs-loadingpage


#获取到百度的标题
phantomjs demo.js > phantomjs.log 2>&1
sleep 3

grep "success" phantomjs.log
print_info $? phantomjs-title


case $distro in
    "centos")
        yum remove phantomjs -y
        print_info $? remove-phantomjs
        ;;
    "ubuntu")
        apt-get remove phantomjs -y
        print_info $? remove-phantomjs
        ;;
esac


