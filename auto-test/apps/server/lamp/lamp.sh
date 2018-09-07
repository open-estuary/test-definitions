#!/bin/bash

set -x

. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib




#usage() {
#    echo "Usage: $0 [-s <true|false>]" 1>&2
#    exit 1
#}

#while getopts "s:" o; do
#  case "$o" in
#    s) SKIP_INSTALL="${OPTARG}" ;;
#    *) usage ;;
#  esac
#done

#! check_root && error_msg "This script must be run as root"

# Install lamp and use systemctl for service management. Tested on Ubuntu 16.04,
# Debian 8, CentOS 7 and Fedora 24. systemctl should available on newer releases
# as well.
#if [ "${SKIP_INSTALL}" = "True" ] || [ "${SKIP_INSTALL}" = "true" ]; then
#    warn_msg "LAMP package installation skipped"
#else
    # Stop nginx server in case it is installed and running.
    systemctl stop nginx > /dev/null 2>&1 || true

    # shellcheck disable=SC2154
    case "${distro}" in
      debian|ubuntu)
        if [ "${distro}" = "debian" ]; then
            pkgs="curl apache2 mysql-server php-mysql php-common libapache2-mod-php"
        elif [ "${distro}" = "ubuntu" ]; then
            echo mysql-server mysql-server/root_password password lxmptest | sudo debconf-set-selections
            echo mysql-server mysql-server/root_password_again password lxmptest | sudo debconf-set-selections
           pkgs="curl apache2 mysql-server php-mysql php-common libapache2-mod-php"
        fi
        install_deps "${pkgs}"
        print_info $? install-pkgs
	case $distro in
	    ubuntu)
            echo "extension=mysqli.so" >> /etc/php/7.2/apache2/php.ini
	    ;;
            debian)
            echo "extension=mysqli.so">> /etc/php/7.0/apache2/php.ini
	    ;;
	 esac
        systemctl start apache2
        systemctl start mysql
        ;;
      centos|fedora)
        yum remove -y `rpm -qa | grep -i mysql`
        yum remove -y `rpm -qa | grep -i alisql`
        yum remove -y `rpm -qa | grep -i percona`
        yum remove -y `rpm -qa | grep -i mariadb`
        #yum install curl -y
        #yum install httpd -y
        #yum install mysql-community-server -y
        #yum install php php-mysql -y
        pkgs="curl httpd mysql-community-server php php-mysql"
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
grep "Test Page for the Apache HTTP Server" ./output
print_info $? apache2-test-page

# Test MySQL.
mysqladmin -u root password lxmptest  > /dev/null 2>&1 || true
mysql --user="root" --password="lxmptest" -e "show databases"
print_info $? mysql-show-databases

# Test PHP.
curl -o "output" "http://localhost/info.php"
grep "PHP Version" ./output
print_info $? phpinfo

# PHP Connect to MySQL.
curl -o "output" "http://localhost/connect-db.php"
grep "Connected successfully" ./output
#exit_on_fail "php-connect-db"
print_info $? php-connect-db

# PHP Create a MySQL Database.
curl -o "output" "http://localhost/create-db.php"
grep "Database created successfully" ./output
print_info $? php-create-db

# PHP Create MySQL table.
curl -o "output" "http://localhost/create-table.php"
grep "Table MyGuests created successfully" ./output
print_info $? php-create-table

# PHP add record to MySQL table.
curl -o "output" "http://localhost/add-record.php"
grep "New record created successfully" ./output
print_info $? php-add-record

# PHP select record from MySQL table.
curl -o "output" "http://localhost/select-record.php"
grep "id: 1 - Name: John Doe" ./output
print_info $? php-select-record

# PHP delete record from MySQL table.
curl -o "output" "http://localhost/delete-record.php"
grep "Record deleted successfully" ./output
print_info $? php-delete-record

# Delete myDB for the next run.
mysql --user='root' --password='lxmptest' -e 'DROP DATABASE myDB'
print_info $? delete-database
remove_deps "${pkgs}"
print_info $? remove-package

rm -rf output
