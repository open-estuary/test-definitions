#!/bin/bash

#=================================================================
#   文件名称：nginx.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年02月05日
#   描    述：
#
#================================================================*/

function nginx_install(){

    
    yum install -y nginx 
    print_info $? "install_nginx"

    local ver=`yum info nginx | grep Version | cut -d : -f 2`
    if [ x"$ver" == x"1.13.3" ];then
        true
    else
        false
    fi 
    print_info $? "nginx_version_is_ok"
}

function nginx_remove(){

    systemctl stop nginx 
    yum remove -y nginx 
}


function nginx_start(){
    
    systemctl start nginx 
    print_info  $? "nginx_startd"

}

function nginx_stop(){

    systemctl stop nginx 
    print_info $? "nginx_stopped"
}

function nginx_base_fun(){

    curl localhost:80 | grep "Welcome to nginx"
    print_info $? "nginx_can_normal_access"
    
}


function install_geoip_mod(){

    yum install -y nginx-module-geoip 
    print_info $? "nginx_install_geoip_module"
    yum install -y php-fpm

    systemctl start php-fpm

}

function modify_nginx_conf(){
    
    cp=`which cp --skip-alias`
    $cp -f  nginx.conf /etc/nginx/ && 
    $cp -f default.conf /etc/nginx/conf.d/default.conf 
    print_info $? "modify_nginx_conf_load_geoip_mod"
    systemctl restart nginx 
    print_info $? "restart_nginx_load_geoip_mod"

    $cp -f index.php test.php /var/www 
}

function get_geoip_info(){

    curl localhost/test.php | grep  country_code
    print_info $? "geoip_mod_is_ok"
}

function test_geoip_mod(){

    install_geoip_mod
    modify_nginx_conf
    get_geoip_info
}


