#! /bin/bash

vsftpd_op()
{
    local cmd=""
    local operation=$1
    local log_file="vsftpd.log"

    case distro in
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

pushd utils
    . ./sys_info.sh
popd

# test case -- start, stop, restart
vsftpd_execute start
vsftpd_execute restart
vsftpd_execute stop

process=$(vsftpd_op status | grep "running")
if [ "$process"x != ""x  ]; then
    vsftpd_op stop
fi

FTP_PUT_LOG=ftp_put_test.log
FTP_GET_LOG=ftp_get_test.log

FTP_USERS=/etc/ftpusers
VSFTPD_CONF=/etc/vsftpd.conf

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
mkdir tmp && pushd tmp
echo 'For ftp put testing' > $FTP_PUT_LOG
echo 'For ftp get testing' > ~/$FTP_GET_LOG

sed -i 's/root/#root/g' $FTP_USERS
sed -i 's/listen=NO/listen=YES/g' $VSFTPD_CONF
sed -i 's/listen_ipv6=YES/#listen_ipv6=YES/g' $VSFTPD_CONF
sed -i 's/#write_enable=YES/write_enable=YES/g' $VSFTPD_CONF

vsftpd_op start
vsftpd_op status

# for get and put test
EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn ftp localhost
expect "Name"
send "\r"
expect "password:"
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

if [ $(find . -name "$FTP_GET_LOG")x != ""x ]; then
    lava-test-case vsftpd-download --result pass
else
    lava-test-case vsftpd-download --result fail
fi

popd

cd ~

if [ $(find . -name 'ftp_put_test.log')x != ""x ]; then
    lava-test-case vsftpd-upload --result pass
else
    lava-test-case vsftpd-upload --result fail
fi

rm -rf tmp
