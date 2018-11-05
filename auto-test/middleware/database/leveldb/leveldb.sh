#!/bin/bash

#=================================================================
#   文件名称：leveldb.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/

function install_leveldb(){
case $distro in
    "centos")
        pkgs="leveldb  leveldb-devel"
        install_deps "${pkgs}"
        print_info $? install_leveldb     
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
        pkgs="leveldb  leveldb-devel"
        install_deps "${pkgs}"
        print_info $? install_leveldb
        yum info leveldb > tmp.info 
        local version=`grep Version tmp.info | cut -d : -f 2`
        local repo=`grep "From repo" tmp.info | cut -d : -f 2`
        if [ $version = "1.20" -a $repo = "updates" ];then
               true
        else
           false
        fi 
         ;;
     "debian")
      wget https://github.com/google/leveldb/archive/v1.20.tar.gz
      print_info $? leveldb-download
      tar -xzvf v1.20.tar.gz
      cd leveldb-1.20
      make
      cp include/leveldb /usr/include/ -r
      cp out-shared/libleveldb.so.1.20 /usr/lib/
      ln -s /usr/lib/libleveldb.so.1.20 /usr/lib/libleveldb.so.1
      ln -s /usr/lib/libleveldb.so.1.20 /usr/lib/libleveldb.so
      ldconfig
       mkdir /usr/lib/leveldb-1.20
       cp out-static/libleveldb.a /usr/lib/leveldb-1.20
       print_info $? install-leveldb
       ;;
esac
}

function install_plyvel(){
case $distro in
     "fedora"|"centos")
        pkgs="python2-pip  python-devel gcc-c++"
        install_deps "${pkgs}"
        pip install plyvel
        python -c "import plyvel"
        if [ $? -ne 0 ];then
           print_info 1 "install_plyvel"
           exit 1
        fi
        print_info 0 "install_plyvel"
     ;;
    "debian")
      pkgs="python-pip python3-dev gcc g++"
        install_deps "${pkgs}"
        pip install plyvel
        python -c "import plyvel"
        if [ $? -ne 0 ];then
           print_info 1 "install_plyvel"
        fi
        print_info 0 "install_plyvel"
esac
}

function uninstall_leveldb(){
   case $distro in
         "fedora"|"centos")
    pkgs="leveldb"  
    remove_deps "${pkgs}"
    print_info $? "uninstall_leveldb"    

    pip uninstall -y plyvel 
    print_info $? "uninstall_plyvel_of_python_package"
;;
   "debian")
   cd -
   rm -rf v1.20.tar.gz
   rm -rf leveldb-1.20
   print_info $? remove-leveldb
   rm -rf /usr/lib/libleveldb.so.1.20
   rm -rf /usr/lib/leveldb-1.20
   ;;
esac
}


function leveldb_test(){
    python ./leveldb-test.py 
}
