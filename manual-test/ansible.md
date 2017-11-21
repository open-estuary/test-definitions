---
ansible.md - ansible是自动化运维工具，基于python
 
Hardware platform: D05 D03  
Software Platform: CentOS 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-11-16 15:38:05  
Categories: Estuary Documents  
Remark:
---

#安装Ansible
	一台控制主机：192.168.0.202
	三台管理主机：
	    192.168.0.200
	    192.168.0.201
	    192.168.0.203
	安装要求：
	    控制服务器：需要安装 Python2.6/2.7
	    管理服务器：需要安装 Python2.4 以上版本，若低于 Python2.5 需要安装 pythonsimplejson; 若启用了 selinux，则需要安装 libselinux-python。
	本次安装基于CentOS7系统环境、Python2.7.5、root用户。
	1、yum安装（推荐）
		yum install epel-release
		yum install ansible
#配置

	控制主机：用于控制其它机器的主机
	管理主机：被控制主机管理的主机
	1、配置管理主机
	vim /etc/ansible/hosts
	在hosts文件中添加管理主机的IP地址列表：
	[hoperun]
	192.168.0.200
	192.168.0.201
	192.168.0.203
	配置管理主机
	2、配置控制主机SSH密钥
	   2.1、在控制主机中生成ssh密钥对
		ssh-keygen -t rsa
		一路回车即可在$HOME/.ssh目录下生成id_rsa和id_rsa.put私钥和公钥两个文件。
		注： 如果在生成密钥的时候设置了密码，ansible每次执行命令的时候，都会提示输入密钥密码，可通过下面的命令记住密码。
		ssh-agent bsh
		ssh-add ~/.ssh/id_rsa

	   2.2、将公钥拷贝到管理主机中.ssh/authorized_keys文件中，实现免密码登录远程管理主机
		ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.0.200
		ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.0.201
		ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.0.203
		注：ssh-copy-id命令会自动将id_rsa.pub文件的内容追加到远程主机root用户下.ssh/authorized_keys文件中。
	   2.3、ansible配置(可以不需要配置)
		vim /etc/ansible/ansible.cfg
		1> 禁用每次执行ansbile命令检查ssh key host
		host_key_checking = False
		2> 开启日志记录
		log_path = /var/log/ansible.log
		3> ansible连接加速配置
		[accelerate]
		#accelerate_port = 5099
		accelerate_port = 10000 
		#accelerate_timeout = 30
		#accelerate_connect_timeout = 5.0

		# If set to yes, accelerate_multi_key will allow multiple
		# private keys to be uploaded to it, though each user must
		# have access to the system via SSH to add a new key. The default
		# is "no".
		accelerate_multi_key = yes

#测试
	测试下在三台管理机器批量执行一个ping命令
	 ansible all -m ping
	结果如下：
	ansible all -m ping运行结果
	[root@localhost ansible]# ansible all -m ping
	192.168.0.200 | SUCCESS => {
	    "changed": false, 
	    "ping": "pong"
	}
	192.168.0.201 | SUCCESS => {
	    "changed": false, 
	    "ping": "pong"
	}
	192.168.0.202 | SUCCESS => {
	    "changed": false, 
	    "ping": "pong"
	}
  	查看远程主机基本信息：
	ansible all -m setup
	远程文件符号链接创建：
	ansible all -m file -a "src=/etc/resolv.conf dest=/tmp/resolv.conf state=link"
	远程文件信息查看：
	ansible all -m command -a "ls –al /tmp/resolv.conf"
	远程文件符号删除：
	ansible all -m file -a "path=/tmp/resolv.conf state=absent"
	将本地文件“/etc/ansible/ansible.cfg”复制到远程服务器：
	ansible all -m copy -a "src=/etc/ansible/ansible.cfg dest=/tmp/ansible.cfg owner=root group=root mode=0644"
	在远程机器上执行命令：
	ansible all -m command -a "uptime"
     	
