#! /bin/bash

### Header info ###
## template: 	V01
## Author: 	XiaoJun x00467495
## name:	sysbench
## desc:	sysbench package install

### RULE
## 1. update Header info
## 2. use pr_err/pr_tip/pr_ok/pr_info as print API
## 3. use ${ass_rst ret exp log} as result assert code
## 4. implement each Interface Functions if you need

### VARIS ###

# Color Macro Start 
MCOLOR_RED="\033[31m"
MCOLOR_GREEN="\033[32m"
MCOLOR_YELLOW="\033[33m"
MCOLOR_END="\033[0m"
# Color Macro End

SRC_URL="https://github.com/akopytov/sysbench/archive/1.0.2.tar.gz"
PKG_URL=NULL
DISTRIBUTION=NULL
rst=0

## Selfdef Varis
MY_SRC_DIR="sysbench-1.0.2"
MY_SRC_TAR="1.0.2.tar.gz"

### internal API ###

function pr_err()
{
	if [ "$1"x == ""x ] ; then
		echo -e $MCOLOR_RED "Error!" $MCOLOR_END
	else
		echo -e $MCOLOR_RED "$1" $MCOLOR_END
	fi
}

function pr_tip()
{
	if [ "$1"x != ""x ] ; then
		echo -e $MCOLOR_YELLOW "$1" $MCOLOR_END
	fi
}

function pr_ok()
{
	if [ "$1"x != ""x ] ; then
		echo -e $MCOLOR_GREEN "$1" $MCOLOR_END
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
	
	if [ "${DISTRIBUTION}"x == "CentOS"x ] ; then
#		yum install -y mysql-community-libs-compat-8.0.13-1.el7.aarch64.rpm --setopt=skip_missing_names_on_install=False
		if [ ! -f "/etc/yum.repos.d/mysql-community.repo" ] ; then
			cp patch/sysbench/* /etc/yum.repos.d/
			yum clean dbcache
			yum makecache
		fi
		if [ ! -f "/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql" ] ; then
			cp patch/sysbench/RPM-GPG-KEY-mysql /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
		fi

		yum install -y mysql-community-libs-compat libpqxx --setopt=skip_missing_names_on_install=False
		ass_rst $? 0 "yum install failed!"
		
		pr_ok "[depend] OK"
	else
		pr_tip "[depend] skiped"
	fi

	return 0
}

## Interface: download_src
function download_src()
{
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
		apt-get install -y sysbench
		ass_rst $? 0 "sysbench install failed!"
	elif [ "$DISTRIBUTION"x == "CentOS"x ] ; then
		rm -rf sysbench-0.4.12-12.el7.aarch64.rpm
		wget ftp://ftp.icm.edu.pl/vol/rzm3/linux-centos-altarch/7.5.1804/cloud/aarch64/openstack-queens/sysbench-0.4.12-12.el7.aarch64.rpm
		ass_rst $? 0 "wget failed!"

		rpm -i sysbench-0.4.12-12.el7.aarch64.rpm
		ass_rst $? 0 "install sysbench-0.4.12-12.el7.aarch64.rpm failed!"

		rm -rf sysbench-0.4.12-12.el7.aarch64.rpm
	fi

	pr_ok "[install]<install> OK"
	return 0
}

## Interface: software self test
## example: print version number, run any simple example
function selftest()
{
	sysbench --version
	ass_rst $? 0 "selftest sysbench failed!"
	
	pr_ok "[selftest] OK"
	return 0
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

### main code ###
function main()
{
	check_distribution
	ass_rst $? 0 "check_distribution failed!"

	clear_history
	ass_rst $? 0 "clear_history failed!"
	
	install_depend
	ass_rst $? 0 "install_depend failed!"
		
	download_src
	ass_rst $? 0 "download_src failed!"
	
	compile_and_install
	ass_rst $? 0 "compile_and_install failed!"
	
	selftest
	ass_rst $? 0 "selftest failed!"

	finish_install
	ass_rst $? 0 "finish_install failed"
}

pr_tip "-------- software compile and install start --------"
main
rst=$?

ass_rst $rst 0 "[FINAL] Software install,Fail!"

pr_ok " "
pr_ok "Software install OK!"

pr_tip "--------  software compile and install end  --------"
