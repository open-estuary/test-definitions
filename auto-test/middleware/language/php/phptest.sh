#!/bin/bash

set -x

cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib

! check_root && error_msg "Please run this script as root."

cd -


##################### Environmental preparation  ##############################
#Installation basic package
pkg="curl net-tools vim git expect lsof"
install_deps "${pkg}"
print_info $? install-tools

case "$distro" in
    centos)
	systemctl stop nginx
	systemctl stop httpd
	systemctl stop php-fpm
	yum remove nginx* -y
	yum remove php* -y
	yum remove httpd -y
	;;
    debian)
	systemctl stop nginx 
	systemctl stop apache2
	systemctl stop php7.0-fpm
	apt-get remove apache2 --purge -y
	apt-get remove nginx* --purge -y
	apt-get remove php* --purge -y
	;;
esac

#删除80端口进程
lsof -i :80|grep -v "PID"|awk '{print "kill -9",$2}'|sh
if [ $? -eq 0 ];then
	echo kill_80_pass
else
	echo kill_80_fail
fi




#Install PHP and nginx packages and modify configuration files
case "${distro}" in
    centos)
	pkgs="nginx php php-fpm"
	install_deps "${pkgs}"
	print_info $? install-php


	# Configure PHP.
	cp /etc/php.ini /etc/php.ini.bak
	#sed -i "s/listen = 127.0.0.1:9000/listen = \/run\/php-fpm\/php-fpm.sock/" /etc/php-fpm.d/www.conf
	#sed -i "s/;listen.owner = nobody/listen.owner = nginx/" /etc/php-fpm.d/www.conf
	#sed -i "s/;listen.group = nobody/listen.group = nginx/" /etc/php-fpm.d/www.conf
	#sed -i "s/user = apache/user = nginx/" /etc/php-fpm.d/www.conf
	#sed -i "s/group = apache/group = nginx/" /etc/php-fpm.d/www.conf
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php.ini
	sed -i "s/doc_root =/doc_root=\/usr\/share\/nginx\/html/" /etc/php.ini
	# Configure NGINX for PHP.
	cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
	cp ../../../../utils/centos-nginx.conf /etc/nginx/conf.d/default.conf
	systemctl stop httpd.service > /dev/null 2>&1 || true
	
	systemctl stop php-fpm
	systemctl start php-fpm
        print_info $? start-php-fpm
	pro=`systemctl status php-fpm`
	echo $pro
	;;
    debian)
	pkgs="nginx* php-fpm php*"
        install_deps "${pkgs}"
	print_info $? install_php
        
	# Stop apache server in case it is installed and running.
        systemctl stop apache2 > /dev/null 2>&1 || true
	
	# Configure PHP.
        cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini

	# Configure NGINX for PHP.
        cp  /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
        cp ../../../../utils/debian-nginx.conf /etc/nginx/sites-available/default
	systemctl stop php7.0-fpm
	systemctl start php7.0-fpm
        print_info $? start-php-fpm
	pro=`systtemctl status php7.0-fpm`
	echo $pro
        ;;
    ubuntu)
	pkgs="nginx php-fpm"
	install_deps "${pkgs}"
        print_info $? install_php_nginx
	
	# Stop apache server in case it is installed and running.
	systemctl stop apache2 > /dev/null 2>&1 || true
	

	 # Configure PHP.
	cp /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini
	# Configure NGINX for PHP.
        cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
        cp ../../../../utils/ubuntu-nginx.conf /etc/nginx/sites-available/default
	

	systemctl start php7.2-fpm
	print_info $? start-php-fpm
        ;;
    fedora)
	pkgs="nginx php php-fpm"
        install_deps "${pkgs}"
        print_info $? install_php_nginx
	
	# Configure PHP.
	sed -i "s/;listen.owner = nobody/listen.owner = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/;listen.group = nobody/listen.group = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/user = apache/user = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/group = apache/group = nginx/" /etc/php-fpm.d/www.conf
	# Configure NGINX for PHP.
	cp /etc/nginx/nginx.conf.default /etc/nginx/nginx.conf.default.bak
	cp ../../../../utils/fedora-nginx.conf /etc/nginx/nginx.conf.default
	systemctl stop httpd.service > /dev/null 2>&1 || true
	
	systemctl start php-fpm
        print_info $? start-php-fpm
	;;

esac

systemctl stop nginx
systemctl start nginx
print_info $? start-nginx
STATUS=`systemctl status nginx`
echo $STATUS

sed -i "s/Apache/Nginx/g" ./html/index.html
cp ./html/* /usr/share/nginx/html/

#################### testing the step ########################################
curl -o "output" "http://localhost/index.html"
egrep 'nginx|Nginx' ./output
print_info $? test-nginx-server

#curl -o "output" "http://localhost/info.php"
#grep 'version' ./output
#print_info $? php-info

curl -o "output" "http://localhost/array.php"
cat output
grep 'I like Volvo, BMW and SAAB' ./output
print_info $? php-array

curl -o "output" "http://localhost/datatype.php"
cat output
grep 'int' ./output
print_info $? php-data-type

curl -o "output" "http://localhost/for.php"
cat output
grep 'the data is' ./output
print_info $? php-for

curl -o "output" "http://localhost/if.php"
cat output
grep 'Have a good' ./output
print_info $? php-if

curl -o "output" "http://localhost/print.php"
cat output
grep 'PHP is fun' ./output
print_info $? php-print

curl -o "output" "http://localhost/time.php"
cat output
grep 'the current time is' ./output
print_info $? php-time

curl -o "output" "http://localhost/constant.php"
cat output
grep 'Welcome to hoperun.com' ./output
print_info $? php-contant

curl -o "output" "http://localhost/error.php"
cat output
grep 'Error:' ./output
print_info $? php-error

curl -o "output" "http://localhost/function.php"
cat output
grep 'Hello world' ./output
print_info $? php-function

curl -o "output" "http://localhost/multiarray.php"
cat output
grep 'Row number 3' ./output
print_info $? php-multiarray

curl -o "output" "http://localhost/string.php"
cat output
grep 'iahgnahS' ./output
print_info $? php-string

curl -o "output" "http://localhost/variable.php"
cat output
grep '11' ./output
print_info $? php-variable

curl -o "output" "http://localhost/cookie.php"
cat output
grep 'Welcome' ./output
print_info $? php-cookie

curl -o "output" "http://localhost/exception.php"
cat output
grep 'Message:' ./output
print_info $? php-exception

curl -o "output" "http://localhost/global.php"
cat output
grep '100' ./output
print_info $? php-global

curl -o "output" "http://localhost/operator.php"
cat output
grep '164601.66666666666674' ./output
print_info $? php-operator

curl -o "output" "http://localhost/session.php"
cat output
grep 'Pageviews=1' ./output
print_info $? php-session

curl -o "output" "http://localhost/switch.php"
cat output
grep 'No number between 1 and 3' ./output
print_info $? php-switch

curl -o "output" "http://localhost/while.php"
cat output
grep 'this number is:' ./output
print_info $? php-while

######################## environment  restore ###########################

case "${distro}" in
    centos|fedora)
        systemctl stop php-fpm
	print_info $? stop-php-fpm

        systemctl stop nginx
	print_info $? stop-nginx

	rm -rf /etc/php.ini
        rm -rf /etc/nginx/conf.d/default.conf
        cp /etc/php.ini.bak /etc/php.ini
        cp /etc/nginx/conf.d/default.conf.bak /etc/nginx/conf.d/default.conf

	pkgs="nginx php php-fpm"
	remove_deps "${pkgs}"
	print_info $? remove-php
		;;
    ubuntu)
	systemctl stop php7.2-fpm
	print_info $? stop-php-fpm

        systemctl stop nginx
	print_info $? stop-nginx

        remove_deps "${pkgs}"
	print_info $? remove-php
    	;;
    debian)
	systemctl stop php7.0-fpm
	print_info $? stop-php-fpm

	systemctl stop nginx
	print_info $? stop-nginx
	
	rm -rf /etc/nginx/sites-available/default
        rm -rf /etc/php/7.0/fpm/php.ini
        cp /etc/nginx/sites-available/default.bak /etc/nginx/sites-available/default
        cp /etc/php/7.0/fpm/php.ini.bak /etc/php/7.0/fpm/php.ini


	apt-get remove nginx --purge -y
	apt-get remove php-fpm --purge -y
	print_info $? remove-php

        ;;
esac

rm -f output
rm -f newfile.txt



