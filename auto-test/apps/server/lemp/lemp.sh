#!/bin/bash
#Author mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
   source ./sys_info.sh
   source ./sh-test-lib
cd -

pkg="curl"
install_deps "${pkg}"

case "$distro" in
    debian)
	#清理环境
	./test.sh
	apt-get remove --purge mysql-server
	
	#安装包
	apt-get install mysql-server mysql-client -y
	pkgs="nginx php-mysql php-fpm"
	install_deps "${pkgs}"
	print_info $? install_php_nginx_mysql
	
	#修改配置文件
	# Configure PHP.
	cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
	# Configure NGINX for PHP.
        cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
        cp ../../../../utils/debian-nginx.conf /etc/nginx/sites-available/default

	systemctl start php7.0-fpm
	systemctl start nginx
	systemctl start mysql
	;;
    centos)
	#清理环境
	./test.sh
        #yum remove -y `rpm -qa | grep -i mysql`
        #yum remove -y `rpm -qa | grep -i alisql`
        #yum remove -y `rpm -qa | grep -i percona`
        #yum remove -y `rpm -qa | grep -i mariadb`

        pkgs=" nginx mysql-community-server php php-mysql php-fpm"
	install_deps "${pkgs}"
        print_info $? install-pkgs
        systemctl stop httpd.service > /dev/null 2>&1 || true

        # Configure PHP.
        cp /etc/php.ini /etc/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini
        sed -i "s/doc_root =/doc_root=\/usr\/share\/nginx\/html/" /etc/php.ini
        # Configure NGINX for PHP.
	cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
        cp ../../../../utils/centos-nginx.conf /etc/nginx/conf.d/default.conf
        
	systemctl start php-fpm
	systemctl start nginx
	systemctl start mysql
     	;;
esac

sed -i "s/Apache/Nginx/g" ./html/index.html
cp ./html/* /usr/share/nginx/html/

curl -o "output" "http://localhost/index.html"
grep 'Test Page for the Nginx HTTP Server' ./output
print_info $? test-nginx-server

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


mysql --user='root' --password='root' -e 'show databases'
print_info $? mysql-show-databases

# Test PHP.
curl -o "output" "http://localhost/info.php"
sleep 5
grep 'PHP Version' ./output
print_info $? test-phpinfo

# PHP Connect to MySQL.
curl -o "output" "http://localhost/connect-db.php"
sleep 5
grep 'Connected successfully' ./output
print_info $? php-connect-db

# PHP Create a MySQL Database.
curl -o "output" "http://localhost/create-db.php"
sleep 5
grep 'Database created successfully' ./output
print_info $? php-create-db

# PHP Create MySQL table.
curl -o "output" "http://localhost/create-table.php"
sleep 5
grep 'Table MyGuests created successfully' ./output
print_info $? php-create-table

# PHP add record to MySQL table.
curl -o "output" "http://localhost/add-record.php"
sleep 5
grep 'New record created successfully' ./output
print_info $? php-create-recoard

# PHP select record from MySQL table.
curl -o "output" "http://localhost/select-record.php"
sleep 5
grep 'id: 1 - Name: John Doe' ./output
print_info $? php-select-record

# PHP delete record from MySQL table.
curl -o "output" "http://localhost/delete-record.php"
sleep 5
grep 'Record deleted successfully' ./output
print_info $? php-delete-record

# Cleanup.
# Delete myDB for the next run.

mysql --user='root' --password='root' -e 'DROP DATABASE myDB'
print_info $? delete-myDB


#stop php,mysql and nginx service
case "${distro}" in
    debian)
	systemctl stop php7.0-fpm
	systemctl stop nginx
	systemctl stop mysql
	cp /etc/php/7.0/fpm/php.ini.bak /etc/php/7.0/fpm/php.ini
        cp /etc/nginx/sites-available/default.bak /etc/nginx/sites-available/default
        ;;
    centos)
	systemctl stop php-fpm
        systemctl stop nginx
        systemctl stop mysql
        cp /etc/php.ini.bak /etc/php.ini
	cp /etc/nginx/nginx.conf.default.bak  /etc/nginx/nginx.conf.default
	;;
esac


#remove packges
case "${distro}" in
    debian)
	./test.sh
	apt-get remove --purge mysql-sever -y
	remove_deps "${pkgs}"
	print_info $? remove-package
	;;
    centos)
	./test.sh
	remove_deps "${pkgs}"
	print_info $? remove-package
	;;
esac

