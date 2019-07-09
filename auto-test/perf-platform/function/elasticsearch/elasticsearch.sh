#! /bin/bash

### Header info ###
## template: 	V02
## Author: 	lwx588815
## name:	elasticsearch
## desc:	elasticsearch package install and uninstall

### RULE
## 1. update Header info
## 2. use pr_err/pr_tip/pr_ok/pr_info as print API
## 3. use ${ass_rst ret exp log} as result assert code
## 4. implement each Interface Functions if you need
## 5. $1: option，(‘uninstall’ only)

### VARIS ###

# Color Macro Start 
MCOLOR_RED="\033[31m"
MCOLOR_GREEN="\033[32m"
MCOLOR_YELLOW="\033[33m"
MCOLOR_END="\033[0m"
# Color Macro End

SRC_URL=NULL
PKG_URL=NULL
DISTRIBUTION=NULL
rst=0

## Selfdef Varis
# MY_SRC_DIR
# MY_SRC_TAR

### internal API ###

function pr_err()
{
	if [ "$1"x == ""x ] ; then
		echo -e ${MCOLOR_RED} "Error!" ${MCOLOR_END}
	else
		echo -e ${MCOLOR_RED} "$1" ${MCOLOR_END}
	fi
}

function pr_tip()
{
	if [ "$1"x != ""x ] ; then
		echo -e ${MCOLOR_YELLOW} "$1" ${MCOLOR_END}
	fi
}

function pr_ok()
{
	if [ "$1"x != ""x ] ; then
		echo -e ${MCOLOR_GREEN} "$1" ${MCOLOR_END}
	fi
}

function pr_info()
{
	if [ "$1"x != ""x ] ; then
		echo " $1"
	fi
}

# assert result [  $1: check value; $2: expect value; $3 fail log  ]
function ass_rst() 
{
	if [ "$#"x != "3"x ] ; then
		pr_err "ass_rst param faill, only $#, expected 3"
		return 1
	fi

	if [ "$1"x != "$2"x ] ; then
		pr_err "$3"
		exit 1
	fi

	return 0
}

### Interface Functions ###
## Interface list:
##	check_distribution()
##  if $1=="uninstall"
##      uninstall()
##      exit 0
##	clear_history()
##	install_depend()
##	download_src()
##		download src
##		untar & cd topdir
##	compile_and_install()
##		toggle to the right version
##		remove git info
##		configure & compile
##		install
##	selftest()
##  finish_install()
##		remove files

## Interface: get distribution
function check_distribution()
{
	if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
		DISTRIBUTION='CentOS'
	elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
		DISTRIBUTION='Debian'
	else
		DISTRIBUTION='unknown'
	fi

	pr_tip "Distribution : ${DISTRIBUTION}"

	return 0
}

## Interface: clear history files to prepare for reinstall files
function clear_history()
{
	pr_tip "[clear] skiped"
	return 0
}

## Interface: install dependency
function install_depend()
{
	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
		pr_info "install using apt-get"
                apt --setopt=skip_missing_names_on_install=False install curl wget openjdk-8-jdk -y
		pr_ok "[compile]<install> ok"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		pr_info "install using yum"		
                yum --setopt=skip_missing_names_on_install=False install wget curl java-1.8.0-openjdk -y
		pr_ok "[compile]<install> ok"
	fi
	pr_tip "[depend] skiped"
	return 0
}

## Interface: download_src
function src_download()
{	
	cd /home
	wget -T 10 -O elasticsearch-6.2.3.tar.gz 192.168.1.107/liubeijie/elasticsearch-6.2.3.tar.gz
	if [ $? -ne 0 ];then
		wget  -T 10 -O elasticsearch-6.2.3.tar.gz https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.3.tar.gz
	fi
	tar -zxvf elasticsearch-6.2.3.tar.gz
        cd /home/elasticsearch-6.2.3
	pr_tip "[download] skiped"
	return 0
}

## Interface: compile_and_install
function compile_and_install()
{
	pr_tip "[install]<version> skiped"
	pr_tip "[install]<rm_git> skiped"
	pr_tip "[install]<compile> skiped"
	
	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
		sed -i 's/#network.host: 192.168.0.1/network.host: localhost/g' config/elasticsearch.yml
                sed -i 's/#http.port: 9200/http.port: 9200/g' config/elasticsearch.yml
                cat /etc/security/limits.conf |grep "* soft nofile  65536"
                if [ $? -ne 0 ];then
                        echo "* soft nofile  65536" >> /etc/security/limits.conf
                        echo "* hard nofile  65536" >> /etc/security/limits.conf
                        echo "* soft nproc   65536" >> /etc/security/limits.conf
                        echo "* hard nproc   65536" >> /etc/security/limits.conf
                fi
                cat /etc/sysctl.conf |grep "vm.max_map_count=655360"
                if [ $? -ne 0 ];then
                        echo "vm.max_map_count=655360" >> /etc/sysctl.conf
                        sysctl -p
                fi

        elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
                sed -i 's/#network.host: 192.168.0.1/network.host: localhost/g' config/elasticsearch.yml
                sed -i 's/#http.port: 9200/http.port: 9200/g' config/elasticsearch.yml
                cat /etc/security/limits.conf |grep "* soft nofile  65536"
                if [ $? -ne 0 ];then
                        echo "* soft nofile  65536" >> /etc/security/limits.conf
                        echo "* hard nofile  65536" >> /etc/security/limits.conf
                        echo "* soft nproc   65536" >> /etc/security/limits.conf
                        echo "* hard nproc   65536" >> /etc/security/limits.conf
                fi
                sed -i 's/4096/40960/g' /etc/security/limits.d/20-nproc.conf
                cat /etc/sysctl.conf |grep "vm.max_map_count=655360"
                if [ $? -ne 0 ];then
                        echo "vm.max_map_count=655360" >> /etc/sysctl.conf
                        sysctl -p
                fi

	fi
	ass_rst $? 0 "install failed"
	pr_tip "[install]<install>"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	pr_tip "[selftest] skiped"
    	return $?
}

## Interface: finish install
function finish_install()
{
	pr_tip "[finish]<clean> skiped"
	return 0
}

### Dependence ###

### Compile and Install ###

### selftest ###

### uninstall ###
function uninstall()
{
	if [ "$DISTRIBUTION"x == "Debian"x ] ; then
        	pr_info "remove using apt-get"
		rm -rf /home/elasticsearch-6.2.3
        	rm -rf /home/elasticsearch-6.2.3.tar.gz
        	pr_ok "[compile]<uninstall> ok"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
        	pr_info "remove using yum"
		rm -rf /home/elasticsearch-6.2.3
		rm -rf /home/elasticsearch-6.2.3.tar.gz
        	pr_ok "[compile]<uninstall> ok"
    	fi
    	ass_rst $? 0 "uninstall failed"
    	pr_tip "[uninstall]<uninstall>"
    	return 0
}

### main code ###
function main()
{
	check_distribution
	ass_rst $? 0 "check_distribution failed!"

    	if [ "$1"x == "uninstall"x ]; then
        	uninstall
        	ass_rst $? 0 "uninstall failed!"
        	pr_ok "Software uninstall OK!"
        	exit 0
    	fi

	clear_history
	ass_rst $? 0 "clear_history failed!"
	
	install_depend
	ass_rst $? 0 "install_depend failed!"
		
	src_download
	ass_rst $? 0 "download_src failed!"
	
	compile_and_install
	ass_rst $? 0 "compile_and_install failed!"
	
	selftest
	ass_rst $? 0 "selftest failed!"

	finish_install
	ass_rst $? 0 "finish_install failed"
}

pr_tip "-------- software compile and install start --------"
main $1
rst=$?

ass_rst $rst 0 "[FINAL] Software install,Fail!"

pr_ok " "
pr_ok "Software install OK!"

pr_tip "--------  software compile and install end  --------"
