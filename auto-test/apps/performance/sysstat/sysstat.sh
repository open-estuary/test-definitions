#!/bin/bash
# Copyright (C) 2017-8-29, Linaro Limited.

#####加载外部文件################
cd ../../../../utils
source      ./sys_info.sh
source       ./sh-test-lib
cd -

#############################  Test user id       #########################
! check_root && error_msg "Please run this script as root."

###################  Environmental preparation  ######################
#变量赋初始值
ITERATION="30"
PARTITION=""
VERSION="11.5.5"
SOURCE="Estuary"
#执行函数得到发行版的名字
install() {
    case $distro in
      "centos")
            install_deps "sysstat" 
            print_info $? install-pkgs
            version=$(yum info sysstat | grep "^Version" | awk '{print $3}')
            if [ ${version} = ${VERSION} ];then
                echo "syssta version is ${version}: [PASS]" 
            else
                echo "syssta version is ${version}: [FAIL]" 
            fi
            print_info $? sys-version

            sourc=$(yum info sysstat | grep "^From repo" | awk '{print $4}')
            if [ ${sourc} = ${SOURCE} ];then
                echo "syssta source from ${version}: [PASS]"
            else
                echo "syssta source from ${version}: [FAIL]"
            fi
            print_info $? sys-source
            ;;
          "ubuntu"|"debian"|"opensuse")
            pkgs="sysstat"
            install_deps "${pkgs}"
            print_info $? install-sysstat
            ;;
        "fedora")
           pkgs="sysstat.aarch64"
           install_deps "${pkgs}"
           print_info $? install-sysstat
           ;;
      unknown) warn_msg "Unsupported distro: package install skipped" ;;
    esac
}

#######################  testing the step ##########################
sysstat_test() {
#收集1秒之内的10次动态信息到指定文件
    /usr/lib64/sa/sadc  1 10 sa00
#通过sar工具查看系统状态
    sar -f sa00 
    print_info $? sar-cpu
   
#查看CPU利用率，每秒更新一次，更新5次
    sar -u  1 5 
    print_info $? sar-network

#查看设备的情况
    sar -n DEV 2 5 
    print_info $? sar-io

#查看io设备的情况
    iostat -x 
    print_info $? iostat-test

#获取CPU的信息，2秒运行一次，运行10次
    mpstat 2 10 
    print_info $? mpstat-test
}


install
sysstat_test
#######################  environment  restore ###########################
case $distro in
      "centos")
       remove_deps "sysstat"
       print_info $? remove-sysstat
       ;;
      "ubuntu"|"opensuse"|"fedora"|"debian")
       remove_deps "${pkgs}"
       print_info $? remove-sysstat
       ;;

esac
