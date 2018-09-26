#!/bin/bash

#=================================================================
#   文件名称：nginx.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年02月05日
#   描    述：
#
#================================================================*/

function nginx_install(){
case "${distro}" in
    centos|fedora)
	pkgs="curl nginx php php-fpm"
	install_deps "${pkgs}"
	print_info $? "install_nginx_php"
	;;
    debian|ubuntu)
	pkgs="curl nginx php-fpm"
        install_deps "${pkgs}"
        print_info $? "install_nginx_php"
        ;;
esac
}

function nginx_php_configure(){
case "${distro}" in
    centos)
	# Configure PHP
	cp /etc/php.ini /etc/php.ini.bak
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php.ini
	sed -i "s/doc_root =/doc_root=\/usr\/share\/nginx\/html/" /etc/php.ini
	# Configure NGINX for PHP.
	cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bak
	cp ../../../../utils/centos-nginx.conf /etc/nginx/conf.d/default.conf
	systemctl stop httpd.service > /dev/null 2>&1 || true
	print_info $? nginx_php_configure
	;;
    ubuntu)
	# Configure PHP.
	cp /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini
	# Configure NGINX for PHP.
        cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
	cp ../../../../utils/ubuntu-nginx.conf /etc/nginx/sites-available/default
	systemctl stop apache2 > /dev/null 2>&1 || true	
	print_info $? nginx_php_configure
	;;
    debian)
	# Configure PHP.
        cp /etc/php/7.0/fpm/php.ini /etc/php/7.0/fpm/php.ini.bak
        sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
	# Configure NGINX for PHP.
        cp  /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
	cp ../../../../utils/debian-nginx.conf /etc/nginx/sites-available/default
	systemctl stop apache2 > /dev/null 2>&1 || true
	print_info $? nginx_php_configure
	;;
    fedora)
	# Configure PHP.
	sed -i "s/;listen.owner = nobody/listen.owner = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/;listen.group = nobody/listen.group = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/user = apache/user = nginx/" /etc/php-fpm.d/www.conf
        sed -i "s/group = apache/group = nginx/" /etc/php-fpm.d/www.conf
	# Configure NGINX for PHP.
	cp /etc/nginx/nginx.conf.default /etc/nginx/nginx.conf.default.bak
	cp ../../../../utils/fedora-nginx.conf /etc/nginx/nginx.conf.default
	systemctl stop httpd.service > /dev/null 2>&1 || true
	print_info $? nginx_php_configure
	;;
esac
}
function nginx_remove(){

    remove_deps "${pkgs}"
    print_info $? "remove_nginx_php"
}


function nginx_php_start(){
case "${distro}" in
    centos|fedora)
	systemctl start nginx
        systemctl start php-fpm	
 	print_info  $? "nginx_php_startd"
	;;
    ubuntu)
	systemctl start nginx
        systemctl start php7.2-fpm
        print_info  $? "nginx_php_startd"
	;;
    debian)
	systemctl start nginx
        systemctl start php7.0-fpm
        print_info  $? "nginx_php_startd"
	;;
esac
}

function nginx_php_stop(){
case "${distro}" in
    centos|fedora)
	systemctl stop nginx 
        systemctl stop php-fpm
	print_info $? "nginx_php_stopped"
	;;
    ubuntu)
	systemctl stop nginx
        systemctl stop php7.2-fpm
        print_info $? "nginx_php_stopped"
        ;;
    debian)
	systemctl stop nginx
        systemctl stop php7.0-fpm
        print_info $? "nginx_php_stopped"
        ;;
esac
}

function nginx_base_fun(){

    curl localhost:80 | grep "Welcome to nginx"
    print_info $? "nginx_can_normal_access"
    
}


function install_geoip_mod(){

    #apt install -y nginx-module-geoip 
    #print_info $? "nginx_install_geoip_module"
    apt install -y php-fpm

    systemctl start php7.2-fpm

}

function download_nginx_geo_data(){

    mkdir -p /etc/nginx/geoip
    cd /etc/nginx/geoip

    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
    gunzip GeoIP.dat.gz 

    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz 
    gunzip GeoLiteCity.dat.gz 

}


function modify_nginx_conf(){
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
    cp nginx.config /etc/nginx/

    systemctl restart nginx
    print_info $? "restart_nginx_load_geoip_mod"

    #mkdir -p /var/www
    cp -f index.php test.php /usr/share/nginx/html 
	

    
    #cp=`which cp --skip-alias`
    #$cp -f  nginx.conf /etc/nginx/ && 
    #$cp -f default.conf /etc/nginx/conf.d/default.conf 
    #print_info $? "modify_nginx_conf_load_geoip_mod"
       
    #mkdir -p /var/www 
    #$cp -f index.php test.php /var/www 
}

function get_geoip_info(){

    curl localhost/test.php | grep  country_code
    print_info $? "geoip_mod_is_ok"
}

function test_geoip_mod(){

# 这里可以进一步使用自己的geoip数据，这样局域网也可以测试一下
    install_geoip_mod
    download_nginx_geo_data
    modify_nginx_conf
    get_geoip_info
}

function install_nginx_image_filter_mod(){

    apt install -y nginx-module-image-filter
    print_info $? "install_nginx_image_filter_mod"

}


nginx_install
nginx_php_configure
nginx_php_start

nginx_base_fun

nginx_php_stop
nginx_remove







