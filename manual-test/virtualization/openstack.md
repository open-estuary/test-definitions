---
Openstack.md - 测试v500对openstack的兼容性及其基本功能
Hardware platform: D06，D05，D03
Software Platform: Debian
Author: Wang Sisii <wang_sisi@hoperun.com>  
Date: 2017-07-25 
Categories: Estuary Documents  
Remark:
---

- **Dependency:**
    - 测试环境搭建
       	- 准备1台服务器
       	- 自带两张网卡  
           eth0：192.168.1.254
           eth1：192.168.1.32
         
- **Test:**
    - 检查服务器网卡是否可用（eth0、eth1网卡状态为up）：
         - ip a
    - 设置sudo命令无需输入密码并配置如下：
         - sudo visudo
          USERNAME ALL=(ALL) NOPASSWD: ALL 
　　
　　- 安装软件包：    
　　    - apt-get install python-pip python-dev libffi-dev gcc libssl-dev python-selinux git
    
    - 升级pip、setuptools、idna
        - pip install -U pip
        - pip install -U setuptools
        - pip install -U idna
    
    - 安装ansible2.4.0
        - pip install ansible==2.4.0

    - 下载kolla-ansible和 kolla
         - git clone https://github.com/openstack/kolla-ansible
         - git clone https://github.com/openstack/kolla

    - 安装kolla-ansible和 kolla：
        - pip install kolla/
        - pip install kolla-ansible/

    - 拷贝kolla-ansible/etc/kolla到/etc/kolla/   
        - cp -r kolla-ansible/etc/kolla /etc/kolla/
        
　　- 配置/etc/kolla/globals.yml如下：
　　     kolla_base_distro: "debian"
　　　　   kolla_install_type: "source"
　　　　   openstack_release: "rocky-53"
　　　　   kolla_internal_vip_address: "192.168.1.254"       //该ip为一个未被使用的ip
　　　　   docker_registry: "registry.docker-cn.com"
　　　　   docker_namespace: "linaro"
　　　　   network_interface: "eth0"
　　　　   neutron_external_interface: "eth1"
　　　　   enable_fluentd: "no"
　　
    - 拷贝kolla-ansible/ansible/inventory/*到当前目录配置如下：
        - cp kolla-ansible/ansible/inventory/* .

　　- 生成密码文件，将会为/etc/kolla/passwords.yml的配置项填充随机生成的密码
　　   - kolla-genpwd
　　
    - 将所有组件安装在一个节点：
      - ./kolla-ansible/tools/kolla-ansible -i all-in-one bootstrap-servers
　　
　　- 添加docker用户组并把当前用户加入到该组中。
      - sudo groupadd docker || true
      - sudo usermod -aG docker $USER

    - 重新登录当前用户   
   
    - 预检查配置
      - ./kolla-ansible/tools/kolla-ansible -i all-in-one prechecks

    - 拉取官方镜像
      - ./kolla-ansible/tools/kolla-ansible -i all-in-one pull
   
　　- 开始部署
　　  - ./kolla-ansible/tools/kolla-ansible -i all-in-one deploy
　　  - ./kolla-ansible/tools/kolla-ansible -i all-in-one post-deploy

    - 安装openstack客户端
      - pip install python-openstackclient  
　　
　　- 设置admin环境变量
　　   - . /etc/kolla/admin-openrc.sh
    
   - 配置init-runonce文件
      - vi ./kolla-ansible/tools/init-runonce
       EXT_NET_CIDR='192.168.1.0/24'
       EXT_NET_RANGE='start=192.168.1.80,end=192.168.1.84'    //未使用ip
       EXT_NET_GATEWAY='192.168.1.1                       //sudo route -n可以查询到
　　
   - 初始化网络
      - ./kolla-ansible/tools/init-runonce
　　
　　- 访问openstack环境，web登录Dashboard
　　   - http://192.168.1.254/dashboard/auth/login
　　   用户名：admin，密码通过env命令查询
        
- **Result:**
     检查能否登录Dashboard，若可以，则pass；若不行，则fail。
          
　　

    