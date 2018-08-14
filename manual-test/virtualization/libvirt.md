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
	$ virsh autostart centos7
  9、关闭自启
	$ virsh autostart --disable centos7
  10、强制关闭虚拟机
	$ virsh destroy centos7
  11、暂停虚拟机
	$ virsh suspend centos7
  12、恢复虚拟机
	$ virsh resume centos7
  13、关闭虚拟机
	$ virsh shutdown centos7
  14、登录虚拟机
	$ virsh console centos7
  15、退出虚拟机
	快捷键ctrl+]
  16、克隆虚拟机(被克隆的虚拟机必须处于关闭状态)
	$ virt-clone --connect=qemu:///system -o centos7 -n centos1 -f /var/lib/libvirt/images/centos1.qcow2
  18、列出所有虚拟机
	$ virsh list --all
  19、添加虚拟机（不启动）
	$ virsh define centos7.xml
  20、添加并创建虚拟机（立即启动）
	$ virsh create centos7.xml
  21、查看虚拟机磁盘文件信息
	$ qemu-img info centos7.qcow2
  22、修改虚拟机的配置文件
	$ virsh edit centos7
  23、查看虚拟机信息
	$ virsh dominfo centos7
  24、显示虚拟机配置文件内容
	$ virsh dumpxml centos7
  25、显示虚拟机vcpu的信息
	$ virsh vcpuinfo centos7
  26、显示虚拟机的内存状态
	$ virsh dommemstat centos7
  27、显示虚拟机id号
	$ virsh domid cents7
  28、显示虚拟机uuid
	$ virsh domuuid centos7
  29、显示虚拟机当前的状态
	$ virsh domstate centos7
  30、显示虚拟机使用的磁盘文件
	$ virsh domblklist centos7
  31、显示虚拟机网卡接口
	$ virsh domiflist centos7
  32、显示网卡信息
	$ virsh domiflist centos7
  33、返回虚拟机的状态（ok or error）
	$ virsh domcontrol centos7
  34、显示虚拟机分区信息
	$ virsh memtune centos7
  35、显示虚拟机磁盘信息
	$ virsh blkiotune centos7
  36、给不活动虚拟机设置内存大小(不能超过最大内存)
	$ virsh setmem centos7 512 --current
  37、设置虚拟机最大内存
	$ virsh setmaxmem centos7
  38、给不活动虚拟机设置cpu个数(不能超过最大vcpu数)
	$ virsh setvcpus centos7 4  --current
  39、保存当前运行的虚拟机状态，当虚拟机再次启动时会恢复到之前保存的状态
	$ virsh managedsave domain-id(虚拟机id)
  40、保存一个正在运行的虚拟机的状态到一个文件中，保存后虚拟机不再运行
	$ virsh save domain-id state-file
  41、恢复到之前保存的状态
	$ virsh restore state-file
  42、彻底删除虚拟机
	1、关闭虚拟机 virsh destroy centos7
	2、取消虚拟机定义 virsh undefine --nvram centos7	
	3、删除磁盘文件 virsh dumpxml centos7|grep "source file",将source file删除
  
-----------------------------------------------------------------------------------------------------
  43、异常场景分析
	1、单个虚拟机内存大小不能超过系统剩余内存
		步骤：
		a、查询系统剩余内存=free -m
		b、创建虚拟机，使用边界值分析，分别创建虚拟机内存ram小于、等于、大于系统剩余内存的场景	
		结果：虚拟机内存小于或等于系统剩余内存时，虚拟机创建成功；虚拟机内存大于系统剩余内存时，虚拟机创建失败，返回“无法分配内存”
	2、多个虚拟机内存大小之和不能超过系统剩余内存
		步骤：
		a、查询系统剩余内存=free -m
		b、创建3个虚拟机，使用边界值分析，分别创建3个虚拟机的内存之和小于、等于、大于系统剩余内存的场景
		结果：虚拟机内存小于或等于系统剩余内存时，虚拟机创建成功；虚拟机内存大于系统剩余内存时，虚拟机创建失败，返回“无法分配内存”
	3、单个虚拟机vcpu数不能超过物理机CPU数
		步骤：
		a、查询物理机CPU数(lsmod)，查看CPU(s)参数
		b、创建虚拟机，使用边界值分析，分别创建虚拟vcpu数小于、等于、大于物理机CPU数的场景
		结果：虚拟机vcpu数小于或等于物理机CPU数时，虚拟机创建成功；虚拟机vcpu数大于物理机CPU数时，虚拟机创建失败，主机挂机
	4、多个虚拟机vcpu数之和不能超过物理机CPU数
		步骤：
		a、查询物理机CPU数(lsmod)，查看CPU(s)参数
		b、创建3个虚拟机，使用边界值分析，分别创建3个虚拟机的vcpu数小于、等于、大于物理机CPU数的场景
		结果：虚拟机vcpu数小于或等于物理机CPU数时，虚拟机创建成功；虚拟机vcpu数大于物理机CPU数时，虚拟机创建失败，主机挂机
	5、设置虚拟机内存不能超过最大内存
		步骤：
		a、查询虚拟机最大内存(virsh dominfo centos7),查看Max memory参数值
		b、设置虚拟机内存超过最大内存(virsh setmem centos7 1048576 --current)
		结果：报错“cannot set memory higher than max memory”
	6、设置虚拟机vcpu数不能超过最大可允许的vcpu数
		步骤：
		a、查询虚拟机最大vcpu数(virsh dominfo centos7),查看CPU(s)参数值
		b、设置虚拟机vcpu数超过最大vcpu数(virsh setvcpus centos7 4 --current)
		结果：报错“requested vcpus is greater than max allowable vcpus for the persistent domain”




	

	
```


