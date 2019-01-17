#!/bin/bash
#Author mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -


pkg="curl net-tools expect lsof"
install_deps "${pkg}"

case "$distro" in
    centos)
	#清理环境
        ./test.sh
	yum remove mysql-community-server -y
	yum remove php -y
        yum remove nginx -y
        yum remove php-mysql -y
        yum remove php-fpm -y

	;;
    debian)
	#清理环境
	./test.sh
        apt autoremove -y
	;;
esac

netstat -tlnp|grep 80

#删除80端口占用进程
lsof -i :80|grep -v "PID"|awk '{print "kill -9",$2}'|sh
if [ $? -eq 0 ];then
        echo kill_80_pass
else
        echo kill_80_fail
fi

netstat -tlnp|grep 80


case "$distro" in
    debian)
	#安装包
	
	apt-get install mysql-server -y
	systemctl start mysql
	

	pkgs="php-mysql php-fpm php "
	install_deps "${pkgs}"
	print_info $? install_php_nginx_mysql
	
	systemctl stop apache2 > /dev/null 2>&1 || true
	
	apt install nginx -y
	systemctl start nginx
	
	STATUS=`systemctl status nginx`
        echo $STATUS

	proc=`netstat -tlnp|grep 80|tee proc.log`
	cat proc.log
	
	sed -i "s/Apache/Nginx/g" /var/www/html/index.html
	curl -o "output" "http://localhost/"
	cat output
	egrep 'Nginx|nginx' ./output
	print_info $? test-nginx-server
	
	#修改配置文件
	# Configure PHP.
	cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
	
	# Configure NGINX for PHP.
        #cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
	cp /etc/nginx/nginx.conf /etc/nginx/nginx.confbak
        #cp ../../../../utils/debian-default /etc/nginx/sites-available/default
	cp ../../../../utils/nginx.conf    /etc/nginx/nginx.conf
	
	
	systemctl stop php7.0-fpm
	systemctl start php7.0-fpm
	STATUS=`systemctl status php7.0-fpm`
	echo $STATUS

	systemctl stop nginx
	systemctl start nginx
	STATUS=`systemctl status nginx`
	echo $STATUS
	;;
    centos)
	#安装包
	yum install nginx -y

        pkgs="mysql-community-server php php-mysql php-fpm"
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
        
	systemctl start mysql
     	systemctl stop php-fpm
	systemctl start php-fpm
	pro=`systemctl status php-fpm`
	echo $pro

	systemctl stop nginx
	systemctl start nginx
	pro=`systemctl status nginx`
	echo $pro
	;;
esac

proc=`netstat -tlnp|grep 80|tee proc.log`
cat proc.log

 sed -i "s/Apache/Nginx/g" ./html/index.html
cp ./html/* /usr/share/nginx/html/

curl -o "output" "http://localhost/index.html"
cat output
egrep 'Nginx|nginx' ./output
print_info $? test-nginx-server1

# Test MySQL.
case "${distro}" in
    centos)
	EXPECT=$(which expect)
        $EXPECT << EOF
        set timeout 100
        spawn mysql -u root -p
        expect "password:"
        send "root\r"
        expect ">"
        send "exit\r"
        expect eof
EOF
        if [ $? -eq 1 ];then
              mysqladmin -u root password root
        fi
        print_info $? set-root-pwd
	systemctl restart mysql
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


curl -o "output" "http://localhost/index.html"
cat output
egrep 'Nginx|nginx' ./output
print_info $? test-nginx-server2


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
	pro=`systemctl status php7.0-fpm`
	echo $pro

	systemctl stop nginx
	systemctl stop mysql
	rm -rf /etc/php/7.0/fpm/php.ini
	rm -rf /etc/nginx/sites-available/default
	rm -rf /etc/nginx/nginx.conf
	mv /etc/php/7.0/fpm/php.ini.bak /etc/php/7.0/fpm/php.ini
        mv /etc/nginx/sites-available/default.bak /etc/nginx/sites-available/default
	mv /etc/nginx/nginx.confbak /etc/nginx/nginx.conf
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
	remove_deps "${pkgs}"
	print_info $? remove-package
	;;
    centos)
	./test.sh
	remove_deps "${pkgs}"
	print_info $? remove-package
	;;
esac

