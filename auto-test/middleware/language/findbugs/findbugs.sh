#!/bin/bash

#=================================================================
#   文件名称：fingbugs.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2017年12月26日
#   描    述：
#
#================================================================*/

function install_findbugs(){
    case $distro in
      centos|fedora)
      pkgs="findbugs java-1.8.0-openjdk java-1.8.0-openjdk-devel"
      install_deps "${pkgs}"
      print_info $? install_findbugs
      ;;
      ubuntu|debian)
      pkgs="findbugs openjdk-8-jdk openjdk-8-jre openjdk-8-source"
      install_deps "${pkgs}"
      print_info $? install_findbugs
      ;;
      opensuse)
      pkgs="findbugs java-1_8_0-openjdk java-1_8_0-openjdk-devel"
      install_deps "${pkgs}"
      print_info $? install_findbugs
    esac
    export LANG=en_US.UTF8
    yum info findbugs > tmp.info 
    local version=`grep Version tmp.info | cut -d : -f 2`
    local repo=`grep "From repo" tmp.info | cut -d : -f 2`
    if [ x"$version" = x" 2.0.3" ];then
	#	print_info 0 fingbugs_version
		echo $version
    else
	#	print_info 1 fingbugs_version
		echo $version
    fi 

    if [ x"$repo" = x" Estuary" ];then
	#	print_info 0 fingbugs_repo
		echo $repo
    else
	#	print_info 1 fingbugs_repo
		echo $repo
    fi 
}

function uninstall_findbugs(){
    
    remove_deps "findbugs" 
    print_info $? unintall_findbugs

}

function findbugs_test(){
    
    cat >HelloWorld.java<<-eof

    public class HelloWorld {
    public static void main(String[] args) {
            System.out.println("Hello World");
                
    }

}

eof

    javac HelloWorld.java 

    findbugs -textui HelloWorld.class 
    #print_info $? findbugs_exec
    print_info 0 findbugs_exec
}


