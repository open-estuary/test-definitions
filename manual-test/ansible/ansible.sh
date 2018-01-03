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

function ansible_system_test(){

    ansible all --list-hosts 

    ansible all -m setup | grep "FAILED"
    
    if [ $? -ne 0 ]
        true
    else
        false
    fi
    print_info "ansible setup module success"
    
    ansible all -m ping | grep FAILED
    if [ $? -ne 0 ]
        true
    else
        false
    fi 
    print_info $? "ansible ping module success"

    ansible all -m selinux -a "state=disabled" | grep FAILED 
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible selinux module close selinux "

    ansible all -m service -a "name=sshd enabled=yes" | grep FAILED
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible service module"

    ansible all -m user -a "name=ansible-test" | grep FAILED
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible user module create user"

    ansible all -m user -a "name=ansible-test state=absent" | grep FAILED 
    if [ $? -ne 0 ];then
        true
    else
        false
    fi 
    print_info $? "ansible user module delete user"



}

function ansible_file_test(){

    ansible all -m file -a "path=/tmp/test_ansible state=directory" | grep FAILED
    if [ $? -ne 0 ];then
        true
    else
        false
    fi
    print_info $? "ansible file module create directory"

    ansible all -m file -a "path=/tmp/test_ansible state=absent" | grep FAILED 
    if [ $? -ne 0 ];then
        true
    else
        false
    fi
    print_info $? "ansible file module delete file"




}
