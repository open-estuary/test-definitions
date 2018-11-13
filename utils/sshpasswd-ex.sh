#!/bin/bash

#================================================================
#   Copyright (C) 2017 r Ltd. All rights reserved.
#   
#   文件名称：sshpasswd-ex.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月20日
#   描    述：
#
#================================================================

set -x

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

   # while read line
   for line in `cat $file`
    do  
        echo $line | grep "^#.*" && continue  
        echo $line | grep "^$" && continue
        host=`echo $line | cut -d : -f 1`
        user=`echo $line | cut -d : -f 2`
        passwd=`echo $line | cut -d : -f 3`
        hostnm=`echo $line | cut -d : -f 4`

        echo "host=$host , user=$user , password=$passwd "
        
        res=`sshpass -p$passwd ssh -n $user@$host "test -f ~/.ssh/id_rsa.pub && echo 7 || echo 8 " `
        if [ $? -eq 0 ];then
            if [ $res -eq 8 ];then
                if [ ! -z $hostnm ];then 
                    hnm=`sshpass -p$passwd ssh -n $user@$host  " hostname"`
                    #echo $hnm ----------------------------------------------
                    if [ $hnm != $hostnm ];then
                        sshpass -p$passwd ssh -n $user@$host "echo   $hostnm > /etc/hostname "
                        sshpass -p$passwd ssh -n $user@$host "hostname $hostnm"
                    fi 
                fi
                sshpass -p$passwd ssh -n $user@$host "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
            else 
                if [ ! -z $hostnm ];then
                    hnm=`sshpass -p$passwd ssh -n $user@$host "hostname"`
                    echo $hnm ----------------------------------------------
                    if [ $hnm != $hostnm ];then
                        sshpass -p$passwd ssh -n $user@$host "hostname $hostnm"
                        sshpass -p$passwd ssh -n $user@$host "echo  $hostnm > /etc/hostname"
                        sshpass -p$passwd ssh -n $user@$host "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
                    fi 
                fi
            fi 
        else 
            echo "sshpass error --$host-$user-$passwd-"
            exit 1
        fi 
        sshpass -p$passwd ssh-copy-id -f  -i ~/.ssh/id_rsa.pub $user@$host 2>&1 >/dev/null 
        if [ $? -ne 0 ];then
            echo "sshpass error"
            exit 1
        fi 
        sshpass -p$passwd ssh -n $user@$host "chmod 0600 ~/.ssh/authorized_keys;echo 'StrictHostKeyChecking NO' > ~/.ssh/config ; chmod 400 ~/.ssh/config"
        if [ $? -ne 0 ];then
            echo "sshpass error"
            exit 1
        fi 
        echo ------------
    done 
    #done < /root/test-definitions/auto-test/bigdata/hostfile
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
    basedir=$(cd `dirname $0`;pwd)
    sshfile="$basedir/sshpasswd-ex.sh"
    echo $sshfile
    #while read line

    echo ------------------------------
    echo ------ssh each other without password
    echo ----------begin----------------------
    for line in `cat $file`
    do
        echo $line | grep "^#.*" && continue
        echo $line | grep "^$" && continue 
        host=`echo $line | cut -d : -f 1`  
        user=`echo $line | cut -d : -f 2`  
        passwd=`echo $line | cut -d : -f 3`
        
        ssh $user@$host "mkdir -p  ~/ssh_tmp"
        scp $file $user@$host:~/ssh_tmp/hostfile 
        scp $sshfile $user@$host:~/ssh_tmp/
       
        ssh $user@$host "~/ssh_tmp/sshpasswd.sh install"
        ssh $user@$host "~/ssh_tmp/sshpasswd-ex.sh oneway ~/ssh_tmp/hostfile"
    done 
    echo ------------end------------------
    echo ---------------------------------
    
}

function usage(){

    echo "usage : $0 [install | oneway | twoway] [hostfile]"
    echo "  install: install sshpass and ssh"
    echo "  oneway: localhost to hostfile host login without password"
    echo "  twoway: hostfile echo one login each other with password"
    echo "  hostfile: format is 'ip:user:password'"
}

if [ $# -eq 0 ];then
    usage $0
    exit 1
fi 

if [ $1 = "install" ];then
    ssh_install
elif [ $1 = "oneway" ];then
    ssh_no_passwd_local_hostfile $2
elif [ $1 = "twoway" ];then
    ssh_no_passwd_each_hostfile $2
elif [ $1 = "all" ];then
    ssh_no_passwd_local_hostfile $2
    ssh_no_passwd_each_hostfile $2
else
    usage $0 
fi 



