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
    #setup模块
  	1.查看远程主机基本信息：
	ansible all -m setup

    #ping模块
    1.检查指定节点机器是否还能连通
    ansible 192.168.0.200 -m ping

	#file模块
	1.远程文件符号链接创建：
	ansible all -m file -a "src=/etc/resolv.conf dest=/tmp/resolv.conf state=link"
	2.远程文件符号删除：
	ansible all -m file -a "path=/tmp/resolv.conf state=absent"
    3.修改远程文件属性
    ansible all -m file -a "dest=/tmp/t.sh mode=755 owner=root group=root"
    
	#copy模块
	1.将本地文件“/etc/ansible/ansible.cfg”复制到远程服务器：
	ansible all -m copy -a "src=/etc/ansible/ansible.cfg dest=/tmp/ansible.cfg owner=root group=root mode=0644"
    
	#commond模块
	1.在远程机器上执行命令：
	ansible all -m command -a "uptime"
	2.远程文件信息查看
    # ansible storm_cluster -m command -a "ls -al /tmp/ansible.cfg"
    
    #shell模块
    1.远程执行脚本
    # ansible storm_cluster -m shell -a "/tmp/rocketzhang_test.sh"
    
    #cron模块
    1.在指定节点上定义一个计划任务，每隔3分钟到主控端更新一次时间
    ansible all -m cron -a 'name="custom job" minute=*/3 hour=* day=* month=* weekday=* job="/usr/sbin/ntpdate 192.168.0.200"'
    
    #group模块
    1.在所有节点上创建一个组名为nolinux，gid为2014的组
    ansible all -m group -a 'gid=2014 name=nolinux'
    
    #user模块
    1.在指定节点上创建一个用户名为nolinux，组为nolinux的用户
    ansible 192.168.0.200 -m user -a 'name=nolinux groups=nolinux state=present'
    2.删除指定用户
    ansible 192.168.0.200 -m user -a 'name=nolinux  state=present removes=yes'

    #yum模块
    1.在指定节点上安装 apache 服务
    ansible all -m yum -a "state=present name=httpd"
    
    #raw模块
    1.在192.168.0.200节点上运行hostname命令
    ansible 10.1.1.113 -m raw-a 'hostname|tee'

    #get_url模块
    1.将http://192.168.0.200/favicon.ico文件下载到指定节点的/tmp目录下
    ansible 192.168.0.200 -m get_url -a 'url=http://192.168.0.201/favicon.ico dest=/tmp
    
    #synchronize模块
    1.将主控方/root/a目录推送到指定节点的/tmp目录下
    ansible 192.168.0.200 -m synchronize -a 'src=/root/a dest=/tmp/ compress=yes'
    
    #service 
    1.检查服务状态为running
    [root@ansibleserver ansible]#ansible nagiosserver -m service -a "name=nagios state=running"

    SSH password:

    192.168.0.200 | success >> {

    "changed": false,

    "name": "nagios",

    "state": "started"

    }
    2.将服务停止
    [root@ansibleserver ansible]#ansible nagiosserver -m service -a "name=nagios state=stopped"
    SSH password:
    192.168.0.200 | success >> {
    
        "changed": true,
    
        "name": "nagios",
    
        "state": "stopped"
    
    }
    3.将服务重新启动
    [root@ansibleserver ansible]#ansible nagiosserver -m service -a "name=nagios state=restarted"

    SSH password:
    
    192.168.0.200 | success >> {
    
        "changed": true,
    
        "name": "nagios",
    
        "state": "started"
    
    }
    4.将服务重新加载
    [root@ansibleserver ansible]#ansible nagiosserver -m service -a "name=nagios state=reloaded"

    SSH password:
    
    192.168.0.200 | success >> {
    
        "changed": true,
    
        "name": "nagios",
    
        "state": "started"
    
    }
    5.当不存在服务的时候
    [root@ansibleserver ansible]#ansible -i hosts kel -m service -a "name=nagios state=stopped"
    
    SSH password:
    
    192.168.0.200 | FAILED >> {
    
        "failed": true,
    
        "msg": "cannot find 'service' binary or init script for service,  possible typo in service name?, aborting"
    
    }
    6.将服务设置为开机启动
    [root@ansibleserver ansible]# ansible nagiosserver -m service -a "name=nagios enabled=no"

    SSH password:
    
    192.168.0.200 | success >> {
    
        "changed": true,
    
        "enabled": false,
    
        "name": "nagios"
    
    }
    
     
    
    [root@ansibleserver ansible]# ansible nagiosserver -m service -a "name=nagios enabled=yes"
    
    SSH password:
    
    192.168.0.200 | success >> {
    
        "changed": true,
    
        "enabled": true,
    
        "name": "nagios"
    
    }
    