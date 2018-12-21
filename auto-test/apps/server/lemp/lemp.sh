#!/bin/bash
#Author mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -


pkg="curl net-tools expect"
install_deps "${pkg}"

case "$distro" in
    centos)
	systemctl stop nginx
	systemctl stop httpd
	;;
    debian)
	systemctl stop mysql
	systemctl stop php7.0-fpm
	systemctl stop nginx 
	systemctl stop apache2
	;;
esac

pro=`netstat -tlnp|grep 80|awk '{print $7}'|cut -d / -f 1|head -1`
process=`ps -ef|grep $pro|awk '{print $2}'`
for p in $process
do
        kill -9 $p
done

case "$distro" in
    debian)
	#清理环境
	./test.sh
	apt-get remove mysql-server --purge -y
	apt-get remove php-fpm --purge -y
	apt-get remove nginx --purge -y
	apt-get remove apache2 --purge -y
	apt-get remove php-mysql -y
	#安装包
	
	apt-get install mysql-server -y
	systemctl start mysql
	
	pkgs="nginx php-mysql php-fpm"
	
	install_deps "${pkgs}"
	print_info $? install_php_nginx_mysql
	
	systemctl stop apache2.service > /dev/null 2>&1 || true
	
	
	systemctl start nginx

	curl -o "output" "http://localhost/"
	cat output
	grep 'Welcome to nginx' ./output
	print_info $? test-nginx-server
	
	#修改配置文件
	# Configure PHP.
	cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
	systemctl start php7.0-fpm

	# Configure NGINX for PHP.
        cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
        cp ../../../../utils/nginx.conf /etc/nginx/sites-available/default
	
	systemctl stop nginx
	systemctl start nginx
	STATUS=`systemctl status nginx`
	echo $STATUS
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

proc=`netstat -tlnp|grep 80|tee proc.log`
cat proc.log

cp ./html/* /usr/share/nginx/html/


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
cat output
sleep 5
grep 'Connected successfully' ./output
print_info $? php-connect-db

# PHP Create a MySQL Database.
curl -o "output" "http://localhost/create-db.php"
sleep 5
cat output
grep 'Database created successfully' ./output
print_info $? php-create-db

# PHP Create MySQL table.
curl -o "output" "http://localhost/create-table.php"
sleep 5
cat output
grep 'Table MyGuests created successfully' ./output
print_info $? php-create-table

# PHP add record to MySQL table.
curl -o "output" "http://localhost/add-record.php"
sleep 5
cat output
grep 'New record created successfully' ./output
print_info $? php-create-recoard

# PHP select record from MySQL table.
curl -o "output" "http://localhost/select-record.php"
sleep 5
cat output
grep 'id: 1 - Name: John Doe' ./output
print_info $? php-select-record

# PHP delete record from MySQL table.
curl -o "output" "http://localhost/delete-record.php"
sleep 5
cat output
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
	rm -rf /etc/php/7.0/fpm/php.ini
	rm -rf /etc/nginx/sites-available/default
	cp /etc/php/7.0/fpm/php.ini.bak /etc/php/7.0/fpm/php.ini
        cp /etc/nginx/sites-available/default.bak /etc/nginx/sites-available/default
        ;;
    centos)
	systemctl stop php-fpm
        systemctl stop nginx
        systemctl stop mysql
        cp /etc/php.ini.bak /etc/php.ini
	rm -rf /etc/nginx/nginx.conf.default
	cp /etc/nginx/nginx.conf.default.bak  /etc/nginx/nginx.conf.default
	;;
esac

#remove packges
case "${distro}" in
    debian)
	./test.sh
	apt-get remove --purge mysql-sever -y
	apt-get remove php-fpm --purge -y
	apt-get remove --purge nginx -y
	remove_deps "${pkgs}"
	print_info $? remove-package
	;;
    centos)
	./test.sh
	remove_deps "${pkgs}"
	print_info $? remove-package
	;;
esac

