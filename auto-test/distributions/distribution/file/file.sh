#!/bin/sh
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
touch test.sh
print_info $? create-file

chmod 777 test.sh
print_info $? chmod-file

echo "hello my test file" > test.sh
print_info $? write-file

cat test.sh
print_info $? cat-file

mv test.sh test1.sh
print_info $? rename-file

rm test1.sh
print_info $? rm-file
