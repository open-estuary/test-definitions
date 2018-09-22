#!/bin/bash
# Author: mahongxin <hongxin_228@163.com>
##file是一个文件，测试它的基本使用功能
set -x

#####加载外部文件################
cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -

#############################  Test user id       #########################
! check_root && error_msg "Please run this script as root."

#######################  testing the step ###########################
#创建文件
touch test.sh
print_info $? create-file

#给文件赋权
chmod 777 test.sh
print_info $? chmod-file

#写入文件内容
echo "hello my test file" > test.sh
print_info $? write-file

#查看文件
cat test.sh
print_info $? cat-file

#复制文件并命名，不改变原文件
cp test.sh test2.sh
print_info $? cp-file

#合并文件
cat test.sh test2.sh >test3.sh
print_info $? bing_file

#清空文件内容
true >test.sh
print_info $? true-file

#复制文件并命名，删除原文件
mv test.sh test1.sh
print_info $? rename-file

#删除文件
rm test1.sh
print_info $? rm-file
