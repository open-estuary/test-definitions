
#!/bin/sh 
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

case $distro in
    "centos"|"opensuse"|"ubuntu"|"debian" )       
	#yum install -y sysstat
        pkgs="sysstat"
	install_deps "${pkgs}"
        print_info $? install_sysstat
        ;;
    "fedora")
	#dnf install -y sysstat.aarch64
	pkgs="sysstat.aarch64"
	install_deps "${pkgs}"
	print_info $? install_sysstat
	;;
esac

# pidstat，输出系统启动后所有活动进程的CPU统计信息
pidstat
print_info $? all-cpu

# pidstat输出以2秒为采样周期，输出10次cpu使用统计信息
pidstat 2 10
print_info $? cpu-usage

# pidstat将显示各活动进程的cpu使用统计
pidstat -u 1 2
print_info $? cpu

# display memory usage
pidstat -r 1 2
print_info $? memory

# 查看进程IO的统计信息
pidstat -d 1 2 
print_info $? IO

# check pid usage 
pidstat -p 1 1 10
print_info $? pid

# remove package
case $distro in
	"centos"|"opensuse"|"ubuntu"|"debian")
          remove_deps "${pkgs}"
          print_info $? remove_pkgs
	  ;;
        "fedora")
       	  remove_deps "${pkgs}"
	  print_info $? remove_pkgs
	 ;;
esac
