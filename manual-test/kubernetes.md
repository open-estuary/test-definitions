---
kubernetes.md - 测试v500对kubernetes的兼容性及其基本功能
Hardware platform: D05
Software Platform: CentOS
Author: Liu Caili <meili760628705@163.com>  
Date: 2017-11-10 14:12
Categories: Estuary Documents  
Remark:
---
- **Dependency:**
    1.添加estuary软件包源
       sudo wget -O /etc/yum.repos.d/estuary.repo https://raw.githubusercontent.com/open-estuary/distro-repo/master/estuaryftp.repo     
       sudo chmod +r /etc/yum.repos.d/estuary.repo               
       sudo rpm --import ftp://repoftp:repopushez7411@117.78.41.188/releases/ESTUARY-GPG-KEY               
       yum clean dbcache
    2.按节点数与规格来进行部署 Kubernetes 集群，操作系统均采用CentOS：
       172.16.35.12 master
       172.16.35.10 node1
       172.16.35.11 node2
       注：master 为主要控制节点也是部署节点，node 为应用程序工作节点
              所有节点彼此网络互通，所有操作全部用root使用者进行

- **Source code:**
    no

- **Build:**
    no

- **Test:**
    1.所有节点需要设定/etc/host解析到所有主机
       	...
	172.16.35.10 node1
	172.16.35.11 node2
	172.16.35.12 master1
    2.安装SSH SERVER
	在所有的节点上都安装SSH server服务:
		apt-get install openssh-server
	修改/etc/ssh/sshd_config中:
      		PermitRootLogin=yes
	重启ssh:systemctl restart sshd
	
     3.设置使用SSH免密码登录
	master生成SSH: keysssh-keygen
	拷贝这个key到所有的节点:ssh-copy-id 节点名
	
      4.关闭防火墙与SELinux
      	$ systemctl stop firewalld && systemctl disable firewalld
	$ setenforce 0
	$ vim /etc/selinux/config
	SELINUX=disabled
	
      5.所有节点安装Docker
      	 curl -fsSL "https://get.docker.com/" | sh
      	 systemctl enable docker && systemctl start docker
         编辑/lib/systemd/system/docker.service，在ExecStart=..上面加入：
         	ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
         完成后，重新启动 docker 服务：
         	$ systemctl daemon-reload && systemctl restart docker
       
       6.所有节点需要设定/etc/sysctl.d/k8s.conf的系统参数
       	  $ cat <<EOF > /etc/sysctl.d/k8s.conf
		net.ipv4.ip_forward = 1
		net.bridge.bridge-nf-call-ip6tables = 1
		net.bridge.bridge-nf-call-iptables = 1
		EOF

	   $ sysctl -p /etc/sysctl.d/k8s.conf
	   
	7.在master1需要安装CFSSL工具，这将会用来建立 TLS certificates
	   $ export CFSSL_URL="https://pkg.cfssl.org/R1.2"
	   $ wget "${CFSSL_URL}/cfssl_linux-amd64" -O /usr/local/bin/cfssl
	   $ wget "${CFSSL_URL}/cfssljson_linux-amd64" -O /usr/local/bin/cfssljson
	   $ chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
	   
	 8.
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail