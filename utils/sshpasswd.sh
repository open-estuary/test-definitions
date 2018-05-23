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

#set -x
function ssh_no_passwd(){
    
    if [ ! -f ~/.ssh/id_rsa.pub ];then
        ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
    fi
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys
    echo "StrictHostKeyChecking NO" >> ~/.ssh/config

}


