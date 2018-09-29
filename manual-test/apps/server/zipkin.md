---
zipkin-spingboot.md - zipkin 是一个开放源代码分布式的跟踪系统,本用例是基于CentOS搭建基于 ZIPKIN 的数据追踪系统
Hardware platform: D05 D03
Software Platform: CentOS 
Author: mahongxin <hongxin_228@163.com>
Date: 2018-1-19 15:38:05
Categories: Estuary Documents
Remark:
---

# Test
```bash
    =======================配置 Java 环境==================================
    (1)安装　jdk 
        yum install java-1.8.0-openjdk.aarch64

    =======================安装Zipkin======================================
    (2)新建目录:  mkdir -p /data/release/zipkin && cd "$_"
    
    (3)下载Zipkin: wget -O zipkin.jar 'https://search.maven.org/remote_content?g=io.zipkin.java&a=zipkin-server&v=LATEST&c=exec'

    (4)启动Zipkin: java -jar zipkin.jar
    
    (5)Zipkin 默认监听9411端口,查看单板ip ,使用浏览器访问http://ip:9411,可以看到Zipkin自带的图形化界面

    ==================配置MySQL作为数据持久化方案=============================
    (6)安装 MySQL
	yum install mysql-community-server -y

    (7)启动 MySQL 服务(mysql默认密码是root,如果没有需设置密码)
	systemctl start mysqld.service

    (8)初始化Zipkin数据库
	/data/release/zipkin 目录下创建 zipkin_init.sql(参考文件放在107 web服务器上)

    (9)登录MySQL
	mysql -u root --password='root'

    (10)创建Zipkin数据库
	create database zipkin;

    (11)切换数据库
	use zipkin;

    (12)初始化表及索引
	1)source /data/release/zipkin/zipkin_init.sql
	2)执行"show tables;", 如果看到zipkin_annotations, zipkin_dependencies, zipkin_spans 三张数据表，说明初始化成功了
	3)退出MySQL

    (13)启动Zipkin
	1)cd /data/release/zipkin
	2)STORAGE_TYPE=mysql MYSQL_HOST=localhost MYSQL_TCP_PORT=3306 MYSQL_DB=zipkin MYSQL_USER=root MYSQL_PASS='root' nohup java -jar zipkin.jar &

===================创建具有数据上报能力的Demo===============================
    (14)搭建 NodeJS 环境
	1)curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
	2)yum install nodejs -y

    (15)创建Demo目录
	mkdir -p /data/release/service_a && cd "$_"

    (16)使用 NPM 安装相关依赖
	1)在 /data/release/service_a 目录下创建并编辑 package.json(参考文件放在107 web服务器上)
	2)npm install

    (17)创建并编辑 app.js
	1)在 /data/release/service_a 目录下创建 app.js(参考文件放在107 web服务器上)
	2)启动服务: node app.js

    (18)该服务监听3000端口,使用浏览器访问http://ip:3000,看到“hello world” 的文本字样说明服务已经正常工作。
	
    

```
