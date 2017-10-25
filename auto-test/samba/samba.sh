#! /bin/bash

set -x

cd ../../utils
    . ./sys_info.sh
cd -

case $distro in
    "ubuntu")
          apt-get install samba -y
          apt-get install smbclient -y
          apt-get install expect -y
          ;;
    "centos")
          yum install samba -y
          yum install samba-client.aarch64 -y
          yum install expect -y
          ;;
     "opensuse")
          zypper install -y samba
          ;;
esac
case $distro in
    "ubuntu")
         systemctl start samba
         print_info $? start_smb
         systemctl restart samba
         print_info $? restart_smb
         systemctl stop samba
         ;;
    "centos")
         systemctl restart nmb.service smb.service
         print_info $? restart_smb
         systemctl start nmb.service smb.service
         print_info $? start_smb
         systemctl stop nmb.service smb.service
         ;;
esac

SMB_CONF=/etc/samba/smb.conf
if [ ! -e ${SMB_CONF}.origin ];
then
    cp ${SMB_CONF}{,.origin}
else
    cp ${SMB_CONF}{.origin,}
fi

cat << EOF >> /etc/samba/smb.conf
[share]
    comment = Anonymous share
    path = /srv/samba/share
    public = yes
    browsable =yes
    writable = yes
    guest ok = yes
    read only = no
EOF

SMB_ROOT=/srv/samba
mkdir -p $SMB_ROOT/share
cd $SMB_ROOT
chmod -R 0755 share/
case $distro in
    "ubuntu" | "debian")
         chown -R nobody:nogroup share/
         ;;
     * )
         chown -R nobody:nobody share/
         ;;
esac

systemctl restart samba
systemctl restart nmb.service smb.service
groupadd smbgrp
useradd smb -G smbgrp

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 100
spawn smbpasswd -a smb
expect "New SMB password:"
send "smb\r"
expect "Retype new SMB password:"
send "smb\r"
expect eof
EOF
print_info $? smb_add_user

mkdir -p $SMB_ROOT/secured
cd $SMB_ROOT
chmod -R 0777 secured/
chown -R smb:smbgrp secured/

cat << EOF >> /etc/samba/smb.conf
[secured]
    comment = Secured share
    path = /srv/samba/secured
    valid users = @smbgrp
    guest ok = no
    writable = yes
    browsable = yes
EOF

systemctl restart samba

SMB_GET_LOG=smb_get_test.log
SMB_PUT_LOG=smb_put_test.log
mkdir tmp && cd tmp
echo 'For samba put testing' > $SMB_PUT_LOG
echo 'For samba get testing' > $SMB_ROOT/share/$SMB_GET_LOG

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 10
spawn testparm
expect "Press enter to see"
send "\r"
expect eof
EOF
print_info $? test_parm

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 10
spawn smbclient //localhost/share -U user
expect "password:"
send "\r"
expect "smb: \> "
send "ls\r"
expect "available"
send "get smb_get_test.log\r"
expect "getting"
send "put smb_put_test.log\r"
expect "putting"
send "quit\r"
expect eof
EOF
print_info $? anony_test_share


EXPECT=$(which expect)
$EXPECT << EOF
set timeout 10
spawn smbclient //localhost/secured -U user
expect "password:"
send "\r"
expect "tree connect failed"
EOF
print_info $? anony_test_secured

EXPECT=$(which expect)
$EXPECT << EOF
set timeout 10
spawn smbclient //localhost/secured -U smb
expect "password:"
send "smb\r"
expect "smb: \> "
send "ls\r"
expect "available"
send "quit\r"
expect eof
EOF
print_info $? group_test_secured


if [ $(find . -maxdepth 1 -name "$SMB_GET_LOG")x != ""x ]; then
    lava-test-case samba-download --result pass
else
    lava-test-case samba-download --result fail
fi

cd $SMB_ROOT/share

if [ $(find . -maxdepth 1 -name "$SMB_PUT_LOG")x != ""x ]; then
    lava-test-case samba-upload --result pass
else
    lava-test-case samba-upload --result fail
fi

cd -

cd ..

rm -rf tmp


