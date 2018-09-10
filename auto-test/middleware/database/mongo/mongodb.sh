#!/bin/bash


function install_mongodb() {
    case $distro in
    centos|fedora)
    pkgs="mongodb mongodb-server"
    install_deps "${pkgs}"
    print_info $? "mongodb_install_mongodb_client"
    ;;
    ubuntu|debian)
    pkgs="mongodb mongodb-server"
    install_deps "${pkgs}"
    print_info $? "mongodb_install_client"
    ;;
   esac
    #version=`mongo -version | grep "shell version" | awk {'print $4'}`
    #echo  $version | grep "v3.4.3"
    #print_info $? "mongodb_client_version"

    #version=`mongod -version | grep "db version | awk {'print $3'}"`
    #echo $version | grep "v3.4.3"
    #print_info $? "mongodb_server_version"

}


function isServerRunning(){
    
    ps -ef | grep "mongod --fork"| grep -v grep
    if [ $? -eq 0 ];then
        print_info 0 "mongodb_server_is_running"
    else
        install_mongodb
        mongodb_start 
    fi

}



function mongodb_start(){
    ## --frok 是可以在后台运行
    ## --dbpath 是mongodb数据存放地方
    ## --rest 是可以web访问的参数 端口是 27017 + 1000
    mon=`ps -ef |grep "mongod --fork" | grep -v grep`
    if [ $? -eq 0 ];then
        mongod --shutdown --dbpath /mongodb/db/ 
        print_info $? "mongodb_shutdown_server"
    fi
    if [ -d /mongodb/db  ];then
        rm -rf /mongodb/db 
    fi
    if [ -d /mongodb/log  ];then
        rm -rf /mongdb/log
    fi
    mkdir -p /mongodb/db 
    mkdir -p /mongodb/log
    mongod --fork --dbpath /mongodb/db --logpath /mongodb/log/mongodb.log --logappend 
    print_info $? "mongodb_start_server"
    sleep 10

}

function mongodb_stop_by_service(){
    
    systemctl stop mongod.service 
    local cmddir=`which mongod`
    ps -ef | grep $cmddir | grep -v grep 
    if [ $? -eq 0 ];then
        false
    else
        true

    fi 
    print_info $? "mongod_service_stop_by_service"
}

function mongodb_start_by_service(){
    systemctl start mongod
    local cmddir=`which mongod`
    ps -ef | grep $cmddir | grep -v grep 
    if [ $? -eq 0 ];then
        true
    else
        false
    fi 
    #print_info $? "mongod_service_start_by_service"
}


function mongodb_client(){
    mongo test.js 
    print_info $? "mongodb_client_exec_js_file"
}

function mongodb_shutdown(){
    ps -ef | grep 'mongod --fork'    
    if [ $?  ] ;then 
    mongo <<-EOF 
    use admin;
    db.shutdownServer();
EOF
    fi
    ps -ef | grep 'mongod --fork'
    if [ $? -ne 0  ];then
        print_info $? 'mongodb_shutdown'
    fi 
}


function mongodb_uninstall() {
    remove_deps "${pkgs}" 
    print_info $? 'mongdb_uninstall'
    rm -rf /mongodb

}

