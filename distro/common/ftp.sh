#! /bin/bash
echo "@@@@@@@@@@@@@@@@@@@@@@@@@#######################"
set -x
log_file="ftp_log.log"

function vsftpd_op()
{
    operation=$1 
    echo "service vsftpd $operation" | tee ${log_file}
    service vsftpd $operation | tee ${log_file}
    if [ 0 -ne $? ]; then
        echo "vsftpd $operation failed"
        lava-test-case vsftpd-$operation --result fail 
    else
        echo "vsftpd $operation pass"
        lava-test-case vsftpd-$operation --result pass
    fi
}

ps_exists=$(`service vsftpd status | grep running`)
if [ "$ps_exists"x != ""x  ]; then
    vsftpd_op 'stop' 
fi

# test case -- start, stop, restart
vsftpd_op 'start'
vsftpd_op 'restart'
vsftpd_op 'stop'

# prepare for the put and get test and the ftp home is ~/
mkdir tmp
pushd tmp && echo 'For ftp put testing' > ftp_put_test.log
echo 'For ftp get testing' > ~/ftp_get_test.log

sed -i 's/root/#root/g' /etc/ftpusers
sed -i 's/listen=NO/listen=YES/g'  /etc/vsftpd.conf
sed -i 's/listen_ipv6=YES/#listen_ipv6=YES/g'  /etc/vsftpd.conf
sed -i 's/#write_enable=YES/write_enable=YES/g'  /etc/vsftpd.conf

service vsftpd start | tee ${log_file}
service vsftpd status | tee ${log_file}
# for get and put test
/usr/bin/expect << EOF
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

if [ $(find . -name 'ftp_get_test.log')x != ""x ]; then
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

lava-test-run-attach ${log_file}
