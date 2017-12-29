#!/bin/bash

#================================================================
#   Copyright (C) 2017 r Ltd. All rights reserved.
#   
#   文件名称：sshpasswd.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月20日
#   描    述：
#
#================================================================

basedir=$(cd `dirname $0`;pwd)
sshfile="$basedir/sshpasswd.sh"
set -x
function ssh_no_passwd(){
    
    rm -rf ~/.ssh 
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys
    echo "StrictHostChecking=NO" > ~/.ssh/config

}


function ssh_install(){

    yum install -y openssh-server sshpass 
}

function ssh_parse_host_passwd(){

    local file=""
    if [ -z $1 ];then
        file="./host_user_passwd"
    else
        file=$1
    fi 
    echo $file 
    local host="" 
    local user=""
    local passwd=""
    while read line
    do
        echo $line | grep "^#.*" && continue  
        echo $line | grep "^$" && continue
        host=`echo $line | cut -d : -f 1`
        user=`echo $line | cut -d : -f 2`
        passwd=`echo $line | cut -d : -f 3`
        
        echo "host=$host , user=$user , password=$passwd "
        local res=`sshpass -p$passwd ssh $user@$host "if [ -f ~/.ssh/id_rsa.pub ];then echo 0 ;else echo 1;fi"`  
        
        if [ $res -eq 1 ];then
            sshpass -p$passwd ssh $user@$host "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
        fi
        sshpass -p$passwd ssh-copy-id -f -n -i ~/.ssh/id_rsa.pub $user@$host
        sshpass -p$passwd ssh $user@$host "chmod 0600 ~/.ssh/authorized_keys;echo 'StrictHostKeyChecking NO' > ~/.ssh/config ; chmod 400 ~/.ssh/config"
        echo ------------
    #done < $file
    done < /root/test-definitions/auto-test/bigdata/hostfile
}

# 这是本地到hostfile文件中的每一个主机的免密登陆
function ssh_no_passwd_local_hostfile(){

    if [ ! -f ~/.ssh/id_rsa.pub ];then
        ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    fi
    ssh_parse_host_passwd $1 

}

# 这是hostfile文件中主机之间相互免密登陆
function ssh_no_passwd_each_hostfile(){
    
    local file=$1 
    local host=""
    local user=""
    local passwd=""
    while read line
    do
        echo $line | grep "^#.*" && continue
        echo $line | grep "^$" && continue 
        host=`echo $line | cut -d : -f 1`  
        user=`echo $line | cut -d : -f 2`  
        passwd=`echo $line | cut -d : -f 3`
        
        ssh $user@$host "mkdir ssh_tmp"
        scp $file $user@$host:~/ssh_tmp/hostfile 
        scp $sshfile $user@host:/ssh_tmp
       
        ssh $user@$host "~/ssh_tmp/sshpasswd.sh install"
        ssh $user@$host "~/ssh_tmp/sshpasswd.sh oneway ~/ssh_tmp/hostfile"
    done < $file
    
}

function usage(){

    echo "usage : $0 [install | oneway | twoway] [hostfile]"
}

if [ $# -eq 0 ];then
    usage $0
    return 1
fi 

if [ $1 = "install" ];then
    ssh_install
elif [ $1 = "oneway" ];then
    ssh_no_passwd_local_hostfile $2
elif [ $1 = "twoway" ];then
    ssh_no_passwd_each_hostfile $2
else
    usage $0 
fi 



