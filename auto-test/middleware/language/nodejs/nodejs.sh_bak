#!/bin/bash

#=================================================================
#   文件名称：nodejs.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年11月28日
#   描    述：
#
#================================================================*/

function nodejs_install(){
    
    yum install -y nodejs 
    print_info $? "install_nodejs"
    
    res=`node -v`

    echo $res | grep "v6"
    print_info $? "nodejs_version"

}

function nodejs_npm(){

    res=`npm -v`
    echo $res | grep "3.10"
    print_info $? "nodejs_npm_version"
    
    npm install "express"
    print_info $? "nodejs_install_package_local"
   
    if [ -d ./node_modules/express/  ];then
        true
    else
        false
    fi
    print_info $? "nodejs_list_local_package_at_current_dir"

    npm install "express" -g
    print_info $? "nodejs_install_package_global"
    
    npm list  -g | grep express 
    print_info $? "nodejs_list_global_package_at_/usr/lib/node_modules/"
    
    
    npm uninstall express
    if [ -d ./node_modules/express  ];then
        false
    else
        true
    fi
    print_info $? "nodejs_uninstall_local_package"

    npm uninstall express -g
    npm list express -g
    if [ $? -eq 1 ];then
        true
    else
        false
    fi
    print_info $? "nodejs_uninstall_global_package"

}

function nodejs_fs_test(){

    npm install 'child_process' -g
    print_info $? "nodejs_insatll_'child_process'_package"
    node readFile.js
    

}

function nodejs_uninstall(){
    
    yum remove -y nodejs 
    print_info $? "uninstall_nodejs"


}
