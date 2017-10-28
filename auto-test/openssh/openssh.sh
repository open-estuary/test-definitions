#! /bin/bash

set -x

cd ../../utils
    . ./sys_info.sh
cd -

case $distro in
    "ubuntu")
        apt-get install openssh-server  -y
        apt-get install expect -y
        ;;
    "centos")
        yum install openssh-server.aarch64 -y
        yum install expect -y
        ;;
    "opensuse")
        zypper install -y openssh
        zypper install -y expect
        ;;
esac

FTP_PUT_LOG=sftp_put_test.log
FTP_GET_LOG=sftp_get_test.log

# prepare for the put and get test and the ftp home is ~/
mkdir tmp && cd tmp
echo 'For ftp put testing' > $FTP_PUT_LOG
echo 'For ftp get testing' > ~/$FTP_GET_LOG
#测试ssh登录是否成功
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn ssh localhost
#expect "Are you sure"
expect {
"*yes/no" { send "yes\r"; exp_continue }
"*assword:" { send "root\r" }
}
#send "yes\n"
#expect "*assword:"
#send "root\n"
expect eof
EOF

#for get and put test "EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn sftp localhost
expect "(password|Password)"
send "root\r"
expect "sftp>"
send "get sftp_get_test.log\r"
expect "sftp>"
send "put sftp_put_test.log\r"
expect "sftp>"
send "quit\r"
expect eof
EOF

if [ $(find . -maxdepth 1 -name "$FTP_GET_LOG")x != ""x ]; then
    lava-test-case sftp-download --result pass
else
    lava-test-case sftp-download --result fail
fi

cd -

cd ~

if [ $(find . -maxdepth 1 -name "sftp_put_test.log")x != ""x ]; then
    lava-test-case sftp-upload --result pass
else
    lava-test-case sftp-upload --result fail
fi

rm -rf tmp
