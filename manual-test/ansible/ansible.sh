#!/bin/bash

#=================================================================
#   文件名称：ansible.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月03日
#   描    述：
#
#================================================================*/

function install_ansible(){

    yum install -y ansible 
    print_info $? "install ansible"
    
}

function ansible_host_file(){

    local hostfile=$1
    echo "" > ./host.tmp 
    local cnt=0
    for line in `cat $hostfile`
    do
        echo $line | grep "^$" && continue
        echo $line | grep "^#.*" && continue 
        let cnt=$cnt+1
        echo $line | cut -d : -f 1 >> ./host.tmp
    done 
    
    if [ $cnt -eq 0 ];then
        # 本机ip地址
        ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/' > ./host.tmp
        ssh_no_passwd 
        cp -f ./host.tmp /etc/ansible/hosts 
        rm -f ./host.tmp 
    else
        ./../../utils/sshpasswd-ex.sh oneway $hostfile 
        mv -f  /etc/ansible/hosts /etc/ansible/hosts.bak 
        cp -f  ./host.tmp /etc/ansible/hosts 
        rm -f ./host.tmp
    fi



}



function ansible_system_test(){

    ansible all --list-hosts 

    ansible all -m setup | grep -E "FAILED|UNREACHABLE"
    
    if [ $? -ne 0 ];then 
        true
    else
        false
    fi
    print_info $? "ansible setup module success"
    
    ansible all -m ping | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible ping module success"

    ansible all -m selinux -a "state=disabled" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible selinux module close selinux "


    ansible all -m package -a "name=httpd state=latest" | grep -E "FAILED|UNREACHABLE "
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible package module install httpd service"

    ansible all -m service -a "name=httpd state=started" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else

        false
    fi 
    print_info $? "ansible service module start service"

    ansible all -m service -a "name=httpd state=stopped" | grep -E " FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible service module stop service"

    ansible all -m service -a "name=httpd state=restarted" | grep -E "FAILED|UNREACHABLE "
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible service module restarted service"

    ansible all -m service -a "name=httpd state=reloaded" | grep -E " FAILED|UNREACHABLE "
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible service module reloaded service"
    ansible all -m service -a "name=httpd state=stopped"
    
    ansible all -m package -a "name=httpd state=absent" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible package uninstall package"


    ansible all -m service -a "name=sshd enabled=yes" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible service module"

    ansible all -m user -a "name=ansible-test" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible user module create user"

    ansible all -m user -a "name=ansible-test state=absent" | grep -E " FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible user module delete user"

    ansible all -m at -a "command='ls > /dev/null' count=2 units=minutes " | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible at module"


}

function ansible_file_test(){

    ansible all -m file -a "path=/tmp/test_ansible state=directory" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi
    print_info $? "ansible file module create directory"

    ansible all -m file -a "path=/tmp/test_ansible state=absent" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi
    print_info $? "ansible file module delete file"

    ansible all -m tempfile -a "state=directory suffix=temp" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then 
        true
    else
        false
    fi 
    print_info $? "ansible tempfile module create temp directory"

    ansible all -m fetch -a "dest=/tmp/ src=/etc/hosts" | grep -E "FAILED|UNREACHABLE "
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible fetch module "



}

function ansible_command_test(){
    
    ansible all -m command -a "ls" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else 
        false
    fi 
    print_info $? "ansible command module"

    ansible all -m shell -a "ls" | grep -E " FAILED|UNREACHABLE "
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible shell module"



}

function ansible_package_test(){

    ansible all -m package -a "name=wget state=latest" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true 
    else
        false
    fi 
    print_info $? "ansible package module install package"

    ansible all -m package -a "name=python-pip "
    ansible all -m pip -a "name=pexpect" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0  ];then
        true
    else
        false
    fi 

    print_info $? "ansible pip module install python package"
}

function ansible_network_test(){

    ansible all -m get_url -a "url=https://github.com/open-estuary/test-definitions/blob/master/README dest=/tmp/baidu" | grep -E "FAILED|UNREACHABLE"
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible get_url module download file"
}


