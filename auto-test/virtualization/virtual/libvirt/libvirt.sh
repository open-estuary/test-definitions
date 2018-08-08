#!/bin/bash
. ../../../../utils/sh-test-lib
. ../../../../utils/sys_info.sh

url=$(`pwd`)
echo $url
random_uuid=`cat /proc/sys/kernel/random/uuid`

! check_root && error_msg "Please run this script as root."

#Check that the kernel supports KVM
ret=`dmesg|grep kvm|grep "initialized successfully"|awk '{print $7,$8}'`
if [ "$ret"x = "initialized successfully"x ];then
        print_info 0 kvm_enable
else
        print_info 1 kvm_enable
fi

#Installation package
apt-get install qemu-kvm qemu-efi libvirt-bin virtinst
print_info $? qemu_libvirt

#Modify configuration file
sed -i "s/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g" /etc/libvirt/libvirtd.conf
sed -i "s/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/g" /etc/libvirt/libvirtd.conf
sed -i "s/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g" /etc/libvirt/libvirtd.conf
sed -i "s/#auth_unix_ro = "none"/auth_unix_ro = "none"/g" /etc/libvirt/libvirtd.conf
sed -i "s/#auth_unix_rw = "none"/auth_unix_rw = "none"/g" /etc/libvirt/libvirtd.conf
sed -i "s/#listen_tls = 0/listen_tls = 0/g" /etc/libvirt/libvirtd.conf
sed -i "s/#listen_tcp = 1/listen_tcp = 1/g" /etc/libvirt/libvirtd.conf
sed -i "s/#auth_tcp="sasl"/auth_tcp="none"/g" /etc/libvirt/libvirtd.conf
print_info $? modify_configure



sed -i "s/<source file='/home/dingyu/cirros-0.4.0-aarch64-disk.img'\/>/<source file='${url}/cirros-0.4.0-aarch64-disk.img'\/>/g" ./demo.xml
print_info $? modify_xml

wget http://192.168.50.122:8083/test_dependents/cirros-0.4.0-aarch64-disk.img
print_info $? download_img

#Start the libvirt service
service libvirtd start
print_info $? libvirtd_start

#Test whether libvirt works at the system level
virsh -c qemu:///system list
print_info $? libvirt_works

#Create virtual machines
cp demo.xml domain_aarch64.xml
sed -i "s/<uuid>e06d5011-2de4-48a0-834e-72eecf7c99f0<\/uuid>/<uuid>${random_uuid}<\/uuid>/g" domain_aarch64.xml
print_info $? modify_uuid

virsh define domain_aarch64.xml
print_info $? virtual_create

virsh start domain_aarch64
print_info $? virtual_start

virsh list --all
print_info $? virsh_list

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

domain_id=`virsh list --all|grep domain_aarch64|awk '{print $1}'`
virsh vcpuinfo ${domain_id}
print_info $? vcpu_info

virsh shutdown domain_aarch64
print_info $? domain_shutdown

virsh destroy domain_aarch64
print_info $? domain_destroy

#delete virtual machines
virsh undefine --nvram domain_aarch64
print_info $? domain_undefine

rm -rf cirros-0.4.0-aarch64-disk.img
print_info $? delete_img

rm -rf domain_aarch64.xml
print_info $? delete_xml


