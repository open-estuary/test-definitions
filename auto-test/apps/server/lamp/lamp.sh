#!/bin/bash

set -x
cd ../../../../utils
   source ./sys_info.sh
   source ./sh-test-lib
cd -

pkg="curl net-tools expect"
install_deps "${pkg}"
print_info $? install-tools

case "$distro" in
    centos)
	systemctl stop nginx
	systemctl stop httpd
	;;
    debian)
	systemctl stop nginx 
	systemctl stop apache2
	apt-get remove apache2 --purge -y
	apt-get remove nginx --purge -y
	apt-get remove php-fpm --purge -y
	;;
esac

pro=`netstat -tlnp|grep 80|awk '{print $7}'|cut -d / -f 1|head -1`
process=`ps -ef|grep $pro|awk '{print $2}'`
for p in $process
do
        kill -9 $p
done


    case "${distro}" in
      debian)
        if [ "${distro}" = "debian" ]; then
            pkgs="apache2 php-fpm mysql-server php-mysql php-common libapache2-mod-php"
        elif [ "${distro}" = "ubuntu" ]; then
            echo mysql-server mysql-server/root_password password lxmptest | sudo debconf-set-selections
            echo mysql-server mysql-server/root_password_again password lxmptest | sudo debconf-set-selections
           pkgs="apache2 mysql-server php-mysql php-common libapache2-mod-php"
        fi
        install_deps "${pkgs}"
        print_info $? install-pkgs
	case "$distro" in
            debian)
            echo "extension=mysqli.so">> /etc/php/7.0/apache2/php.ini
	    ;;
	 esac
        systemctl start apache2
        systemctl start mysql
        ;;
      centos)
        yum remove -y `rpm -qa | grep -i mysql`
        yum remove -y `rpm -qa | grep -i alisql`
        yum remove -y `rpm -qa | grep -i percona`
        yum remove -y `rpm -qa | grep -i mariadb`
        #yum install curl -y
        #yum install httpd -y
        #yum install mysql-community-server -y
        #yum install php php-mysql -y
        pkgs="httpd mysql-community-server php php-mysql"
        install_deps "${pkgs}"
        print_info $? install-pkgs
        systemctl start httpd.service
        systemctl start mysql
        ;;
      *)
        error_msg "Unsupported distribution!"
    esac
#fi

sed -i "s/Nginx/Apache/g" ./html/index.html
cp ./html/* /var/www/html/

# Test Apache.
curl -o "output" "http://localhost/index.html"
cat output
grep "Test Page for the Apache HTTP Server" ./output
print_info $? apache2-test-page

# Test MySQL.
case "${distro}" in
    centos)
        mysqladmin -u root password root
        print_info $? set-root-pwd
        ;;
    debian)
        EXPECT=$(which expect)
        $EXPECT << EOF
        set timeout 100
        spawn mysql -u root -p
        expect "password:"
        send "root\r"
        expect ">"
        send "use mysql;\r"
        expect ">"
        send "UPDATE mysql.user SET authentication_string=PASSWORD('Avalon'), plugin='mysql_native_password' WHERE user='root';\r"
        expect "OK"
        send "UPDATE user SET authentication_string=PASSWORD('lxmptest') where USER='root';\r"
        expect "OK"
        send "FLUSH PRIVILEGES;\r"
        expect "OK"
        send "exit\r"
        expect eof
EOF
        print_info $? set-root-pwd
        ;;
esac

case "${distro}" in
    ubuntu|debian)
        $EXPECT << EOF
        set timeout 100
        spawn mysql -uroot -p
        expect "password:"
        send "lxmptest\r"
        expect ">"
        send "use mysql;\r"
        expect ">"
        send "UPDATE mysql.user SET authentication_string=PASSWORD('Avalon'), plugin='mysql_native_password' WHERE user='root';\r"
        expect "OK"
        send "UPDATE user SET authentication_string=PASSWORD('root') where USER='root';\r"
        expect "OK"
        send "FLUSH PRIVILEGES;\r"
        expect "OK"
        send "exit\r"
        expect eof      
EOF
        ;;
esac

#mysqladmin -u root password root  > /dev/null 2>&1 || true
mysql --user="root" --password="root" -e "show databases"
print_info $? mysql-show-databases

# Test PHP.
curl -o "output" "http://localhost/info.php"
cat output
grep "PHP Version" ./output
print_info $? phpinfo

# PHP Connect to MySQL.
curl -o "output" "http://localhost/connect-db.php"
cat output
grep "Connected successfully" ./output
#exit_on_fail "php-connect-db"
print_info $? php-connect-db

# PHP Create a MySQL Database.
curl -o "output" "http://localhost/create-db.php"
cat output
grep "Database created successfully" ./output
print_info $? php-create-db

# PHP Create MySQL table.
curl -o "output" "http://localhost/create-table.php"
cat output
grep "Table MyGuests created successfully" ./output
print_info $? php-create-table

# PHP add record to MySQL table.
curl -o "output" "http://localhost/add-record.php"
cat output
grep "New record created successfully" ./output
print_info $? php-add-record

# PHP select record from MySQL table.
curl -o "output" "http://localhost/select-record.php"
cat output
grep "id: 1 - Name: John Doe" ./output
print_info $? php-select-record

# PHP delete record from MySQL table.
curl -o "output" "http://localhost/delete-record.php"
cat output
grep "Record deleted successfully" ./output
print_info $? php-delete-record

# Delete myDB for the next run.
mysql --user='root' --password='root' -e 'DROP DATABASE myDB'
print_info $? delete-database

#停止服务
case "$distro" in
    centos)
	systemctl stop httpd
	systemctl stop mysql
	;;
    debian)
	systemctl stop apache2
	systemctl stop mysql
	;;
esac

case "$distro" in
    debian)
	apt-get remove apache2 --purge -y
	apt-get remove php-fpm --purge -y
	pkgs="mysql-server php-mysql php-common libapache2-mod-php"
	remove_deps "${pkgs}"
	print_info $? remove-package
	;;
    centos)
	remove_deps "${pkgs}"
        print_info $? remove-package
	;;
esac


rm -rf output
