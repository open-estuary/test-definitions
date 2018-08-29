
---
dnsmasq.md - dnsmasq是一个小巧且方便地用于配置DNS和DHCP的工具，作为域名解析服务器，dnsmasq可以通过缓存DNS请求来提高对访问过的网址的连接速度。作为DHCP服务器，dnsmasq可以用于为局域网电脑分配内网ip地址和提供路由。
 
Hardware platform: D05　D06 
Software Platform: centos,ubuntu,debian，fedora,opensuse  
Author: Ding yu <1136920311@qq.com>  
Date: 2018-08-16 13:50:05  
Categories: Estuary Documents  
Remark:
---

一、Dnsmasq安装
    centos|fedora: $ yum install dnsmasq bind-utils
    ubuntu|debian: $ apt-get install dnsmasq dnsutils
    opensuse     : $ zypper install dnsmasq dnsutils

二、修改配置文件
    vi /etc/dnsmasq.conf
    1、resolv-file=/etc/resolv.dnsmasq.conf    #表示dnsmasq 会从这个指定的文件中寻找上游dns服务器
    2、strict-order                            #取消前面的注释，表示严格按照resolv-file文件中的顺序从上到下进行DNS解析，直到第一个解析成功为止
    3、listen-address=127.0.0.1,192.168.1.212  #定义dnsmasq监听的地址，默认是监控本机的所有网卡上。
    4、echo 'nameserver 127.0.0.1' > /etc/resolv.conf
    5、cp /etc/resolv.conf /etc/resolv.dnsmasq.conf
    6、echo 'nameserver 8.8.8.8' > /etc/resolv.dnsmasq.conf
    7、cp /etc/hosts /etc/dnsmasq.hosts
    8、echo 'addn-hosts=/etc/dnsmasq.hosts' >> /etc/dnsmasq.conf
三、Dnsmasq启动
    1、$ service dnsmasq start
    2、执行命令：$ netstat -tunlp|grep 53 可以查看Dnsmasq是不是已经正常启动：
四、测试
    1、dig www.freehao123.com，第一次是没有缓存，时间为200多毫秒
    2、第二次再次测试，因为已经有了缓存，所以查询时间已经变成了0.
五、Dnsmasq使用
    1、修改hosts实现dns劫持(host解析)
	预置条件：dnsmasq启动
	步骤：
	a、进入/etc/dnsmasq.hosts，加入"192.168.1.212 freehao123.com"	
	b、执行"ping  freehao123.com "
	结果：网络可以ping通
	
    2、指定域名解析到特定的IP上(address泛解析)
	预置条件：dnsmasq启动
	步骤：
	a、进入/etc/dnsmasq.conf文件，加入"address=/aaa.bbb.com/192.168.1.212"(正向解析)
	b、进入/etc/dnsmasq.conf文件，加入"ptr-record=212.1.168.192.in-addr.arpa,aaa.bbb.com"(反向解析)
	c、执行"dig freehao123.com"测试正向解析
	d、执行"dig -x 192.168.1.212"测试反向解析
	结果：结果可以看见域名解析出来的IP地址是"192.168.1.212"，IP地址解析出来的域名是"aaa.bbb.com"
     3、管理控制内网DNS
	预置条件：
	准备两台机器
	serverA 192.168.1.6
	clientB 192.168.1.7
	步骤：
 	a、在服务器A上安装dnsmasq,按照前面的步骤配置好dnsmasq
	b、修改A的配置文件,添加域名解析记录
	      $ echo "192.168.1.6 aaa.bbb.com" >> /etc/hosts
	c、重启dnsmasq
	d、配置客户端B，修改配置文件，填入dnsmasq所在地址
	      $ echo "nameserver 192.168.1.6" /etc/resolv.conf
	e、使用ping命令测试内网DNS "ping -c 5 aaa.bbb.com"
	f、测试
	结果：网络可以ping通
       
	


 
