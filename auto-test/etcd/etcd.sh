#!/bin/bash

set -x

cd ../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

case "${distro}" in
	centos|fedora)
		sudo wget -O /etc/yum.repos.d/estuary.repo https://raw.githubusercontent.com/open-estuary/distro-repo/master/estuaryftp.repo
		sudo chmod +r /etc/yum.repos.d/estuary.repo
		sudo rpm --import ftp://repoftp:repopushez7411@117.78.41.188/releases/ESTUARY-GPG-KEY
		yum clean dbcache
		print_info $? setup-estuary-repository
		
		pkgs="etcd"
		install_deps "${pkgs}"
		print_info $? install-bazel
	;;
	*)
		error_msg "Unsupported distribution!"
esac

etcd &
print_info $? start-single-etcd

etcdctl set hello world
print_info $? create-key-value

etcdctl get hello | grep "world"
print_info $? search-key-value

kill -9 $(pidof etcd)
print_info $? stop-single-etcd

echo $local_ip
etcd --name infra0 --initial-advertise-peer-urls http://$local_ip:2380 \
	--listen-peer-urls http://$local_ip:2380 \
	--listen-client-urls http://$local_ip:2379,http://127.0.0.1:2379 \
	--advertise-client-urls http://$local_ip:2379 \
	--initial-cluster-token etcd-cluster-1 \
	--initial-cluster infra0=http://$local_ip:2380,infra1=http://$local_ip:2382,infra2=http://$local_ip:2384 \
	--initial-cluster-state new &

etcd --name infra1 --initial-advertise-peer-urls http://$local_ip:2382 \
	--listen-peer-urls http://$local_ip:2382 \
	--listen-client-urls http://$local_ip:2381,http://127.0.0.1:2381 \
	--advertise-client-urls http://$local_ip:2381 \
	--initial-cluster-token etcd-cluster-1 \
	--initial-cluster infra0=http://$local_ip:2380,infra1=http://$local_ip:2382,infra2=http://$local_ip:2384 \
	--initial-cluster-state new &

etcd --name infra2 --initial-advertise-peer-urls http://$local_ip:2384 \
	--listen-peer-urls http://$local_ip:2384 \
	--listen-client-urls http://$local_ip:2383,http://127.0.0.1:2383\
	--advertise-client-urls http://$local_ip:2383 \
	--initial-cluster-token etcd-cluster-1 \
	--initial-cluster infra0=http://$local_ip:2380,infra1=http://$local_ip:2382,infra2=http://$local_ip:2384 \
	--initial-cluster-state new &

print_info $? start-cluster-etcd

etcdctl member list
print_info $? search-cluster-list

etcdctl cluster-health | grep 'cluster is healthy'
print_info $? check-cluster-health

kill -9 $(pidof etcd)
print_info $? stop-cluster-etcd

yum remove -y etcd
print_info $? remove-etcd


