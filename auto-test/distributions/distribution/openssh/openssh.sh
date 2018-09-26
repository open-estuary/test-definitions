#! /bin/bash

#=================================================================
#   文件名称：openssh.sh
#   创 建 者：dingyu ding_yu@hoperun.com
#   描    述：OpenSSH 是 SSH 协议的免费开源实现,OpenSSH提供了服务端后台程序和客户端工具，用来加密远程控制和文件传输过程中的数据.
#
#================================================================*/

set -x

cd ../../../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

! check_root && error_msg "Please run this script as root."


##################### Environmental preparation  ##############################
case $distro in
    "ubuntu"|"debian")
        pkgs="openssh-server expect"
        install_deps "${pkgs}"
        print_info $? install-package
        ;;
    "centos"|"fedora")
        pkgs="openssh-server.aarch64 expect"
        install_deps "${pkgs}"
	print_info $? install-package
        ;;
    "opensuse")
	pkgs="openssh expect"
	install_deps "${pkgs}"
        print_info $? install-package
        ;;
esac

#################### testing the step ########################################

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
expect {
"*yes/no" 
{send "yes\r";exp_continue;}
"*assword:" 
{send "root\r";}
} 
expect eof
EOF
print_info $? test-login


#测试sftp上传下载功能
$EXPECT << EOF
set timeout 100
spawn sftp localhost
expect {
"*yes/no"
{send "yes\r";exp_continue;}
"*assword:"
{send "root\r";}
} 
expect "sftp>"
send "get sftp_get_test.log\r";
expect "sftp>"
send "put sftp_put_test.log\r";
expect "sftp>"
send "quit\r";

expect eof
EOF

#测试下载结果
if [ $(find . -maxdepth 1 -name "$FTP_GET_LOG")x != ""x ]; then
	print_info 0  sftp-get
else
	print_info 1  sftp-get
fi

cd ../
rm -rf tmp

cd ~

#测试上传结果
if [ $(find . -maxdepth 1 -name "sftp_put_test.log")x != ""x ]; then
	print_info 0  sftp-put
else
	print_info 0  sftp-put
fi

######################## environment  restore ###########################
remove_deps "expect"
print_info $? remove-package
