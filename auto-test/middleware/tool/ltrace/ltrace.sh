#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../../../utils
    .        ./sys_info.sh
             ./sh-test-lib
cd -

# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "debian")
        apt-get install gcc -y
        print_info $? gcc
        apt-get install build-essential
        print_info $? buid-essential
        apt-get install ltrace -y
        print_info $? ltrace
         ;;
esac
cat <<EOF >> ./hello.c
#include <stdio.h>
int main()
{
    printf("hello world\n");
    return 0;
}
EOF

gcc hello.c -o hello
print_info $? gcc-hello.c

./hello
print_info $? run-hello

#可以看到程序调用了puts()函数
ltrace ./hello  2>&1 | tee ltrace-hello.log
print_info $? ltrace-hello

#把系统调用都打印出来
ltrace -S ./hello 2>&1 | tee ltrace-s-hello.log
print_info $? ltrace-S-hello

#耗时
ltrace -c dd if=/dev/urandom of=/dev/null count=1000 2>&1 | tee ltrace-c-hello.log
print_info $? ltrace-c-hello

#输出调用时间开销
ltrace -T ./hello 2>&1 | tee ltrace-T-hello.log
print_info $? ltrace-T-hello

count=`ps -aux | grep ltrace | wc -l`
if [ $count -gt 0 ]; then
    kill -9 $(pidof ltrace)
     print_info $? kill-ltrace
fi

apt-get remove ltrace -y
print_info $? remove-ltrace

apt-get remove gcc -y
print_info $? remove-gcc

apt-get remove build-essential -y
print_info $? remove-build-essential -y


