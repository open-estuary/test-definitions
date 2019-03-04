#!/bin/bash
set -x

#*****************************************************************************************
# *用例编号： New_Linux-KVM-021 
# *用例功能：单台虚拟机内存压力测试                      
# *作者：dwx588814                            
# *完成时间：                        
# *前置条件：
#    配置启动一台8U16G的虚拟机
# *测试步骤:
#    1)在虚拟机中，通过"cat /proc/meminfo"查看内存信息
#    2)在虚拟机中，根据空闲的内存大小，利用工具"memtester"对内存做加压测试
# *测试结果
#*****************************************************************************************

#加载公共函数
. ../../../../utils/test_case_common.inc
. ../../../../utils/error_code.inc
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib		

#获取脚本名称作为测试用例名称
test_name=$(basename $0 | sed -e 's/\.sh//')
#创建log目录
TMPDIR=./logs/temp
mkdir -p ${TMPDIR}
#存放脚本处理中间状态/值等
TMPFILE=${TMPDIR}/${test_name}.tmp
#存放每个测试步骤的执行结果
RESULT_FILE=${TMPDIR}/${test_name}.result
test_result="pass"

#预置条件
function init_env()
{

#检查结果文件是否存在，创建结果文件：
fn_checkResultFile ${RESULT_FILE}

#root用户执行
if [ `whoami` != 'root' ]
then
    PRINT_LOG "WARN" " You must be root user " 
    return 1
fi


#设置全局变量
path=`pwd`
random_uuid=`cat /proc/sys/kernel/random/uuid`
random_mac=`cat /dev/urandom | head -n 10 | md5sum | head -c 2`

#安装依赖包
pkg_depend="expect wget"
install_deps "${pkg_depend}"


#安装kvm所需的软件包
case "${distro}" in
	centos)
	cd ~
	pkgs="virt-install libvirt* python2-pip"
	install_deps "${pkgs}"
	if [ $? -eq 0 ];then
	    PRINT_LOG "INFO" "Libvirt was installed successfully"
        fn_writeResultFile "${RESULT_FILE}" "libvirt_install" "pass"
        return 0 
    else
	    PRINT_LOG "FATAL" "Libvirt installation failed"
        fn_writeResultFile "${RESULT_FILE}" "libvirt_install" "fail"
        return 1
    fi
	
    pip install --ignore-installed --force-reinstall 'requests==2.6.0' urllib3
	cd -
	#下载loder文件
	if [ ! -d /usr/share/AAVMF ];then
		
	mkdir -p /usr/share/AAVMF
	cd /usr/share/AAVMF
	wget ${ci_http_addr}/test_dependents/AAVMF_CODE.fd
	wget ${ci_http_addr}/test_dependents/AAVMF_VARS.fd
	wget ${ci_http_addr}/test_dependents/AAVMF_CODE.verbose.fd
	cd -

	fi
	;;
esac



#初始化libvirtd

#Add root to users and groups
sed -i "s/#user = /user = /g" /etc/libvirt/qemu.conf
sed -i "s/#group = /group = /g" /etc/libvirt/qemu.conf
	
#启动libvirt服务
systemctl start libvirtd 
	
#测试libvirt服务是否启动
res=`virsh -c qemu:///system list|grep "Id"|awk '{print $1}'`
if [ "$res"x == "Id"x ];then
	PRINT_LOG "INFO" "Libvirt started successfully"
    fn_writeResultFile "${RESULT_FILE}" "libvirt_start" "pass"
    return 0 
else
	PRINT_LOG "FATAL" "Libvirt failed to start"
    fn_writeResultFile "${RESULT_FILE}" "libvirt_start" "fail"
    return 1
fi




#修改xml配置文件(创建一台8U16G的虚拟机)

case "${distro}" in
	centos)
	cd /var/lib/libvirt/qemu/nvram
	if [ ! -f "centos_VARS.fd" ];then
		wget ${ci_http_addr}/test_dependents/centos_VARS.fd
	fi
	cd -
	if [ ! -f "centos.img" ];then
		wget ${ci_http_addr}/test_dependents/centos.img
	fi
	cp centos_libvirt_demo1.xml kvm.xml
	#sed -i "s%<name>kvm</name>%<name>kvm5</name>%g" kvm.xml
	sed -i "s%<uuid>e06d5011-2de4-48a0-834e-72eecf7c99f0</uuid>%<uuid>${random_uuid}</uuid>%g" kvm.xml
	sed -i "s%<source file='/home/dingyu/centos.img'/>%<source file='${path}/centos.img'/>%g" kvm.xml
	sed -i "s%<mac address='52:54:00:85:f0:1c'/>%<mac address='52:54:00:85:f0:${random_mac}'/>%g" kvm.xml
	;;
esac

}


#测试执行
function test_case()
{

#创建虚拟机
virsh define kvm.xml
if [ $? -eq 0 ];then
	PRINT_LOG "INFO" "The virtual machine was created successfully"
    fn_writeResultFile "${RESULT_FILE}" "kvm_define" "pass"
    return 0 
else
	PRINT_LOG "FATAL" "The virtual machine creation failed"
    fn_writeResultFile "${RESULT_FILE}" "kvm_define" "fail"
    return 1
fi

#启动虚拟机
virsh start kvm
if [ $? -eq 0 ];then
	PRINT_LOG "INFO" "The virtual machine started successfully"
    fn_writeResultFile "${RESULT_FILE}" "kvm_start" "pass"
    return 0 
else
	PRINT_LOG "FATAL" "Virtual machine startup failed"
    fn_writeResultFile "${RESULT_FILE}" "kvm_start" "fail"
    return 1
fi

#连接虚拟机
EXPECT=$(which expect)	
$EXPECT <<EOF
set timeout 100
spawn virsh console kvm 
expect {
" is ^]" {send "\03";exp_continue} 
"login:" {send "root\r";exp_continue}
"assword:" {send "root\r"}
}

expect "]#" 
send "ip a\r"
expect eof
EOF
	
if [ $? -eq 0 ];then
	PRINT_LOG "INFO" "The virtual machine connected successfully"
    fn_writeResultFile "${RESULT_FILE}" "kvm_connect" "pass"
    return 0 
else
	PRINT_LOG "FATAL" "Virtual machine connection failed"
    fn_writeResultFile "${RESULT_FILE}" "kvm_connect" "fail"
    return 1
fi

}


#恢复环境
function clean_env()
{

#清除临时文件
FUNC_CLEAN_TMP_FILE

#停止虚拟机
virsh destroy kvm

#删除虚拟机
virsh undefine --nvram kvm

#停止libvirt服务
systemctl stop libvirtd


}



function main()
{
    init_env || test_result="fail"
    if [ ${test_result} = 'pass' ]
    then
        test_case || test_result="fail"
    fi
    clean_env || test_result="fail"
	[ "${test_result}" = "pass" ] || return 1
}

main $@
ret=$?
#LAVA平台上报结果接口，勿修改
lava-test-case "$test_name" --result ${test_result}
exit ${ret}








