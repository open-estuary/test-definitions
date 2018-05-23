---
distro.md - distro是测试发行版启动后一些基本功能，确保单板网络通讯正常，可以正常添加用户，以及开关机等操作  
 
Hardware platform: D05　D03  
Software Platform: CentOS,ubuntu,debian  
Author: Chen Shuangsheng <hongxin_228@163.com>  
Date: 2017-11-9 13:50:05  
Categories: Estuary Documents  
Remark:
---

# 在目标单板部署发行版系统
```
  cat /etc/os-release
  ```

# 查看单板IP
```
ip addr

```
#发行版执行更新命令
```
ubuntu|debian:apt-get update
centos:yum update
```
#发行版执行安装命令
```
ubuntu|debian:apt-get install xxx
centos:yum install xxx
```
#发行版执行卸载命令
```
ubuntu|debian:apt-get remove xxx
centos:yum remove xxx
```
#在发行版上安装git软件
```
ubuntu|debian:apt-get install -y wget git
centos:yum install wget git -y
```
#发行版安装ssh server
```
ubuntu|debian:apt-get install openssh-server
centos:yum install openssh-server
```
#发行版启动ssh 服务
```
ubuntu|debian:service ssh start
centos:systemctl start sshd.service
```
#测试ssh功能
```
ssh username:IP
```
#添加用户
```
useradd
```
#登录新用户
```
su user
```
#测试基本命令
```
ping www.baidu.com
```
#删除用户
```
userdel xxx
```
#长时间运行测试
```
单板长时间运行不重启不断电
```
#关机功能
```
shutdown -h now
```
#重启功能测试
```
reboot
```

