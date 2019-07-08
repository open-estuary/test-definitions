#!/bin/bash

############################################################################
#用例名称：qemu-kvm
#用例功能：
#	版本检查：2.12.0
#	虚拟机操作：部署、删除、规格调整、迁移、启动、克隆、重启、关机、暂停
#	虚拟机时间准确性测试
#	虚拟机磁盘访问测试
#	虚拟机压力测试

#作者：zwx644970
#完成时间：2019/5/
#版本号  ： V0.1
##############################################################################

################################初始化变量################################
INSTALL_DIR=./ # 指定安装脚本所在目录
INSTALL_SCRIPT=qemu.sh # 指定安装脚本
PY_JSON_TRANSFOR=../../../../utils/result_transfor_json.py # 将测试结果转为json的python脚本

################################导入公共函数################################
PUBLIC_UTILS_DIR=../../../../utils
. ${PUBLIC_UTILS_DIR}/sys_info.sh
. ${PUBLIC_UTILS_DIR}/sh-test-lib
. ${PUBLIC_UTILS_DIR}/test_case_common.inc
. ${PUBLIC_UTILS_DIR}/test_case_public.sh
################################获取脚本名称作为测试用例名称################################
test_name=$(basename $0 | sed -e 's/\.sh//')

################################@创建log目录################################
TMPDIR=./logs
mkdir -p ${TMPDIR}

#设置全局变量
#path=`pwd`
random_uuid=`cat /proc/sys/kernel/random/uuid`
random_mac=`cat /dev/urandom | head -n 10 | md5sum | head -c 2`
CUR_PATH=`pwd`
vmachine=(centos centos1 centos2)
length=${#vmachine[@]}

################################存放脚本处理中间状态/值等################################
#!!!!!!!!可否不使用中间状态文件,直接用字符串存储中间数据!!!!!!!!!!!
#TMPFILE=${TMPDIR}/${test_name}.tmp

################################存放每个测试步骤的执行结果################################
RESULT_FILE=${TMPDIR}/${test_name}_rst.log

################################初始化环境包含（安装所需要的包）################################
function init_env()
{ 
    ###@开启日志入库时间### 
    #
	#get_starttime
	###@安装依赖包###
	pkg_depend="expect wget sshpass"
	install_deps "${pkg_depend}"
	###@调用安装脚本###
	bash ${INSTALL_DIR}${INSTALL_SCRIPT}
	
    ###@检查结果文件是否存在，创建结果文件###
    check_resultfile ${RESULT_FILE}
	echo "OS=`cat /etc/os-release |grep ^NAME |awk -F "=" '{print $2}'`    version=`dmidecode --type processor | grep Version |awk -F ":" '{print $2}'|head -1 |awk '{sub("^ *","");sub(" *$","");print}'`" > ${RESULT_FILE}
}

################################测试函数实现区域################################
###@test1###
function qemu_create()
{	
	if [ ! -d /usr/share/AAVMF ];then
		mkdir -p /usr/share/AAVMF
		cd /usr/share/AAVMF
		wget http://114.119.4.74:18083/test_dependents/AAVMF_CODE.fd    #下载内部仓库文件
		wget http://114.119.4.74:18083/test_dependents/AAVMF_VARS.fd
		wget http://114.119.4.74:18083/test_dependents/AAVMF_CODE.verbose.fd
		cd -
	fi
	
	sed -i "s/#user = /user = /g" /etc/libvirt/qemu.conf
	sed -i "s/#group = /group = /g" /etc/libvirt/qemu.conf
	systemctl start libvirtd 	
case "${distro}" in
	centos)
	cd /var/lib/libvirt/qemu/nvram
	if [ ! -f "centos_VARS.fd" ];then
		wget http://114.119.4.74:18083/test_dependents/centos_VARS.fd
	fi
	cd -
	if [ ! -f "centos.img" ];then
		wget http://114.119.4.74:18083/test_dependents/centos.img
	fi
	cp centos_libvirt_demo.xml kvm.xml
	sed -i "s%<uuid>e06d5011-2de4-48a0-834e-72eecf7c99f0</uuid>%<uuid>${random_uuid}</uuid>%g" kvm.xml
	sed -i "s%<name>domain_aarch64</name>%<name>centos</name>%g" kvm.xml
	sed -i "s%<nvram>/var/lib/libvirt/qemu/nvram/domain_aarch64_VARS.fd</nvram>%<nvram>/var/lib/libvirt/qemu/nvram/centos_VARS.fd</nvram>%g" kvm.xml
	sed -i "s%<source file='/home/dingyu/fedora_01.qcow2'/>%<source file='${CUR_PATH}/centos.img'/>%g" kvm.xml
	sed -i "s%<mac address='52:54:00:85:f0:1c'/>%<mac address='52:54:00:85:f0:${random_mac}'/>%g" kvm.xml	
	;;
	debian)
	cd /var/lib/libvirt/qemu/nvram
	if [ ! -f "centos_VARS.fd" ];then
		chmod a+x ${CUR_PATH}/centos_fd.sh
		${CUR_PATH}/centos_fd.sh
	fi
	cd -
	if [ ! -f "debian.qcow2" ];then
		chmod a+x ${CUR_PATH}/debian_qcow2.sh
		${CUR_PATH}/debian_qcow2.sh
	fi
	cp centos.xml kvm.xml
	chmod 777 kvm.xml
	#sed -i "s%<name>kvm</name>%<name>kvm5</name>%g" kvm.xml
	sed -i "s%<uuid>e06d5011-2de4-48a0-834e-72eecf7c99f0</uuid>%<uuid>${random_uuid}</uuid>%g" kvm.xml
	sed -i "s%<name>domain_aarch64</name>%<name>centos</name>%g" kvm.xml
	sed -i "s%<nvram>/var/lib/libvirt/qemu/nvram/domain_aarch64_VARS.fd</nvram>%<nvram>/var/lib/libvirt/qemu/nvram/centos_VARS.fd</nvram>%g" kvm.xml
	sed -i "s%<source file='/home/kvm/debian.qcow2'/>%<source file='${CUR_PATH}/debian.qcow2'/>%g" kvm.xml
	sed -i "s%<mac address='52:54:00:85:f0:1c'/>%<mac address='52:54:00:85:f0:${random_mac}'/>%g" kvm.xml	
	;;
esac
	echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
	virsh define kvm.xml
	if [ $? -eq 0 ]
	then
		write_result "${RESULT_FILE}" "qemu_create" "pass"
	else
		write_result "${RESULT_FILE}" "qemu_create" "fail"
	fi
}

function specifications_update()
{
	sed -i "s/16777216/15728640/g" kvm.xml
	sed -i "/vcpu/s/10/8/g" kvm.xml
	virsh define kvm.xml
	memory_new=`virsh dominfo centos|grep -i 15728640|awk '{print $3}'|head -1`
	cpu_new=`virsh dominfo centos|grep -i cpu|awk '{print $2}'|head -1`
	if [ $memory_new -eq '15728640' ]
	then
		write_result "${RESULT_FILE}" "memory_update" "pass"
	else
		write_result "${RESULT_FILE}" "memory_update" "fail"
	fi
		
	if [ $cpu_new -eq '8' ]
	then
		write_result "${RESULT_FILE}" "cpu_update" "pass"
	else
		write_result "${RESULT_FILE}" "cpu_update" "fail"
	fi
	network_state=`virsh net-list --all|grep default|awk '{print $2}'`
	if [ $network_state == "inactive" ]
	then
		virsh net-start default
	fi
	qemu-img create -f qcow2 centos_add.img 100G
case "${distro}" in
	centos)	
	virsh start centos
	virsh attach-disk centos ${CUR_PATH}/centos_add.img sdk --subdriver=qcow2
	;;
	debian)
	chown root:kvm /dev/kvm
	service libvirtd restart
	virsh start centos
	virsh attach-device centos disk.xml
	;;
esac
	if [ $? -eq 0 ];then
		###@把测试的结果写入到结果文件中
		write_result "${RESULT_FILE}" "virdisk_add" "pass"
	else
        write_result "${RESULT_FILE}" "virdisk_add" "fail"
    fi
	
}


function disk_fio()
{
if [ ${distro} == "centos" ]
then
	disk1=sdb
	disk2=sdb1
elif [ ${distro} == "debian" ]
then
	disk1=vda
	disk2=vda1
else 
	disk=""
fi
EXPECT=$(which expect)	
$EXPECT <<EOF 
set timeout 1900
spawn virsh console centos
expect {
" is ^]" {send "\r";exp_continue} 
"login:" {send "root\r";exp_continue}
"Password:" {send "root\r"}
}
expect "]#"
send "ssh-keygen -R 192.168.122.1\r"
expect {
"]#" {send "scp root@192.168.122.1:/root/fio /usr/local/'bin'\r";exp_continue}
")?" {send "yes\r";exp_continue}
"password:" {send "root\r"}
}
expect "]#"
send "chmod 777 /usr/local/'bin'/fio\r"
expect "]#"
send "fdisk /dev/$disk1\r"
expect "):"
send "n\r"
expect "):"
send "\r"
expect "):"
send "\r"
expect "):"
send "\r"
expect "):"
send "+20G\r"
expect "):"
send "w\r"
expect "]#"
send "fio -filename=/dev/$disk2 -direct=1 -iodepth 1 -thread -rw=rw -ioengine=psync -bs=4k -size=10G -numjobs=1 -runtime=1800 -time_based=1 -group_reporting -name=rw_10G_4k \r"
expect eof
EOF

}

###@test2###


function qemu_suspend()
{
	virsh suspend centos
	state=`virsh list --all|grep -w centos|awk '{print $NF}'`
	if [ $? -eq 0 ]
	then
		write_result "${RESULT_FILE}" "qemu_suspend" "pass"
	else
		write_result "${RESULT_FILE}" "qemu_suspend" "fail"
	fi
}

function qemu_recovery()
{
	virsh resume centos
	state=`virsh list --all|grep -w centos|awk '{print $NF}'`
	if [ $? -eq 0 ]
	then
		write_result "${RESULT_FILE}" "qemu_recovery" "pass"
	else
		write_result "${RESULT_FILE}" "qemu_recovery" "fail"
	fi
	
}

function qemu_shutdown()
{
	virsh destroy centos
	if [ $? -eq 0 ];then
		###@把测试的结果写入到结果文件中
		write_result "${RESULT_FILE}" "qemu_shutdown" "pass"
	else
        write_result "${RESULT_FILE}" "qemu_shutdown" "fail"
		
    fi
}

function qemu_start()
{
    virsh start centos
	if [ $? -eq 0 ];then
		###@把测试的结果写入到结果文件中
		write_result "${RESULT_FILE}" "qemu_start" "pass"
	else
        write_result "${RESULT_FILE}" "qemu_start" "fail"
		
    fi
}

function qemu_clone()
{
	virt-clone -o centos -n centos1 -f centos1.img
	virt-clone -o centos -n centos2 -f centos2.img
	count=`virsh list --all|grep centos|wc -l`
	if [ $count -eq '3' ]
	then
		write_result "${RESULT_FILE}" "qemu_clone" "pass"
	else
		write_result "${RESULT_FILE}" "qemu_clone" "fail"
	fi
	virsh start centos
	virsh start centos1
	virsh start centos2
}

function qemu_migration()
{
virsh dumpxml centos > /root/kvm.xml
if [ ${distro} == "centos" ]
then
	iso=centos.img
elif [ ${distro} == "debian" ]
then
	iso=debian.qcow2
else
	iso=""
fi
EXPECT=$(which expect)	
$EXPECT <<EOF
set timeout 60
spawn ssh root@192.168.2.75
expect {
")?" {send "yes\r";exp_continue}
"password:" {send "root\r"}
}
expect {
"#" {send "scp root@192.168.2.2:/root/kvm.xml /root\r";exp_continue}
")?" {send "yes\r";exp_continue}
"password:" {send "root\r"}
}
expect {
"#" {send "scp root@192.168.2.2:/home/test-definitions/auto-test/virtualization/virtual/qemu/$iso /home/test-definitions/auto-test/virtualization/virtual/qemu\r";exp_continue}
"password:" {send "root\r"}
}
expect "]#"
send "sed -i 's/#user = /user = /g' /etc/libvirt/qemu.conf\r"
expect "]#"
send "sed -i 's/#group = /group = /g' /etc/libvirt/qemu.conf\r"
expect "]#"
send "systemctl restart libvirtd\r"
expect "]#"
send "virsh define kvm.xml\r"
expect "]#"
send "virsh net-start default\r"
expect "]#"
send "virsh start centos\r"
expect "]#"
send "virsh destroy centos\r"
expect "]#"
send "virsh undefine centos --nvram\r"
expect eof
EOF

}

function qemu_connect()
{	
EXPECT=$(which expect)	
$EXPECT <<EOF
set timeout 60
spawn virsh console centos
expect {
" is ^]" {send "\r";exp_continue} 
"login:" {send "root\r";exp_continue}
"Password:" {send "root\r"}
}
expect "]#"
send "ip a\r"
expect "]#"
send "echo nameserver 114.114.114.114 > /etc/resolv.conf\r"
expect eof
EOF

}

function qemu_reboot()
{
EXPECT=$(which expect)	
$EXPECT <<EOF
set timeout 60
spawn virsh console centos
expect {
" is ^]" {send "\r";exp_continue} 
"login:" {send "root\r";exp_continue}
"Password:" {send "root\r"}
}
expect "]#"
send "reboot\r"
expect eof
EOF
}


function time_synchronization()
{
EXPECT=$(which expect)	
$EXPECT <<EOF
set timeout 10400
spawn virsh console centos
expect {
" is ^]" {send "\r";exp_continue} 
"login:" {send "root\r";exp_continue}
"Password:" {send "root\r"}
}

expect {
"]#" {send "scp root@192.168.2.2:/root/os_reboot_cycle .\r";exp_continue}
")?" {send "yes\r";exp_continue}
"password:" {send "root\r"}
}
expect "]#"
send "chmod a+x os_reboot_cycle\r"
expect "]#"
send "./os_reboot_cycle 100\r"
expect eof
EOF

#sleep 180

$EXPECT <<EOF
set timeout 60
spawn virsh console centos
expect {
" is ^]" {send "\r";exp_continue} 
"login:" {send "root\r";exp_continue}
"assword:" {send "root\r"}
}
expect "]#"
send "date +%s > time.txt\r"
expect {
"]#" {send "scp /root/time.txt root@192.168.2.2:/home/test-definitions/auto-test/virtualization/virtual/qemu/time1.txt\r";exp_continue}
")?" {send "yes\r";exp_continue}
"assword:" {send "root\r"}
}
expect eof
EOF
	# chmod a+x ${CUR_PATH}/qemu-kvm-time.sh
	# ${CUR_PATH}/qemu-kvm-time.sh	
date +%s > time.txt
a=`cat time.txt`
b=`cat time1.txt`
if [[ $(($a-$b)) -lt 61 && $(($a-$b)) -gt 59 ]]
then
	write_result "${RESULT_FILE}" "time_synchronization" "pass"
else
	write_result "${RESULT_FILE}" "time_synchronization" "fail"
fi	
}

################################基本功能测试################################
###基本功能测试###
function basic_function()
{  
    qemu_create
	
	specifications_update
	
	disk_fio
	
    qemu_suspend
	
	qemu_recovery
	
	qemu_shutdown
	
	qemu_start
	
	qemu_shutdown
	
	qemu_clone
	
	qemu_migration
	
	qemu_connect
	
	qemu_reboot
	
	time_synchronization
}

###压力测试###
function performance_test()
{
	###@压力测试###
	chmod a+x ${CUR_PATH}/qemu-kvm-stress.sh
	for ((i=0;i<$length;i++))
	do
	${CUR_PATH}/qemu-kvm-stress.sh	${vmachine[$i]}
	done
	if [ $? -eq 0 ]
	then
		write_result "${RESULT_FILE}" "qemu_stress" "pass"
	else
		write_result "${RESULT_FILE}" "qemu_stress" "fail"
	fi
}

################################清理环境################################
function clean_env()	
{
    ###@清除临时文件###
    FUNC_CLEAN_TMP_FILE
	
	#停止虚拟机
	virsh destroy centos
	virsh destroy centos1
	virsh destroy centos2

	#删除虚拟机
	virsh undefine centos --nvram
	virsh undefine centos1 --nvram
	virsh undefine centos2 --nvram
    ###@停止服务 @结束进程 @移除redis###
	#停止libvirt服务
	systemctl stop libvirtd
	  
	#删除下载文件
	#rm -rf /usr/share/AAVMF
	rm -rf kvm.xml
	rm -rf centos_add.img
	rm -rf centos1.img
	rm -rf centos2.img
	rm -rf time.txt
	rm -rf time1.txt
}

###调用所有函数###
function main()
{
	###@调用所有的函数###
	init_env 
    basic_function
    performance_test
	
	###@检查结果文件###
    check_resultes ${RESULT_FILE}
	
	###@结果文件转为json文件，方便入库###
	cd ${path}
    python ${PY_JSON_TRANSFOR} ${RESULT_FILE} ${test_name}
	add_json ${test_name}.json
	###@调用入库函数###
	#data_to_db ${PWD}/${test_name}.json #!!!!!!!!需要处理失败异常!!!!!!!!!!!
	
	###@清理环境###
    clean_env 
	rm -rf ${RESULT_FILE}
	rm -rf ${path}/logs
	echo "case test Complete"
}

main 


