#! /bin/bash

### Header info ###
## template: 	V02
## Author: 	XiaoJun x00467495
## name:	rally
## desc:	rally package install and uninstall

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
		apt-get install -y make openjdk-8-jdk gettext make asciidoc xmlto autoconf gcc wget python3-dev
		apt-get install  -y tk perl cpio zlib1g-dev openssl libreadline-dev bzip2 expat sqlite3 libgdbm-dev
		apt remove git -y
		pr_ok "[compile]<install> ok"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		pr_info "install using yum"		
                yum install java-1.8.0-openjdk make asciidoc xmlto autoconf perl-ExtUtils-Embed gcc curl-devel expat-devel gettext-devel perl-ExtUtils-MakeMaker wget -y
		yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel python36-devel -y
		yum remove git -y
		pr_ok "[compile]<install> ok"
	fi
	pr_tip "[depend] skiped"
	return 0
}

## Interface: download_src
function src_download()
{	
	cd /home
	wget -T 10 -O /home/v2.2.1.tar.gz 192.168.1.107/liubeijie/v2.2.1.tar.gz
	if [ $? -ne 0 ];then
		wget -T 10 -O /home/v2.2.1.tar.gz https://github.com/git/git/archive/v2.2.1.tar.gz
	fi
	tar -zxvf v2.2.1.tar.gz
	wget -T 10 -O /home/Python-3.6.1.tgz 192.168.1.107/liubeijie/Python-3.6.1.tgz
	if [ $? -ne 0 ];then
		wget -T 10 -O /home/Python-3.6.1.tgz https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tgz
	fi
	tar -zxvf Python-3.6.1.tgz
	pr_tip "[download] skiped"
	return 0
}

## Interface: compile_and_install
function compile_and_install()
{
	pr_tip "[install]<version> skiped"
	pr_tip "[install]<rm_git> skiped"
	pr_tip "[install]<compile> skiped"
	
	git --version |grep "2.2.1"
	if [ $? -eq 1 ];then
		cd /home/git-2.2.1/
		make configure
		./configure --prefix=/usr/local/git --with-iconv --with-curl --with-expat=/usr/local/lib
		make
		make install
		echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/bashrc
		source /etc/bashrc
		source ~/.bash_profile
	fi

	pip3 --version|grep "19.1.1"
	if [ $? -eq 1 ];then
		cd /home/Python-3.6.1/
		mkdir -p /usr/local/python3
		./configure --prefix=/usr/local/python3
		make
		make install
		ln -s /usr/local/python3/bin/python3 /usr/bin/python3
		ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
		echo "PATH=$PATH:$HOME/bin:/usr/local/python3/bin" >> /root/.bash_profile
		source /root/.bash_profile
		pip3 install --upgrade pip
	fi
	#wget https://bootstrap.pypa.io/get-pip.py
	#python3 get-pip.py
	ass_rst $? 0 "install failed"
	pr_tip "[install]<install>"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	pr_tip "[selftest] check version"
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
	rm -rf /home/v2.2.1.tar.gz 
	rm -rf /home/git-2.2.1 
	rm -rf /usr/local/python3
	rm -rf /home/Python-3.6.1.tgz 
	rm -rf /home/Python-3.6.1 
	rm -rf /usr/bin/python3
	pr_ok "[compile]<uninstall> ok"
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
