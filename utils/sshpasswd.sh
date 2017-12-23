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

function ssh_no_passwd(){
    
    rm -rf ~/.vim 
    ssh-keygen -t rsa -P '' -f ~/.vim/id_rsa
    cat ~/.vim/id_rsa.pub > ~/.vim/authorized_keys
    chmod 0600 ~/.vim/authorized_keys
    echo "StrictHostChecking=NO" > ~/.vim/config

}
