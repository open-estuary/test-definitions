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
          
	  ip a

    - 设置sudo命令无需输入密码并配置如下：
       	- sudo visudo  
           USERNAME ALL=(ALL) NOPASSWD: ALL
　　
    - 安装软件包：
           
	   sudo apt-get install python-pip python-dev libffi-dev gcc libssl-dev python-selinux git
    
    - 升级pip、setuptools、idna
        - pip install -U pip
        - sudo pip install -U setuptools
        - sudo pip install -U idna
    
    - 安装ansible2.4.0
          
	  Sudo pip install ansible==2.4.0

    - 下载kolla-ansible和 kolla
         - git clone https://github.com/openstack/kolla-ansible
         - git clone https://github.com/openstack/kolla

    - 安装kolla-ansible和 kolla：
        - sudo pip install kolla/
        - sudo pip install kolla-ansible/

    - 拷贝kolla-ansible/etc/kolla到/etc/kolla/   
          
	  sudo cp -r kolla-ansible/etc/kolla /etc/kolla/
        
    - 配置/etc/kolla/globals.yml(vi前需要加sudo)如下:
        
          kolla_base_distro: "debian”

          kolla_install_type: "source"
 
          openstack_release: "rocky-53"
  
          kolla_internal_vip_address: "192.168.1.254"       //该ip为一个未被使用的ip
 
          docker_namespace: "linaro”

          network_interface: "eth0"
        
          neutron_external_interface: "eth1"

          enable_fluentd: "no"
　　
　　
   - 拷贝kolla-ansible/ansible/inventory/*到当前目录配置如下：
          
	  cp kolla-ansible/ansible/inventory/* .

   - 生成密码文件，为/etc/kolla/passwords.yml的配置项填充随机生成的密码
          
	  sudo kolla-genpwd
　　
   - 将所有组件安装在一个节点：
          
	  sudo ./kolla-ansible/tools/kolla-ansible -i all-in-one bootstrap-servers
　　
   - 添加docker用户组并把当前用户加入到该组中。
        - sudo groupadd docker || true
        - sudo usermod -aG docker $USER

   - 重新登录当前用户   
   
   - 预检查配置
          
	  sudo ./kolla-ansible/tools/kolla-ansible -i all-in-one prechecks

   - 拉取官方镜像
          
	  ./kolla-ansible/tools/kolla-ansible -i all-in-one pull
   
   - 开始部署
        - sudo ./kolla-ansible/tools/kolla-ansible -i all-in-one deploy
        - ./kolla-ansible/tools/kolla-ansible -i all-in-one post-deploy

   - 安装openstack客户端
          
	  sudo pip install python-openstackclient  
　　
   - 设置admin环境变量
          
	  . /etc/kolla/admin-openrc.sh
    
   - 配置init-runonce文件
         - vi ./kolla-ansible/tools/init-runonce

          EXT_NET_CIDR='192.168.1.0/24'
          EXT_NET_RANGE='start=192.168.1.80,end=192.168.1.84'    //未使用ip
          EXT_NET_GATEWAY='192.168.1.1                       //sudo route -n可以查询到
　　
   - 初始化网络

           ./kolla-ansible/tools/init-runonce
　　
   - 访问openstack环境，web登录Dashboard

          http://192.168.1.254/auth/login
	   用户名：admin
	   
	   密码通过env命令查询



   - 服务器上命令测试

     查看keystone的用户: openstack user list

     查看keystone endpoint: openstack endpoint list

     查看keystone的role: openstack role list

     查看keystone 服务：openstack service list

     查看keystone租户：openstack project list

     创建域: openstack domain create --description "Test Domain" test

     创建项目（租户）: openstack project create --domain test --description "Test Project" projectTest

     创建用户: openstack user create --domain test --password-prompt admin1

     创建角色: openstack role create Admin1

     为某项目中的某用户指定角色: openstack role add  --project projectTest --user admin1 Admin1

     为组件创建服务实体: openstack service create  --name serviceTest --description "service test" type

     删除服务: openstack service delete serviceTest

     删除用户的角色: openstack role remove  --project projectTest --user admin1 Admin1 

     删除角色: openstack role delete Admin1

     删除用户: openstack user delete admin1

     删除项目: openstack project delete projectTest

     删除域: openstack domain set --disable  test;openstack domain delete test

- **Result:**
          
     检查能否登录Dashboard，若可以，则部署pass；若不行，则部署fail。检查命令是否执行成功，若成功，则pass；若不行，则fail。
          
　　

    
