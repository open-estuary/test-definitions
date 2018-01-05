---
iotables.md - iptables 是linux上常用的防火墙软件
Hardware platform: D05 D03
Software Platform: CentOS Ubuntu Debian
Author: mahongxin <hongxin_228@163.com>
Date: 2018-1-5 15:38:05
Categories: Estuary Documents
Remark:
---
#命令说明
```
 命令选项输入顺序:iptables -t 表名 <-A/I/D/R> 规则链名 [规则号] <-i/o 网卡名> -p 协议名 <-s 源IP/源子网> --sport 源端口 <-d 目标IP/目标子网> --dport 目标端口 -j 动作
```
#选项
---
　　　　　　　-t<表>：指定要操纵的表
　　　　　　　-A：向规则链中添加条目
　　　　　　　-D：从规则链中删除条目
　　　　　　　-i：向规则链中插入条目
　　　　　　　-R：替换规则链中的条目
　　　　　　　-L：显示规则链中已有的条目
　　　　　　　-F：清楚规则链中已有的条目
　　　　　　　-Z：清空规则链中的数据包计算器和字节计数器
　　　　　　　-N：创建新的用户自定义规则链
　　　　　　　-P：定义规则链中的默认目标
　　　　　　　-h：显示帮助信息
　　　　　　　-p：指定要匹配的数据包协议类型
　　　　　　　-s：指定要匹配的数据包源ip地址
　　　　　　　-j<目标>：指定要跳转的目标
　　　　　　　-i<网络接口>：指定数据包进入本机的网络接口
　　　　　　　-o<网络接口>：指定数据包要离开本机所使用的网络接口

---
# Test
```bash
    (1)$iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT  允许本地回环接口（即运行本机访问本机)
    (2)$iptables -A INPUT -p tcp --dport 21 -j ACCEPT 允许ftp服务的21端口
    (3)$iptables -A OUTPUT -j ACCEPT  允许所有本机向外的访问
　  (4)$iptables -A INPUT -j reject   禁止其他未允许的规则访问
　  (5)$iptables -I INPUT -s 123.45.6.7 -j DROP 屏蔽单个ip
    (6)iptables -I INPUT -s 123.0.0.0/8 -j DROP 屏蔽整个段即123.0.0.1到123.255.255.254的
　　(7)$iptables -L -n -v 查看已添加的iptables规则
root@ubuntu:~# iptables -L -n -v
Chain INPUT (policy ACCEPT 24 packets, 3285 bytes)
pkts bytes target     prot opt in     out     source                   destination
    0     0 ACCEPT     all  --  *      *       127.0.0.1            127.0.0.1
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:21

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

   (8)$iptables -L -n --line-numbers 将所有iptables以序号标记显示

root@ubuntu:~# iptables -L -n --line-numbers
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    ACCEPT     all  --  127.0.0.1            127.0.0.1
2    ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:21

Chain FORWARD (policy ACCEPT)
num  target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
num  target     prot opt source               destination

  (9)$iptables -D INPUT 8 删除INPUT里序号为8的规则

```
