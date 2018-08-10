---
libvirt.md -libvirt是管理虚拟机和其他虚拟功能，比如存储管理、网络管理的软件集合，主要对qemu-kvm虚拟机的生命周期操作进行测试
Hardware platform: D05 D06
Software Platform: Ubuntu
Author: Ding Yu <1136920311@qq.com>
Date: 2018-07-27 16:38:05
Categories: Estuary Documents
Remark:
---

# Dependency
```
  1、D05/D06上部署最新版本的Ubuntu系统，并成功进入；
  2、检查内核是否支持kvm,使用命令dmesg|grep kvm
  3、准备centos发行版的.iso的镜像文件，放入/var/lib/libvirt/images目录下；

```

# Test
```
  1、安装所需要的安装包
	apt-get install qemu-kvm
	apt-get install qemu-efi
	apt-get install libvirt-bin
	apt-get install virtinst
  2、修改配置文件
	(1)为了给 libvirt 组用户定义基于文件的权限以管理虚拟机，取消下列行的注释： 
	vi /etc/libvirt/libvirtd.conf
	#unix_sock_group = "libvirt"
	#unix_sock_ro_perms = "0777"
	#unix_sock_rw_perms = "0770"
	#auth_unix_ro = "none"
	#auth_unix_rw = "none"
	(2)使用非加密的TCP/IP sockets
	vi /etc/libvirt/libvirtd.conf
	listen_tls = 0
	listen_tcp = 1
	auth_tcp="none"
  3、启动libvirt服务
	$ service libvirtd start
  4、测试测试 libvirt 在系统级工作是否正常： 
	$ virsh -c qemu:///system list
	setlocale: No such file or directory
 	Id    Name                           State
	----------------------------------------------------
  5、创建虚拟机
	$ virt-install \
   	--name centos7   \ #虚拟机名
	--ram 2048  \      #分配内存大小，MB
	--arch aarch64 \   #模拟的CPU架构
   	--boot uefi \      #启用uefi支持
	--disk size=8  \   #创建8G的磁盘空间
   	--cdrom /var/lib/libvirt/images/CentOS-7-aarch64-Everything.iso \ #系统镜像文件
   	--virt-type kvm    #使用kvm虚拟机
  6、启动虚拟机
	$ virsh start centos7
  7、重启虚拟机
	$ virsh reboot centos7
  8、设置虚拟机跟随系统自启
	$ virsh auto
  9、关闭自启
  8、强制关闭虚拟机
  7、暂停虚拟机
	$ virsh suspend centos7
  8、恢复虚拟机
	$ virsh resume centos7
  9、关闭虚拟机
	$ virsh shutdown centos7
  10、登录虚拟机
	$ virsh console centos7
  11、退出虚拟机
	快捷键ctrl+]
  12、自动加载虚拟机
	$ virsh autostart contos7
  13、克隆虚拟机
	$ virt-clone --connect=qemu:///system -o centos7 -n centos1 -f /var/lib/libvirt/images/centos1.qcow2
  14、列出所有虚拟机
  15、查看虚拟机信息
  16、显示虚拟机配置文件内容
  17、添加虚拟机（不启动）
  18、添加并创建虚拟机（立即启动）
  19、查看虚拟机使用的磁盘文件
  20、查看虚拟机磁盘文件信息
  21、修改虚拟机的配置文件
  22、







	

	
```


