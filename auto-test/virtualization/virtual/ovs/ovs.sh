#!/bin/bash

set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

#install
pkgs="wget expect libtool net-tools "
install_deps "${pkgs}"
print_info $? install-tools

case "${distro}" in
	debian|ubuntu)
		apt-get update
		apt-get install -y openvswitch-switch openvswitch-common
		print_info $? install-ovs
	;;
	centos|fedora)
		yum update
		yum install -y openvswitch openvswitch-devel openvswitch-test openvswitch-debuginfo
		print_info $? install-ovs
		systemctl start openvswitch.service
		print_info $? start-ovs-service
	;;
	*)
		error_msg "Unsupported distribution!"
esac

#ovsdb-server -v --remote=punix:/usr/local/var/run/openvswitch/db.sock \
#	--remote=db:Open_vSwitch,Open_vSwitch,manager_options \
#	--private-key=db:Open_vSwitch,SSL,private_key \
#	--certificate=db:Open_vSwitch,SSL,certificate \
#	--bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile --detach
systemctl start openvswitch
ps -ef | grep ovsdb-server
print_info $? start-ovsdb-server

ovs-vsctl --no-wait init
print_info $? init-ovs-db

#ovs-vswitchd --pidfile --detach
ps -ef |grep ovs
print_info $? start-ovs-vswitchd

ovs-vsctl --version
print_info $? ovs-version

ovs-vsctl add-br br0
ifconfig br0
print_info $? ovs-add-br

ovs-vsctl list-br
print_info $? ovs-list-br

ifconfig br0 up
ifconfig br0 | grep UP
print_info $? up-br0

case "${distro}" in
	debian|ubuntu)
		ovs-vsctl add-port br0 enahisic2i0
	;;
	centos|fedora)
		ovs-vsctl add-port br0 eth0
	;;
esac
print_info $? ovs-add-port

ovs-vsctl list-ports br0
print_info $? ovs-list-port

case "${distro}" in
	debian|ubuntu)
		ovs-vsctl port-to-br enahisic2i0
	;;
	centos|fedora)
		ovs-vsctl port-to-br eth0
	;;
esac
print_info $? list-port-to-br

ovs-vsctl show
print_info $? show-ovs-status

case "${distro}" in
	debian|ubuntu)
		ovs-vsctl del-port br0 enahisic2i0
	;;
	centos|fedora)
		ovs-vsctl del-port br0 eth0
	;;
esac
print_info $? ovs-del-port

ovs-vsctl del-br br0
print_info $? ovs-del-br

case "${distro}" in
	debian|ubuntu)
		apt-get remove -y openvswitch-switch openvswitch-common
	;;
	centos|fedora)
		systemctl stop openvswitch.service
		print_info $? start-ovs-service
		yum remove -y openvswitch openvswitch-devel openvswitch-test openvswitch-debuginfo
	;;
	*)
		error_msg "Unsupported distribution!"
esac
print_info $? remove-ovs

