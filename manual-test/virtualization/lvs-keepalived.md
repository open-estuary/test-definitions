---
lvs-keepalived.md - lvs-keepalived lvs提供IP虚拟服务和负载均衡，keepalived用来对lvs进行健康管理,lvs有三种方案：NAT、DR和Tun，我们只做DR的测试，其它方案请参考https://www.cnblogs.com/liwei0526vip/p/6370103.html
 
Hardware platform: D05 D03  
Software Platform: CentOS 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-11-20 14:38:05  
Categories: Estuary Documents  
Remark:
---
#网络拓扑
至少四台单板，同一局域网内，2台DR，一台主一台备份，2台RS
# Dependency
```
  yum install -y lsof
  yum install -y httpd
  yum install -y ipvsadm
  yum install -y nginx
  yum -y install keepalived

```
#DR配置
```
1.$vi /etc/keepalived/keepalived.conf
    global_defs {
    notification_email {
        acassen@firewall.loc     #设置报警邮件地址，可以设置多个，每行一个。
        failover@firewall.loc    #需开启本机的sendmail服务
        sysadmin@firewall.loc
    }
    notification_email_from Alexandre.Cassen@firewall.loc  #设置邮件的发送地址
    smtp_server 127.0.0.1      #设置smtp server地址
    smtp_connect_timeout 30    #设置连接smtp server的超时时间
    router_id LVS_DEVEL        #表示运行keepalived服务器的一个标识。发邮件时显示在邮件主题的信息
}

vrrp_instance VI_1 {
    state MASTER              #指定keepalived的角色，MASTER表示此主机是主服务器，BACKUP表示此主机是备用服务器
    interface enp0s3     #指定HA监测网络的接口
    virtual_router_id 51      #虚拟路由标识，这个标识是一个数字，同一个vrrp实例使用唯一的标识。即同一vrrp_instance下，MASTER和BACKUP必须是一致的
    priority 100              #定义优先级，数字越大，优先级越高，在同一个vrrp_instance下，MASTER的优先级必须大于BACKUP的优先级
    advert_int 1              #设定MASTER与BACKUP负载均衡器之间同步检查的时间间隔，单位是秒
    authentication {          #设置验证类型和密码
        auth_type PASS        #设置验证类型，主要有PASS和AH两种
        auth_pass 1111        #设置验证密码，在同一个vrrp_instance下，MASTER与BACKUP必须使用相同的密码才能正常通信
    }
    virtual_ipaddress {       #设置虚拟IP地址，可以设置多个虚拟IP地址，每行一个
        192.168.1.160
    }
}

virtual_server 192.168.1.160 80 {  #设置虚拟服务器，需要指定虚拟IP地址和服务端口，IP与端口之间用空格隔开
    delay_loop 6              #设置运行情况检查时间，单位是秒
    lb_algo rr                #设置负载调度算法，这里设置为rr，即轮询算法
    lb_kind DR                #设置LVS实现负载均衡的机制，有NAT、TUN、DR三个模式可选
    nat_mask 255.255.255.0 
    persistence_timeout 0    #会话保持时间，单位是秒。这个选项对动态网页是非常有用的，为集群系统中的session共享提供了一个很好的解决方案。
                              #有了这个会话保持功能，用户的请求会被一直分发到某个服务节点，直到超过这个会话的保持时间。
                              #需要注意的是，这个会话保持时间是最大无响应超时时间，也就是说，用户在操作动态页面时，如果50秒内没有执行任何操作
                              #那么接下来的操作会被分发到另外的节点，但是如果用户一直在操作动态页面，则不受50秒的时间限制
    protocol TCP              #指定转发协议类型，有TCP和UDP两种

    real_server 192.168.1.223 80 { #配置服务节点1，需要指定real server的真实IP地址和端口，IP与端口之间用空格隔开
        weight 1              #配置服务节点的权值，权值大小用数字表示，数字越大，权值越高，设置权值大小可以为不同性能的服务器
                              #分配不同的负载，可以为性能高的服务器设置较高的权值，而为性能较低的服务器设置相对较低的权值，这样才能合理地利用和分配系统资源
        TCP_CHECK {           #realserver的状态检测设置部分，单位是秒
            connect_timeout 3    #表示3秒无响应超时
            nb_get_retry 3       #表示重试次数
            delay_before_retry 3 #表示重试间隔
            connect_port 8066
        } 
    }
    real_server 192.168.1.190 80 {
        weight 1
        TCP_CHECK {
            connect_timeout 3
            nb_get_retry 3
            delay_before_retry 3
            connect_port 8066
        }
    }
}
要注意的地方：

    interface enp0s3：这里的enp0s3是我的网卡名称，想要查看自己网卡名称的话，在/etc/sysconfig/network-scripts/ifcfg-e（敲下TAB）
    persistence_timeout 0：指的是在一定的时间内来自同一IP的连接将会被转发到同一realserver中。而不是严格意义上的轮询。默认为50s，因此在测试负载均衡是否可以正常轮询时，最好先把值设置为0，方便查看
    TCP_CHECK { ：注意TCK_CHECK和 {之间有一个空格，忘记打这个空格的话，可能会出现后面用ipvsadm查看时，某个RS查看不到

2.另外一个台备用服务器上Keepavlied的配置类似，只是把MASTER改为backup，把priority设置为比MASTER低

3.keepalived的2个节点执行如下命令，开启转发功能：

$echo 1 > /proc/sys/net/ipv4/ip_forward


$service keepalived start
```
#RS配置
```
启动脚本如下：
    #!/bin/bash
    #description: Config realserver
    
    VIP=192.168.1.160
    
    /etc/rc.d/init.d/functions
    lsof -i:80 | grep httpd
    echo "rsxxxrsxxx"> /usr/share/httpd/noindex/index.html
    /usr/sbin/apachectl restart
    iptables -F
    
    case "$1" in
    start)
           /sbin/ifconfig lo:0 $VIP netmask 255.255.255.255 broadcast $VIP
           /sbin/route add -host $VIP dev lo:0
           echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
           echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
           echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
           echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
           sysctl -p >/dev/null 2>&1
           echo "RealServer Start OK"
           ;;
    stop)
           /sbin/ifconfig lo:0 down
           /sbin/route del $VIP >/dev/null 2>&1
           echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
           echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
           echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
           echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
           echo "RealServer Stoped"
           ;;
    *)
           echo "Usage: $0 {start|stop}"
           exit 1
    esac
    
    exit 0
$sh realserver.sh start
```
#test 
```
1.测试负载均衡
    curl 192.168.1.160
    
2.测试keepalived的监控检测
    1.停掉RS1的nginx
    $service httpd stop
    停止 httpd：                                               [确定]
    2.在MASTER负载均衡服务器上可以到看VIP映射关系中已经剔除了192.168.1.223
    [root@master ~]ipvsam -L -n
    IP Virtual Server version 1.2.1 (size=4096)   
    Prot LocalAddress:Port Scheduler Flags   
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn   
    TCP  192.168.1.160:80 rr   
      -> 192.168.1.190:80            Route   1      0          0       
    3.重新启动一下RS1
    [root@node1 src]# service httpd start  
    正在启动 httpd：                                           [确定]
    4.再查看一下lvs状态
    [root@master ~]# ipvsadm -L -n  
    IP Virtual Server version 1.2.1 (size=4096)   
    Prot LocalAddress:Port Scheduler Flags   
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn   
    TCP  192.168.1.160:80 rr   
      -> 192.168.1.190:80            Route   1      0          0       
      -> 192.168.1.223:80            Route   1      0          0
    5.关闭主keepalived
     [root@master ~]# service keepalived stop  
     停止 keepalived：                                          [确定]   
     [root@master ~]# ipvsadm -L -n   
     IP Virtual Server version 1.2.1 (size=4096)   
     Prot LocalAddress:Port Scheduler Flags   
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn

    6.查看一下slave状态
     [root@master ~]$ip addr show
     1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN   
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00   
        inet 127.0.0.1/8 scope host lo   
        inet6 ::1/128 scope host   
           valid_lft forever preferred_lft forever   
     2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000   
        link/ether 00:0c:29:f9:e6:26 brd ff:ff:ff:ff:ff:ff   
        inet 192.168.1.190/24 brd 192.168.18.255 scope global eth0   
        inet 192.168.1.223/32 scope global eth0   
        inet6 fe80::20c:29ff:fef9:e626/64 scope link   
           valid_lft forever preferred_lft forever  
    [root@slave ~]# ipvsadm -L -n   
    IP Virtual Server version 1.2.1 (size=4096)   
    Prot LocalAddress:Port Scheduler Flags   
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn   
    TCP  192.168.1.160:80 rr   
      -> 192.168.1.190:80            Route   1      0          0       
      -> 192.168.1.223:80            Route   1      0          0
    7.关闭所有的RS并重新启动一下master与slave的keepalived
    [root@node1 ~]# service httpd stop 
    停止 httpd：                                               [确定]
    [root@node2 ~]# service httpd stop 
    停止 httpd：                                               [确定]
    [root@master ~]# service keepalived restart 
    停止 keepalived：                                          [确定]  
    正在启动 keepalived：                                      [确定]
    [root@slave ~]# service keepalived restart 
    停止 keepalived：                                          [确定]  
    正在启动 keepalived：                                      [确定]
    8.查看一下lvs
    [root@master ~]# ipvsadm -L -n 
    IP Virtual Server version 1.2.1 (size=4096)  
    Prot LocalAddress:Port Scheduler Flags  
      -> RemoteAddress:Port           Forward Weight ActiveConn InActConn  
    TCP  192.168.18.200:80 rr  
      -> 127.0.0.1:80                 Local   1      0          0
 
```
