#!/bin/bash
set -x
source ../../../../utils/sh-test-lib
source ../../../../utils/sys_info.sh

! check_root && error_msg "Please run this script as root."

##################### Environmental preparation ###################
### variables set ###
path=`pwd`
random_uuid=`cat /proc/sys/kernel/random/uuid`

### Download the virtual machine image file ###
pkgs="wget"
install_deps "${pkgs}"
#wget http://120.31.149.194:18083/test_dependents/cirros-0.4.0-aarch64-disk.img
wget ${ci_http_addr}/test_dependents/cirros-0.4.0-aarch64-disk.img


case "${distro}" in
    ubuntu)
	# Check if the kernel support kvm
	ret=`dmesg|grep kvm|grep "initialized successfully"|awk '{print $7,$8}'`
	if [ "$ret"x != "initialized successfully"x ];then
        	echo "the kernel not supports KVM" >&2
        	exit 1
	fi
	pkgs="qemu-kvm qemu-efi libvirt-bin virtinst"
	install_deps "${pkgs}"
	print_info $? install-package
	;;
   centos)
	pkgs="qemu-kvm libvirt virt-install libguestfs-tools bridge-utils libvirt-python virt-manager"
	install_deps "${pkgs}"
	print_info $? install-package
	#添加loaler文件
	;;
   fedora)
	pkgs="qemu-kvm libvirt virt-install libguestfs-tools bridge-utils"
	install_deps "${pkgs}"
        print_info $? install-package
	;;
esac


##################  initialize ###############################
LIBVIRT=/etc/libvirt/libvirtd.conf
#To define file-based permissions for the libvirt group users to 
#manage the virtual machine, uncomment the following lines:
sed -i "s/#unix_sock_group = /unix_sock_group = /g" $LIBVIRT
sed -i "s/#unix_sock_ro_perms = /unix_sock_ro_perms = /g" $LIBVIRT
sed -i "s/#unix_sock_rw_perms = /unix_sock_rw_perms = /g" $LIBVIRT
sed -i "s/#auth_unix_ro = /auth_unix_ro = /g" $LIBVIRT
sed -i "s/#auth_unix_rw = /auth_unix_rw = /g" $LIBVIRT
#Use non-encrypted TCP/IP sockets
sed -i "s/#listen_tls = 0/listen_tls = 0/g" $LIBVIRT
sed -i "s/#listen_tcp = 1/listen_tcp = 1/g" $LIBVIRT
sed -i "s/#auth_tcp="sasl"/auth_tcp="none"/g" $LIBVIRT
#Add root to users and groups
sed -i "s/#user = /user = /g" /etc/libvirt/qemu.conf
sed -i "s/#group = /group = /g" /etc/libvirt/qemu.conf

systemctl start libvirtd 
print_info $? libvirtd_start

res=`virsh -c qemu:///system list|grep "Id"|awk '{print $1}'`
if [ "$res"x != "Id"x ];then
        echo "the libvirt service is fail" >&2
        exit 1
fi

case "${distro}" in
    ubuntu)
	cp ubuntu_libvirt_demo.xml domain_aarch64.xml
	sed -i "s%<uuid>e06d5011-2de4-48a0-834e-72eecf7c99f0</uuid>%<uuid>${random_uuid}</uuid>%g" domain_aarch64.xml
	sed -i "s%<source file='/home/dingyu/cirros-0.4.0-aarch64-disk.img'/>%<source file='${path}/cirros-0.4.0-aarch64-disk.img'/>%g" domain_aarch64.xml
	;;
    fedora)
	cp fedora_libvirt_demo.xml domain_aarch64.xml
	sed -i "s%<uuid>0af1092d-6aea-4e71-927e-538f131b9f39</uuid>%<uuid>${random_uuid}</uuid>%g" domain_aarch64.xml
        sed -i "s%<source file='/home/dingyu/fedora_01.qcow2'/>%<source file='${path}/cirros-0.4.0-aarch64-disk.img'/>%g" domain_aarch64.xml
	;;
    centos)
	cp centos_libvirt_demo.xml domain_aarch64.xml
	sed -i "s%<uuid>e06d5011-2de4-48a0-834e-72eecf7c99f0</uuid>%<uuid>${random_uuid}</uuid>%g" domain_aarch64.xml
        sed -i "s%<source file='/home/dingyu/fedora_01.qcow2'/>%<source file='${path}/cirros-0.4.0-aarch64-disk.img'/>%g" domain_aarch64.xml
	;;
esac
 ################## testing the step ##############################
#Create virtual machines
virsh define domain_aarch64.xml
print_info $? virtual_create

#Start virtual machines
virsh start domain_aarch64
print_info $? virtual_start

#Virtual machine lifecycle operations
virsh reboot domain_aarch64
print_info $? domain_reboot

virsh list --all
print_info $? virsh_list

#从一个xml文件进行磁盘热插拔
mkdir -p /home/domain
qemu-img create -f qcow2 /home/domain/huge.img 500G
virsh attach-device domain_aarch64 disk.xml
print_info $? domain_attach-device

#通过attach-disk进行磁盘热插拔
#qemu-img create -f qcow2 /home/domain/test.img 500G
#virsh attach-disk domain_aarch64 /home/domain/test.img vdb --subdriver qcow2
#print_info $? domain_attach-disk

#删除热插拔
virsh detach-device domain_aarch64 disk.xml
print_info $? domain_detach_device

#virsh detach-disk domain_aarch64 /home/domain/test.img
#print_info $? domain_detach_disk

#使用blkdeviotune设置虚拟机的读写速度和iops
BLKDEV=`virsh domblklist domain_aarch64|grep "cirros-0.4.0-aarch64-disk.img"|awk '{print $1}'`
virsh blkdeviotune domain_aarch64 $BLKDEV --read-bytes-sec 20000000 --write-bytes-sec 1000000  --read-iops-sec 15 --write-iops-sec 15 --live
res=`virsh blkdeviotune domain_aarch64 $BLKDEV|grep "read_iops_sec"|awk '{print $3}'`
if [ "$res"x == "15"x ];then
        print_info 0 domain_blkdeviotune
else
        print_info 1 domain_blkdeviotune
fi

#使用blkiotune设置虚拟机的权重
virsh blkiotune domain_aarch64 --weight 700 --live
res1=`virsh blkiotune domain_aarch64 |grep "weight "|awk '{print $3}'`
if [ "$res1"x == "700"x ];then
	print_info 0 domain_blkiotune
else
	print_info 1 domain_blkiotune
fi



virsh autostart domain_aarch64
print_info $? domain_autostart

virsh autostart --disable domain_aarch64
print_info $? disable_autostart

virsh dominfo domain_aarch64
print_info $? domain_info

virsh dumpxml domain_aarch64
print_info $? dumpxml_info

virsh suspend domain_aarch64
print_info $? domain_suspend

virsh resume domain_aarch64
print_info $? domain_resume

virsh dommemstat domain_aarch64
print_info $? domain_mem

virsh vcpuinfo domain_aarch64
print_info $? vcpu_info

virsh domid domain_aarch64
print_info $? domain_id

virsh domuuid domain_aarch64
print_info $? domain_uuid

virsh domstate domain_aarch64
print_info $? domain_status

virsh domblklist domain_aarch64
print_info $? domain_blk

virsh domiflist domain_aarch64
print_info $? domain_ifconfig

virsh domcontrol domain_aarch64
print_info $? domain_control

virsh memtune domain_aarch64
print_info $? domain_memtune

virsh blkiotune domain_aarch64
print_info $? domain_blkiotune

virsh shutdown domain_aarch64
print_info $? domain_shutdown

virsh destroy domain_aarch64
print_info $? domain_destroy

virsh setmaxmem domain_aarch64 1048576
print_info $? domain_setmaxmem

virsh setmem domain_aarch64 524288 --current
print_info $? domain_setmem 

virsh setvcpus domain_aarch64 1 --current
print_info $? domain_setvcpus 

virt-clone --connect=qemu:///system -o domain_aarch64 -n domain_copy -f /var/lib/libvirt/images/domain_copy.qcow2
print_info $? domain_clone

#delete virtual machines
virsh undefine --nvram domain_aarch64
rm -rf cirros-0.4.0-aarch64-disk.img
print_info $? domain_undefine


################ environment  restore  #######################
virsh undefine --nvram domain_copy
rm -rf /var/lib/libvirt/images/domain_copy.qcow2
print_info $? delete_clone

rm -rf domain_aarch64.xml AAVMF_CODE.fd
rm -rf /home/domain

#Stop the libvirt service
service libvirtd stop
print_info $? libvirtd_stop

#remove packgs
remove_deps ${pkgs}
print_info $? remove_pkgs

