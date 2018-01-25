#!/bin/bash

#=================================================================
#   文件名称：bigdata.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月28日
#   描    述：
#
#================================================================*/

function install_bigdata(){

    yum install -y bigdata 
    print_info $? "install bigdata"
    
    export LANG=en_US.UTF8
    yum info bigdata > tmp.info 
    local version=`grep Version tmp.info | cut -d : -f 2`
    local repo=`grep "From repo" tmp.info | cut -d : -f 2`
    if [ $version = "1.0" -a $repo = "Estaury" ];then
        true
    else
        false
    fi 
    print_info $? "bigdata version is right"
}


