#!/bin/sh
# Copyright (C) 2017-8-29, Linaro Limited.
#qperf is a tool for testing bandwidth and latency
# Author: mahongxin <hongxin_228@163.com>

set -x

cd ../../utils
    . ./sys_info.sh
cd -

# Test user id
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi
case $distro in
    "centos")
        yum install mariadb.aarch64 -y
        yum install mariadb-server.aarch64 -y
        yum install expect.aarch64 -y
         ;;
esac

#Test ' mariadb test'
#启动暂停重启测试
systemctl start mariadb.service
systemctl stop mariadb.service
systemctl restart mariadb.service
#设置初始化ｒｏｏｔ密码
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysql_secure_installation
expect "Enter current password"
send "\n\n"
expect "Set root password"
send "Y\n"
expect "New password"
send "root\n"
expect "Re-enter new password"
send "root\n"
expect "Remove anonymous users"
send "Y\n"
expect "Disallow root login"
send "Y\n"
expect "Remove test database"
send "Y\n"
expect "Reload privilege"
send "Y\n"
expect eof
EOF
#进行登录测试
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn mysql -u root -p
expect "Enter password"
send "root\n"
expect "MariaDB"
send "exit\n"
expect eof
EOF



#if [ "$str" != "" ] ; then
 #   lava-test-case $TCID --result fail
#else
 #   lava-test-case $TCID --result pass
#fi
#rm wrklog
#pkill wrk

