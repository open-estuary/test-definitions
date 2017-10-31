#!/bin/sh

# shellcheck disable=SC1091
#. ../../lib/sh-test-lib
#Author mahongxin <hongxin_228@163.com>
set -x

cd ../../utils
    . ./sys_info.sh
    . ./sh-test-lib
cd -

#OUTPUT="$(pwd)/output"
#RESULT_FILE="${OUTPUT}/result.txt"
#export RESULT_FILE
#TEST_LIST="test-nginx-server mysql-show-databases test-phpinfo
#           php-connect-db php-create-db php-create-table php-add-record
#           php-select-record php-delete-record"

#! check_root && error_msg "This script must be run as root"
#[ -d "${OUTPUT}" ] && mv "${OUTPUT}" "${OUTPUT}_$(date +%Y%m%d%H%M%S)"
#mkdir -p "${OUTPUT}"

#dist_name
# Install and configure LEMP.
# systemctl available on Debian 8, CentOS 7 and newer releases.
# shellcheck disable=SC2154
case "${distro}" in
    debian|ubuntu)
        if [ "${distro}" = "debian" ]; then
            pkgs="nginx mysql-server php5-mysql php5-fpm curl"
        elif [ "${distro}" = "ubuntu" ]; then
            echo mysql-server mysql-server/root_password password lxmptest | sudo debconf-set-selections
	        echo mysql-server mysql-server/root_password_again password lxmptest | sudo debconf-set-selections
	        pkgs="nginx mysql-server php php-mysql php-common libapache2-mod-php curl php7.0-fpm"
        fi
        install_deps "${pkgs}"

        # Stop apache server in case it is installed and running.
        systemctl stop apache2 > /dev/null 2>&1 || true

        systemctl restart nginx
        systemctl restart mysql

        # Configure PHP.
        cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
        systemctl restart php7.0-fpm

        # Configure NGINX for PHP.
        mv -f /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
        cp ./utils/ubuntu-nginx.conf /etc/nginx/sites-available/default
        systemctl restart nginx
        ;;
    centos)
        # x86_64 nginx package can be installed from epel repo. However, epel
        # project doesn't support ARM arch yet. RPB repo should provide nginx.
        [ "$(uname -m)" = "x86_64" ] && install_deps "epel-release"
        pkgs="nginx mariadb-server mariadb php php-mysql php-fpm curl"
        install_deps "${pkgs}"

        # Stop apache server in case it is installed and running.
        systemctl stop httpd.service > /dev/null 2>&1 || true

        systemctl restart nginx
        systemctl restart mariadb

        # Configure PHP.
        cp /etc/php.ini /etc/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini
        sed -i "s/listen.allowed_clients = 127.0.0.1/listen = \/run\/php-fpm\/php-fpm.sock/" /etc/php-fpm.d/www.conf
        sed -i "s/;listen.owner = nobody/listen.owner = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/;listen.group = nobody/listen.group = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/user = apache/user = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/group = apache/group = nginx/" /etc/php-fpm.d/www.conf
        # This creates the needed php-fpm.sock file
        systemctl restart php-fpm
        chmod 666 /run/php-fpm/php-fpm.sock
        chown nginx:nginx /run/php-fpm/php-fpm.sock
        systemctl restart php-fpm

        # Configure NGINX for PHP.
        cp ../../utils/centos-nginx.conf /etc/nginx/default.d/default.conf
        systemctl restart nginx
        ;;
    *)
        info_msg "Supported distributions: Debian, Ubuntu , CentOS"
        error_msg "Unsupported distribution: ${distro}"
        ;;
esac

# Copy pre-defined html/php files to root directory.
#mv -f /usr/share/nginx/html /usr/share/nginx/html.bak
#mkdir -p /usr/share/nginx/html
sed -i "s/Apache/Nginx/g" ./html/index.html
cp ./html/* /usr/share/nginx/html/
#cp ./html/* /var/www/html
# Test Nginx.
#skip_list="$(echo "${TEST_LIST}" | awk '{ for (i=2; i<=NF; i++) print $i}')"
curl -o "${OUTPUT}/index.html" "http://localhost/index.html"
grep 'Test Page for the Nginx HTTP Server' ${OUTPUT}/index.html
print_info $? test-nginx-server

# Test MySQL.
#skip_list="$(echo "${skip_list}" | awk '{ for (i=2; i<=NF; i++) print $i}')"
mysqladmin -u root password lxmptest > /dev/null 2>&1 || true
mysql --user='root' --password='lxmptest' -e 'show databases'
print_info $? mysql-show-databases

# Test PHP.
#skip_list="$(echo "${skip_list}" | awk '{ for (i=2; i<=NF; i++) print $i}')"
curl -o "${OUTPUT}/phpinfo.html" "http://localhost/info.php"
grep 'PHP Version' ${OUTPUT}/phpinfo.html
print_info $? test-phpinfo

# PHP Connect to MySQL.
#skip_list="$(echo "${skip_list}" | awk '{ for (i=2; i<=NF; i++) print $i}')"
curl -o "${OUTPUT}/connect-db" "http://localhost/connect-db.php"
grep 'Connected successfully' ${OUTPUT}/connect-db
print_info $? php-connect-db

# PHP Create a MySQL Database.
#skip_list="$(echo "${skip_list}" | awk '{ for (i=2; i<=NF; i++) print $i}')"
curl -o "${OUTPUT}/create-db" "http://localhost/create-db.php"
grep 'Database created successfully' ${OUTPUT}/create-db
print_info $? php-create-db

# PHP Create MySQL table.
#skip_list="$(echo "${skip_list}" | awk '{ for (i=2; i<=NF; i++) print $i}')"
curl -o "${OUTPUT}/create-table" "http://localhost/create-table.php"
grep 'Table MyGuests created successfully' ${OUTPUT}/create-table
print_info $? php-create-table

# PHP add record to MySQL table.
#skip_list="$(echo "${skip_list}" | awk '{ for (i=2; i<=NF; i++) print $i}')"
curl -o "${OUTPUT}/add-record" "http://localhost/add-record.php"
grep 'New record created successfully' ${OUTPUT}/add-record
print_info $? php-create-recoard

# PHP select record from MySQL table.
#skip_list="$(echo "${skip_list}" | awk '{ for (i=2; i<=NF; i++) print $i}')"
curl -o "${OUTPUT}/select-record" "http://localhost/select-record.php"
grep 'id: 1 - Name: John Doe' ${OUTPUT}/select-record
print_info $? php-select-record

# PHP delete record from MySQL table.
curl -o "${OUTPUT}/delete-record" "http://localhost/delete-record.php"
grep 'Record deleted successfully' ${OUTPUT}/delete-record
print_info $? php-delete-record

# Cleanup.
# Delete myDB for the next run.
mysql --user='root' --password='lxmptest' -e 'DROP DATABASE myDB'

# Restore from backups.
#rm -rf /usr/share/nginx/html
#mv /usr/share/nginx/html.bak /usr/share/nginx/html
# shellcheck disable=SC2154
case "${distro}" in
    debian|ubuntu)
        mv -f /etc/php/7.0/fpm/php.ini.bak /etc/php/7.0/fpm/php.ini
        mv -f /etc/nginx/sites-available/default.bak /etc/nginx/sites-available/default
        ;;
    centos)
        mv -f /etc/php.ini.bak /etc/php.ini
        rm -f /etc/nginx/default.d/default.conf
        ;;
esac
