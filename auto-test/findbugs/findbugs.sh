#!/bin/bash

#=================================================================
#   文件名称：fingbugs.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/

function install_findbugs(){

    yum install -y findbugs java-1.8.0-openjdk
    print_info $? "install fingbugs"

    export LANG=en_US.UTF8
    yum info findbugs > tmp.info 
    local version=`grep Version tmp.info | cut -d : -f 2`
    local repo=`grep "From repo" tmp.info | cut -d : -f 2`
    if [ $version = "2.0.3" -a $repo = "Estuary" ];then
        true
    else
        false
    fi 
    print_info $? "fingbugs version is right"

}

function uninstall_findbugs(){
    
    yum remove -y findbugs 
    print_info $? "unintall findbugs"

}

function findbugs_test(){
    
    cat >HelloWorld.java<<-eof

    public class HelloWorld {
    public static void main(String[] args) {
            System.out.println("Hello World");
                
    }

}

eof

    javac HelloWorld.java 

    findbugs -textui HelloWorld.class 
    print_info $? "findbugs command exec"
    
}


