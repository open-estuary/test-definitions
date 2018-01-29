#!/bin/bash

set -x

cd ../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

pkgs="curl net-tools vim git expect"
install_deps "${pkgs}"
print_info $? install-tools

case "${distro}" in
    centos)
		pkgs="nginx php php-fpm"
		install_deps "${pkgs}"
		print_info $? install-php

		# Configure PHP.
		cp /etc/php.ini /etc/php.ini.bak
		sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini
		sed -i "s/listen.allowed_clients = 127.0.0.1/listen = \/run\/php-fpm\/php-fpm.sock/" /etc/php-fpm.d/www.conf
		sed -i "s/;listen.owner = nobody/listen.owner = nginx/" /etc/php-fpm.d/www.conf
		sed -i "s/;listen.group = nobody/listen.group = nginx/" /etc/php-fpm.d/www.conf
		sed -i "s/user = apache/user = nginx/" /etc/php-fpm.d/www.conf
		sed -i "s/group = apache/group = nginx/" /etc/php-fpm.d/www.conf
		print_info $? configure-php
		# This creates the needed php-fpm.sock file
		chmod 666 /run/php-fpm/php-fpm.sock
		chown nginx:nginx /run/php-fpm/php-fpm.sock
		systemctl restart php-fpm
		print_info $? start-php-fpm

		# Configure NGINX for PHP.
		cp ../../utils/centos-nginx.conf /etc/nginx/conf.d/default.conf
		print_info $? configure-nginx
		systemctl stop httpd.service > /dev/null 2>&1 || true
		;;
	debian|ubuntu)
	    pkgs="nginx php php-common php7.0-fpm"
        install_deps "${pkgs}"

        # Stop apache server in case it is installed and running.
        systemctl stop apache2 > /dev/null 2>&1 || true

        # Configure PHP.
        cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
		print_info $? configure-php
        systemctl restart php7.0-fpm
		print_info $? start-php-fpm

        # Configure NGINX for PHP.
        mv -f /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
        cp ../../utils/ubuntu-nginx.conf /etc/nginx/sites-available/default
		print_info $? configure-php
        ;;
    *)
        error_msg "Unsupported distribution: ${distro}"
        ;;
esac

systemctl stop nginx
systemctl start nginx
print_info $? start-nginx

sed -i "s/Apache/Nginx/g" ./html/index.html
cp ./html/* /usr/share/nginx/html/

curl -o "output" "http://localhost/index.html"
grep 'Test Page for the Nginx HTTP Server' ./output
print_info $? test-nginx-server

curl -o "output" "http://localhost/php/info.php"
grep 'version' ./output
print_info $? php-info

curl -o "output" "http://localhost/php/array.php"
grep 'I like Volvo, BMW and SAAB' ./output
print_info $? php-array

curl -o "output" "http://localhost/php/datatype.php"
grep 'int' ./output
print_info $? php-data-type

curl -o "output" "http://localhost/php/for.php"
grep 'the data is' ./output
print_info $? php-for

curl -o "output" "http://localhost/php/if.php"
grep 'Have a good day' ./output
print_info $? php-if

curl -o "output" "http://localhost/php/print.php"
grep 'PHP is fun' ./output
print_info $? php-print

curl -o "output" "http://localhost/php/sort.php"
print_info $? php-sort

curl -o "output" "http://localhost/php/time.php"
grep 'the current time is' ./output
print_info $? php-time

php /usr/share/nginx/html/php/writefile.php
print_info $? php-writefile

curl -o "output" "http://localhost/php/constant.php"
grep 'Welcome to hoperun.com' ./output
print_info $? php-contant

curl -o "output" "http://localhost/php/error.php"
grep 'Error:' ./output
print_info $? php-error

curl -o "output" "http://localhost/php/function.php"
grep 'Hello world' ./output
print_info $? php-function

curl -o "output" "http://localhost/php/multiarray.php"
grep 'Row number 3' ./output
print_info $? php-multiarray

php /usr/share/nginx/html/php/readfile.php | grep Bill
print_info $? php-readfile

curl -o "output" "http://localhost/php/string.php"
grep 'iahgnahS' ./output
print_info $? php-string

curl -o "output" "http://localhost/php/variable.php"
grep '11' ./output
print_info $? php-variable

curl -o "output" "http://localhost/php/cookie.php"
grep 'Welcome' ./output
print_info $? php-cookie

curl -o "output" "http://localhost/php/exception.php"
grep 'Message:' ./output
print_info $? php-exception

curl -o "output" "http://localhost/php/global.php"
grep '100' ./output
print_info $? php-global

curl -o "output" "http://localhost/php/operator.php"
grep '164601.66666666666674' ./output
print_info $? php-operator

curl -o "output" "http://localhost/php/session.php"
grep 'Pageviews=1' ./output
print_info $? php-session

curl -o "output" "http://localhost/php/switch.php"
grep 'No number between 1 and 3' ./output
print_info $? php-switch

curl -o "output" "http://localhost/php/while.php"
grep 'this number is:' ./output
print_info $? php-while

case "${distro}" in
    centos)
        systemctl stop php-fpm
		print_info $? stop-php-fpm

        systemctl stop nginx
		print_info $? stop-nginx

		pkgs="nginx php php-fpm"
		remove_deps "${pkgs}"
		print_info $? remove-php
		;;
	debian|ubuntu)
        systemctl stop php7.0-fpm
		print_info $? stop-php-fpm

        systemctl stop nginx
		print_info $? stop-nginx

	    pkgs="nginx php php-common php7.0-fpm"
        remove_deps "${pkgs}"
		print_info $? remove-php
        ;;
esac

rm -f output
rm -f newfile.txt



