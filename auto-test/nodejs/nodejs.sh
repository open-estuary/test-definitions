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
    print_info $? "install nodejs"
    
    res=`node -v`

    echo $res | grep "v6"
    print_info $? "nodejs version"

}

function nodejs_npm(){

    res=`npm -v`
    echo $res | grep "3.10"
    print_info $? "nodejs npm version"
    
    npm install "express"
    print_info $? "nodejs install package local"
   
    if [ -d ./node_modules/express/  ];then
        true
    else
        false
    fi
    print_info $? "nodejs list local package at current dir"

    npm install "express" -g
    print_info $? "nodejs install package global"
    
    npm list  -g | grep express 
    print_info $? "nodejs list global package at /usr/lib/node_modules/"
    
    
    npm uninstall express
    if [ -d ./node_modules/express  ];then
        false
    else
        true
    fi
    print_info $? "nodejs uninstall local package"

    npm uninstall express -g
    npm list express -g
    if [ $? -eq 1 ];then
        true
    else
        false
    fi
    print_info $? "nodejs uninstall global package"

}

function nodejs_fs_test(){

    npm install 'child_process' -g
    print_info $? "nodejs insatll 'child_process' package"
    node readFile.js
    

}

function nodejs_uninstall(){
    
    yum remove -y nodejs 
    print_info $? "uninstall nodejs"


}
