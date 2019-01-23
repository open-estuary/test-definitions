#!/bin/bash


function install_mongodb() {
    case $distro in
    ubuntu|debian)
    
    netstat -tlnp|grep 27017
    #删除27017端口占用进程
    apt install lsof -y
    lsof -i :27017|grep -v "PID"|awk '{print "kill -9",$2}'|sh

    if [ $? -eq 0 ];then
        echo kill_27017_pass
    else
	echo kill_27017_fail
    fi

    netstat -tlnp|grep 27017


    pkgs="mongodb mongodb-server"
    install_deps "${pkgs}"
    print_info $? "mongodb_install_client"
    ;;
   esac

}




function mongodb_start_by_service(){

    systemctl start mongodb
    local cmddir=`which mongod`
    ps -ef | grep $cmddir | grep -v grep 
    if [ $? -eq 0 ];then
    	print_info 0 mongodb_start_by_service
    else
	print_info 1 mongodb_start_by_service
    fi

}




function mongodb_stop_by_service(){
    
    systemctl stop mongodb
    local cmddir=`which mongod`
    ps -ef | grep $cmddir | grep -v grep 
    if [ $? -eq 0 ];then
        print_info 1 mongodb_stop_by_service
    else
        print_info 0 mongodb_stop_by_service

    fi 
}



function mongodb_client(){
    
    if [ -d /data/db ];then
	rm -rf /data/db
    fi

    mkdir -p /data/db
    
    mongod &  
    mongo test.js 
    print_info $? mongodb_client_exec_js_file
    
}

function mongodb_shutdown(){
       
    mongo <<-EOF 
    use admin;
    db.shutdownServer();
EOF
    local cmddir=`which mongod`   
    ps -ef | grep '$cmddir'|grep -v grep
    if [ $? -eq 0  ];then
        print_info 1 mongodb_shutdown
    else
	print_info 0 mongodb_shutdown
    fi 
}


function mongodb_uninstall() {
    remove_deps "${pkgs}" 
    print_info $? 'mongdb_uninstall'
    rm -rf /data/db

}

