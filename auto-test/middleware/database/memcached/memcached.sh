#! /bin/bash


basedir=$(cd `dirname $0`;pwd)
cd $basedir
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh
dist=`dist_name`
echo $dist

#set -x 
#export PS4='+{$LINENO:${FUNCTION[0]}} '
outDebugInfo



function memcached_install(){
case $distro in
    "centos"|"fedora")
	pkgs="memcached libevent python2-pip nmap-ncat"
	install_deps "${pkgs}"
        pip install -q python-memcached
	print_info $? install_pkgs	
        ;;
    "ubuntu"|"debian")
	pkgs="memcached libevent-dev"
        install_deps "${pkgs}"
        print_info $? install_pkgs
	;;
    "opensuse")
	pkgs="memcached libevent-2_1-8"
	install_deps "${pkgs}"
        print_info $? install_pkgs
        ;;

esac

}

function memcached_start_by_command(){
    user=`cat /etc/passwd|grep "memtest"|awk -F ':' '{print $1}'`
    if [ "$user"x != "memtest"x ];then
	useradd memtest    
    fi
	memcached -d -p 11211 -m 64m -u memtest 
    	ps -ef |grep "memcached -d -p" | grep -v grep
    	print_info $? "memcached_start"
        
}

function memcached_start_by_service(){

    systemctl start memcached.service 
    systemctl status memcached.service | grep "running"
    print_info $? memcached_start_by_service
}


function memcached_conn(){
case $distro in
    "centos"|"fedora")
	echo "stats" | nc localhost 11211|grep "pid"
	print_info $? memcached_conn
	;;
    "ubuntu"|"debian")
	EXPECT=$(which expect)
	$EXPECT << EOF
	set timeout 100
	spawn telnet localhost 11211
	expect "'^]'"
	send "set foo 0 0 3\r"
	send "bar\r"
	expect "STORED"
	send "quit\r"
	expect eof
EOF
	print_info $? memcached_conn
	;;
esac
}

function memcached_exec(){
    echo "-------begin memcache innter function------"
    echo 
    python ./mc.py
    echo 
    echo "-------stop memcached innter function------"
    print_info $? memcached_exec
}

function memcached_stop_by_service(){
   systemctl stop memcached.service 
   systemctl status memcached.service | grep "dead"
   print_info $? memcached_stop_by_service
        

}

function memcached_stop_by_command(){
    
    pid=`ps -ef | grep 'memcached' | grep -v grep | awk {'print $2'}`
    if [ $? -eq 0 ];then
        kill -9 $pid
    fi 
    ps -ef | grep 'memcached' | grep -v grep 
    if [ $? -eq 0 ];then
        print_info 1 memcached_stop_by_command
    else
        print_info 0 memcached_stop_by_command
    fi
    
}



function memcached_uninstall(){
    remove_deps "${pkgs}"
    print_info $? "memcached_uninstall"
}

memcached_install
memcached_start_by_service
memcached_conn
memcached_exec
memcached_stop_by_service

memcached_start_by_command
memcached_stop_by_command 

memcached_uninstall
