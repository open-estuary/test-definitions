#!/bin/bash

#=================================================================
#   文件名称：leveldb.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/

function install_leveldb(){
  
        pkgs="leveldb  leveldb-devel"
        install_deps "${pkgs}"
        print_info $? install_leveldb

case $distro in
    "centos")     
        yum info leveldb > tmp.info 
        local version=`grep Version tmp.info | cut -d : -f 2`
        local repo=`grep "From repo" tmp.info | cut -d : -f 2`
        if [ $version = "1.20" -a $repo = "Estuary" ];then
               true
        else
           false
        fi 
        print_info $? "leveldb_version_is_right"
         ;;
    "fedora")     
        yum info leveldb > tmp.info 
        local version=`grep Version tmp.info | cut -d : -f 2`
        local repo=`grep "From repo" tmp.info | cut -d : -f 2`
        if [ $version = "1.20" -a $repo = "updates" ];then
               true
        else
           false
        fi 
        #print_info $? "leveldb_version_is_right"
         ;;
#     "opensue")
#        local version=`zypper info libleveldb1|grep Version|awk '{print $3}'` 
#       local repo=`zypper info libleveldb1|grep Repositoryawk '{print $3}'` 
#        if [ $version = "1.18-lp150.1.2" -a $repo = "Estuary" ];then
#               true
#        else
#           false
#       fi 
#        print_info $? "leveldb_version_is_right"
#         ;;
esac
}

function install_plyvel(){

        pkgs="python2-pip  python-devel gcc-c++"
        install_deps "${pkgs}"
#        case $distro in
#           "opensuse")
#              pip install --upgrade pip
#           ;;     
#        esac   
        pip install plyvel
        python -c "import plyvel"
        if [ $? -ne 0 ];then
           print_info 1 "install_plyvel"
           exit 1
        fi
        print_info 0 "install_plyvel"
     
}

function uninstall_leveldb(){
    pkgs="leveldb"  
    remove_deps "${pkgs}"
    print_info $? "uninstall_leveldb"    

    pip uninstall -y plyvel 
    print_info $? "uninstall_plyvel_of_python_package"

}


function leveldb_test(){
    python ./leveldb-test.py 
}
