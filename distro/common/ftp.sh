#! /bin/bash

vsftpd_op()
{
    local cmd=""
    local operation=$1
    local log_file="vsftpd.log"

    #case distro in 
    #add $ liucaili 20170505
    case $distro in
        "ubuntu" | "debian" )
            cmd="service vsftpd $operation"
            echo "$cmd" | tee ${log_file}
            $cmd | tee ${log_file}
            ;;
        * )
            cmd="${operation}_service vsftpd"
            echo "$cmd" | tee ${log_file}
            eval \$$cmd | tee ${log_file}
            ;;
    esac
}

vsftpd_execute()
{
    local operation=$1
    vsftpd_op $operation

    if [ 0 -ne $? ]; then
        echo "vsftpd $operation failed"
        lava-test-case vsftpd-$operation --result fail
    else
        echo "vsftpd $operation pass"
        lava-test-case vsftpd-$operation --result pass
    fi
}

set -x

cd utils
    . ./sys_info.sh
cd -

# test case -- start, stop, restart
vsftpd_execute start
vsftpd_execute restart
vsftpd_execute stop
netstat -na --ip

process=$(vsftpd_op status | grep "running")
if [ "$process"x != ""x  ]; then
    vsftpd_op stop
fi
netstat -na --ip

FTP_PUT_LOG=ftp_put_test.log
FTP_GET_LOG=ftp_get_test.log
if [ "$distro"x = "centos"x ]; 
then
	FTP_USERS=/etc/vsftpd/ftpusers
	VSFTPD_CONF=/etc/vsftpd/vsftpd.conf
else
	FTP_USERS=/etc/ftpusers
	VSFTPD_CONF=/etc/vsftpd.conf
fi

if [ ! -e ${FTP_USERS}.origin ];
then
    cp ${FTP_USERS}{,.origin}
else
    cp ${FTP_USERS}{.origin,}
fi

if [ ! -e ${VSFTPD_CONF}.origin ];
then
    cp ${VSFTPD_CONF}{,.origin}
else
    cp ${VSFTPD_CONF}{.origin,}
fi

# prepare for the put and get test and the ftp home is ~/
mkdir tmp && cd tmp
echo 'For ftp put testing' > $FTP_PUT_LOG
echo 'For ftp get testing' > ~/$FTP_GET_LOG

sed -i 's/root/#root/g' $FTP_USERS
sed -i 's/listen=NO/listen=YES/g' $VSFTPD_CONF
sed -i 's/listen_ipv6=YES/#listen_ipv6=YES/g' $VSFTPD_CONF
sed -i 's/#write_enable=YES/write_enable=YES/g' $VSFTPD_CONF
sed -i 's/userlist_enable=YES/userlist_enable=NO/g' $VSFTPD_CONF

netstat -na --ip
vsftpd_op start
vsftpd_op status
netstat -na --ip

# for get and put test
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn ftp localhost
expect "Name"
send "\r"
expect "password"
send "root\r"
expect "ftp>"
send "get ftp_get_test.log\r"
expect {
   "Transfer complete"
   {
       send "put ftp_put_test.log\r"
       expect "Transfer complete"
   }
   "Failed to open file"
   {
       send "put ftp_put_test.log\r"
       expect "Transfer complete"
   }
   "Connection refused"
   {
       send "put ftp_put_test.log\r"
       expect "Transfer complete"
   }
}
send "quit\r"
expect eof
EOF

if [ $(find . -maxdepth 1 -name "$FTP_GET_LOG")x != ""x ]; then
    lava-test-case vsftpd-download --result pass
else
    lava-test-case vsftpd-download --result fail
fi

cd -

cd ~

if [ $(find . -maxdepth 1 -name "ftp_put_test.log")x != ""x ]; then
    lava-test-case vsftpd-upload --result pass
else
    lava-test-case vsftpd-upload --result fail
fi

rm -rf tmp
