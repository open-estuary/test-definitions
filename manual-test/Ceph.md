---
ceph.md - 测试v500对ceph的兼容性及其基本功能
Hardware platform: D05，D03
Software Platform: CentOS,Ubuntu,OpenSuse
Author: Liu Caili <meili760628705@163.com>  
Date: 2017-11-09 15:51:00 
Categories: Estuary Documents  
Remark:
---

- **Dependency:**
    测试环境搭建
       	准备3台服务器：
       		Ubuntu: 3台服务器均安装Ubuntu系统
       		CentOS: 3台服务器均安装CentOS系统
       		OpenSuse: 3台服务器均安装OpenSuse系统
       	1台作为Monitor，1台作为OSD RGW，另一台作为OSD


- **Source code:**
    no

- **Build:**
    no

- **Test:**
       注意：以ubuntu为例，centos、opensuse仅安装命令不同，分别为
       		ubuntu: apt-get install
       		centos: yum install 
       		opensuse: zypper install
       
    	1.正确配置hosts和hostname
       	修改主机名:vim /etc/hostname
	生效:hostname NodeName
 	添加IP与主机名对应关系:vim /etc/hosts
	       127.0.0.1   localhost
	       127.0.1.1   node1
	       192.168.1.100   node1
	       192.168.1.101   node2
	       192.168.1.102   node3
	
     	2.搭建NTP server
     	安装ntp:apt-get install ntp
	重启ntp服务:service ntp restart
	
	3.搭建NTP client
	安装ntpdate:apt-get install ntpdate
     		     	
	4.安装SSH SERVER
	在所有的节点上都安装SSH server服务:
		apt-get install openssh-server
	修改/etc/ssh/sshd_config中:
      		PermitRootLogin=yes
	重启ssh:service ssh restart
	
	5.设置使用SSH免密码登录
	生成SSH: keysssh-keygen
	拷贝这个key到所有的节点:ssh-copy-id 节点名
	
	6.安装Ceph-deploy
	mkdir my-cluster
	cd my-cluster
	apt-get update && sudo apt-get install ceph-deploy
	
	7.部署Ceph
	ceph-deploy install {ceph-node}[{ceph-node} …]
	
	8.安装monitor
	ceph-deploy mon create-initial
	
	9.创建OSD数据目录
	 ssh OSD-节点名
	 sudo mkdir /var/local/osd0
	 chown ceph:ceph /var/local/osd0
	 exit
	
	10.准备OSD
	ceph-deploy osd prepare {ceph-node}:/path/to/directory
	
	11.激活OSD
	ceph-deploy osd prepare {ceph-node}:/path/to/directory
	
	12.拷贝配置文件及管理key
	ceph-deploy admin node1 node2
	chmod +r /etc/ceph/ceph.client.admin.keyring
	
	13.查看集群状态
	ceph –s
	集群应该返回health HEALTH_OK，并且所有pg都是active+clean的状态，这样部署就完全没问题了
	
	12.部署rgw网关
	ceph-deploy rgw create {gateway-node}
	
	13.验证Ceph是否正常工作
	新建文件并写入内容:vim testfile.txt: hello Ceph
	创建一个pool:rados mkpool {pool-name}
	将文件写入pool:rados put {object-name} {file-path} –pool={pool-name}
	查看文件是否存在于pool中:rados -p {pool-name} ls
	确定文件的位置:ceph osd map {pool-name} {object-name}
	从pool中读取文件:rados get {object-name} –pool={pool-name} {file-path} 
	比对文件内容:diff myfile testfile.txt
	从pool中删除文件:rados rm {object-name} –pool={pool-name}
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail