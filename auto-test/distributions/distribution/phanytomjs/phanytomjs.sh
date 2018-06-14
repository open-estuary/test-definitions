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
     yum install phantomjs -y
     print_info $? install-phantomjs
     ;;
 "ubuntu")
     apt-get install phantomjs -y
     print_info $? install-phantomjs
     ;;
esac

#验证截图功能
phantomjs ./a.js
print_info $? phantomjs-screenshots

#验证hello world功能
phantomjs ./hello.js 2>&1 | tee phantomjs.log
print_info $? phantomjs-helloword

#验证传递参数功能
phantomjs ./arguments.js foo bar baz 2>&1 |tee -a  phantomjs.log
print_info $? phantomjs-parameters

#加载页面的时间
phantomjs ./loadspeed.js https://www.baidu.com 2>&1 | tee -a phantomjs.log
print_info $? phantomjs-loadingpage

#获取到百度的标题
phantomjs ./title.js 2>&1 | tee -a phantomjs.log
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


