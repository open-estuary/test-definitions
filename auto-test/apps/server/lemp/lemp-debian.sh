#!/bin/bash
#Author mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
source ./sys_info.sh
source ./sh-test-lib
cd -


pkg="curl net-tools expect lsof"
install_deps "${pkg}"

  
#清理环境
./test.sh
apt autoremove -y
	

netstat -tlnp|grep 80

#删除80端口占用进程
lsof -i :80|grep -v "PID"|awk '{print "kill -9",$2}'|sh
if [ $? -eq 0 ];then
        echo kill_80_pass
else
        echo kill_80_fail
fi

netstat -tlnp|grep 80


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
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
cp ../../../../utils/nginx.conf /etc/nginx/sites-available/default
	
	
systemctl stop php7.0-fpm
systemctl start php7.0-fpm
STATUS=`systemctl status php7.0-fpm`
echo $STATUS

systemctl stop nginx
systemctl start nginx
STATUS=`systemctl status nginx`
echo $STATUS

proc=`netstat -tlnp|grep 80|tee proc.log`
cat proc.log

sed -i "s/Apache/Nginx/g" ./html/index.html
cp ./html/* /usr/share/nginx/html/

curl -o "output" "http://localhost/index.html"
cat output
egrep 'Nginx|nginx' ./output
print_info $? test-nginx-server1

# Test MySQL.
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
send "UPDATE user SET authentication_string=PASSWORD('root') where USER='root';\r"
expect "OK"
send "FLUSH PRIVILEGES;\r"
expect "OK"
send "exit\r"
expect eof
EOF
print_info $? set-root-pwd


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

systemctl stop php7.0-fpm
systemctl stop nginx


################################################ nginx1 #################################################

# Configure NGINX for PHP.
cp ../../../../utils/nginx1.conf /etc/nginx/sites-available/default


systemctl stop php7.0-fpm
systemctl start php7.0-fpm
STATUS=`systemctl status php7.0-fpm`
echo $STATUS

systemctl stop nginx
systemctl start nginx
STATUS=`systemctl status nginx`
echo $STATUS

proc=`netstat -tlnp|grep 80|tee proc.log`
cat proc.log


curl -o "output" "http://localhost/index.html"
sleep 5
cat output
egrep 'Nginx|nginx' ./output
print_info $? test-nginx-server1

# Test MySQL.
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
send "UPDATE user SET authentication_string=PASSWORD('root') where USER='root';\r"
expect "OK"
send "FLUSH PRIVILEGES;\r"
expect "OK"
send "exit\r"
expect eof
EOF
print_info $? set-root-pwd1


mysql --user='root' --password='root' -e 'show databases'
print_info $? mysql-show-databases1

# Test PHP.
curl -o "output" "http://localhost/info.php"
sleep 5
grep 'PHP Version' ./output
print_info $? test-phpinfo1

# PHP Connect to MySQL.
curl -o "output" "http://localhost/connect-db.php"
cat output
sleep 5
grep 'Connected successfully' ./output
print_info $? php-connect-db1

systemctl stop php7.0-fpm
systemctl stop nginx

###################################### nginx2 ###################################

# Configure NGINX for PHP.
cp ../../../../utils/nginx2.conf /etc/nginx/sites-available/default


systemctl stop php7.0-fpm
systemctl start php7.0-fpm
STATUS=`systemctl status php7.0-fpm`
echo $STATUS

systemctl stop nginx
systemctl start nginx
STATUS=`systemctl status nginx`
echo $STATUS

proc=`netstat -tlnp|grep 80|tee proc.log`
cat proc.log


curl -o "output" "http://localhost/index.html"
sleep 5
cat output
egrep 'Nginx|nginx' ./output
print_info $? test-nginx-server2

# Test MySQL.
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
send "UPDATE user SET authentication_string=PASSWORD('root') where USER='root';\r"
expect "OK"
send "FLUSH PRIVILEGES;\r"
expect "OK"
send "exit\r"
expect eof
EOF
print_info $? set-root-pwd2


mysql --user='root' --password='root' -e 'show databases'
print_info $? mysql-show-databases2

# Test PHP.
curl -o "output" "http://localhost/info.php"
sleep 5
grep 'PHP Version' ./output
print_info $? test-phpinfo2

# PHP Connect to MySQL.
curl -o "output" "http://localhost/connect-db.php"
cat output
sleep 5
grep 'Connected successfully' ./output
print_info $? php-connect-db2

systemctl stop php7.0-fpm
systemctl stop nginx

rm -rf /etc/nginx/sites-available/default


#清理环境
./test.sh
remove_deps "${pkgs}"
print_info $? remove-package



