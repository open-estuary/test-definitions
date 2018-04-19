---
e-commerce.md -e-commerce是电商平台的搭建和基本服务测试，目前不涉及场景测试，只是数据流通性测试
Hardware platform: D05 D03
Software Platform: CentOS
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>
Date: 2017-11-24 14:38:05
Categories: Estuary Documents
Remark:
---

# 环境
本套电商应用部署在4台ARM64服务器上，具体配置如下所示：

设备编号|IP地址
-|-
140| 192.168.1.190
141|192.168.1.254
143|192.168.1.233
142|192.168.1.218

- 190的服务如下：

服务名|端口号|cpu
-|-|-
nginx|9000|0-3
中断|无|4
logstash/pcp|无|5
eureka|8761|6
twemproxy|22112-22114|12-14
mycat-1|9066|10-11

- 254的服务如下

服务名|端口号|cpu
-|-|-
order|8000|0-3
中断|无|4
logstash/pcp|无|5
search|8002|6-8
cart|8001|9-10
redis|7011-7013|11-13 （端口号的后两位跟cpu保持一直）
mycat-2|9066|14-15

- 218的服务如下

服务名|端口号|cpu
-|-|-
zuul|5555|0-3
中断|无|4
logstash/pcp|无|5
mysql|3306|6-8
zipkin|无|9-10

- 233的服务如下

服务名|端口号|cpu
-|-|-
solr cloud|8983|0-3
中断|无|4
logstash/pcp|无|5
mysql|3306|6-8
pcp web/vector|无|9-10
zookeeper|无|11-15

# 存储访问配置
- mycat配置

微服务|端口|mycat配置：端口|mysql：端口|twemproxy：端口|redis配置：端口
-|-|-|-|-|-
order|8000|192.168.1.190：9066|192.168.1.218：3306|192.168.1.190：22112|192.168.1.254：7011
cart|8001|192.168.1.254：9067|192.168.1.233：3306|192.168.1.190：22113|192.168.1.254：7012

- solr配置

微服务|端口|solr配置：端口|twemproxy：端口|redis配置：端口
-|-|-|-|-
search|8002|192.168.1.233：8983|192.168.1.190：22114|192.168.1.254：7013

# 创建用户和用户组
## 在每一台服务器上都需要创建用户和组
    groupadd estuaryapp
    useradd -g estuaryapp estuaryapp
    passwd estuaryapp
    输入：estuaryapp

## 修改用户权限增加root权限
修改`/etc/sudoers`配置文件，找到下面一行，在root下面添加一行，如下所示：

	## Allow root to run any commands anywhere
	root    ALL=(ALL)     ALL
	+ estuaryapp   ALL=(ALL)     ALL

## 给每个estuaryapp用户生成操作机上的密钥,我是在190机器上操作
    3.1在操作机上生成密钥
        $ssh-keygen -t rsa
        一路回车即可在$HOME/.ssh目录下生成id_rsa和id_rsa.put私钥和公钥两个文件。
    3.2将公钥拷贝到管理主机中.ssh/authorized_keys文件中，实现免密码登录远程管理主机
        ssh-copy-id -i ~/.ssh/id_rsa.pub estuaryapp@192.168.1.233
        ssh-copy-id -i ~/.ssh/id_rsa.pub estuaryapp@192.168.1.254
        ssh-copy-id -i ~/.ssh/id_rsa.pub estuaryapp@192.168.1.218
        ssh-copy-id -i ~/.ssh/id_rsa.pub estuaryapp@192.168.1.190

# 下载软件仓库
    git clone https://github.com/open-estuary/appbenchmark.git
    cd appbenchmark/apps/e-commerce-solutions/e-commerce-springcloud-microservice/examples/mini_provision_with_4nodes/

## 修改`ansible/group_vars/TestServer02`配置，新增

    + mycat_cart_ip: 192.168.1.254
    + mycat_order_ip: 192.168.1.190
    + redis_cart_ip: 192.168.1.190
    + redis_order_ip: 192.168.1.190
    + redis_search_ip: 192.168.1.190

# 安装ansible工具
    yum install ansible

# 运行 setup.sh
    ./setup.sh

# 关闭nginx服务上的selinux
    setenforce 0

# 最后还需要建立数据库
## 登录order服务器
    0.登录数据库：mysql -uroot -h127.0.0.1 -P3306
    1.建立数据库，如cart数据库： create database `e-commerce-order`;
    2.查看创建结果： show databases;
    3.使用库：use e-commerce-order;
    4.建立表:CREATE TABLE r_ec_sku(nSKUID varchar(8),nSPUID varchar(8) NOT NULL,nPrice varchar(10) NOT NULL,nInventory VARCHAR(50),sSize VARCHAR(100),PRIMARY KEY (nSKUID))ENGINE=InnoDB DEFAULT CHARSET=utf8;
    CREATE TABLE r_ec_userinfo(sFirstName varchar(8),sLoginName varchar(20) NOT NULL,sPayPassword varchar(20) NOT NULL,nUserID VARCHAR(20),sLoginPassword VARCHAR(20),sLastName varchar(20),PRIMARY KEY (sFirstName))ENGINE=InnoDB DEFAULT CHARSET=utf8;
     CREATE TABLE r_ec_userdeliveryaddress(nAddressID varchar(8),sAddress varchar(100) NOT NULL,nUserID VARCHAR(20),sPhoneNo VARCHAR(20),PRIMARY KEY (nAddressID))ENGINE=InnoDB DEFAULT CHARSET=utf8;

    5.查看表：show tables;
    6.插入数据：
    插入商品数据：insert into r_ec_sku (nSKUID,nSPUID,nPrice,nInventory,sSize) values('1','1','7632','3000','i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机');
                insert into r_ec_sku (nSKUID,nSPUID,nPrice,nInventory,sSize) values('2','1','8743','3000','i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机');
    插入用户数据：replace into r_ec_userinfo (sFirstName,sLoginName,sPayPassword,nUserID,sLoginPassword,sLastName) values('糜','j0Bxu1PWO3m%&V#X1Jkg','66312480','1','bh7gt73spa','莹玉');
    插入用户地址数据：replace into r_ec_userdeliveryaddress (nAddressID,sAddress,nUserID,sPhoneNo) values('1','上海市浦东新区诜畏路 10号 窝小区 83号楼 9单元 396室','164488','13666941328');
    7. 验证
    select * from r_ec_sku;
    select * from r_ec_userinfo;
    select * from r_ec_userdeliveryaddress;
   
 备注：order必须至少3个表格r_ec_sku、r_ec_userinfo和r_ec_userdeliveryaddress
 
## 登录cart服务器
    注意：cart必须至少要两个表格r_ec_sku和r_ec_userinfo，
    0.登录数据库：mysql -uroot -h127.0.0.1 -P3306
    1.建立数据库，如cart数据库： create database `e-commerce-cart`;
    2.查看创建结果： show databases;
    3.使用库：use e-commerce-cart;
    4.创建表：CREATE TABLE r_ec_sku(nSKUID varchar(8),nSPUID varchar(8) NOT NULL,nPrice varchar(10) NOT NULL,nInventory VARCHAR(50),sSize VARCHAR(100),PRIMARY KEY (nSKUID))ENGINE=InnoDB DEFAULT CHARSET=utf8;
     CREATE TABLE r_ec_userinfo(sFirstName varchar(8),sLoginName varchar(20) NOT NULL,sPayPassword varchar(20) NOT NULL,nUserID VARCHAR(20),sLoginPassword VARCHAR(20),sLastName varchar(20),PRIMARY KEY (sFirstName))ENGINE=InnoDB DEFAULT CHARSET=utf8;
    5.查看表格：show tables;
    6.插入数据：
        插入商品数据：
        insert into r_ec_sku (nSKUID,nSPUID,nPrice,nInventory,sSize) values('1','1','7632','3000','i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机');
        insert into r_ec_sku (nSKUID,nSPUID,nPrice,nInventory,sSize) values('2','1','8743','3000','i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机');
        replace into r_ec_userinfo (sFirstName,sLoginName,sPayPassword,nUserID,sLoginPassword,sLastName) values('糜','j0Bxu1PWO3m%&V#X1Jkg','66312480','1','bh7gt73spa','莹玉');
    7. 验证
    select * from r_ec_sku;
    select * from r_ec_userinfo;

    
# 别急还要先关闭防火墙：
关闭所有服务器的防火墙
systemctl disable firewalld
service firewalld stop

如果数据库无法直连还需要设置远程连接。

    mysql -uroot -h127.0.0.1 -P3306
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION;
    FLUSH PRIVILEGES

# 可以开始测试
直接访问服务节点测试相关服务
## order微服务测试
1. createOrder
 curl -X POST http://192.168.1.254:8000 -H "Content-Type: application/json" -d '{"addressDTO": {"naddressid":1},"deliveryDTO":{"naddressid":1808782,"ndeliveryprice":100,"sexpresscompany":"EMS"},"orderskudtoList":[{"discount":0,"originPrice":7632,"price":7632,"quantity":5,"skuId":1},{"discount":0,"originPrice":8743,"price":8743,"quantity":7,"skuId":2}],"scustomermark":"everything is good!","totalQuantity":0,"userId":1}'

result:
 {"userId":1,"status":"SUCCESS","info":null,"error":null}

2. getOrder by user
  curl http://192.168.1.254:8000/1
result：
  {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":null,"ncreatetime":null}

3. getOrder by ID
  curl http://192.168.1.254:8000/1/2
  {"orderId":2,"userId":1,"parentOrderid":0,"paymentMethod":0,"discount":0.00,"totalQuantity":12,"totalPrice":99461.00,"cstatus":0,"screatetime":null,"supdatetime":null,"scompletedtime":1511320977000,"scustomermark":"everything is good!","sordercode":"1-order-2017-11-22-11:22:57","sshopcode":null,"sordertype":null,"dpaymenttime":null,"sordersource":null,"addressDTO":{"naddressid":1808782,"nuserid":164488,"sfirstname":"姓","slastname":"名","saddress":"上海市浦东新区诜畏路 10号 窝小区 83号楼 9单元 396室","scity":"上海","sprovince":"上海","scountry":"中国","semail":"example@huawei.com","sphoneno":"13666941328","sdistrict":null,"dcreatetime":null,"dupdatetime":null,"szipcode":null},"deliveryDTO":{"ndeliveryid":2,"sexpresscompany":"EMS","ndeliveryprice":100.00,"cstatus":0,"dcreatetime":null,"dupdatetime":null,"douttime":null,"naddressid":1808782,"sconsignee":"","sdeliverycomment":"","sdeliverycode":"1-delivery-2017-11-22-11:22:57"},"orderskudtoList":[{"orderId":2,"skuId":1,"quantity":5,"originPrice":7632.00,"discount":0.00,"currency":"RMB","price":7632.00},{"orderId":2,"skuId":2,"quantity":7,"originPrice":8743.00,"discount":0.00,"currency":"RMB","price":8743.00}]}

目前不能定位userID和orderID

4. 删除order
  curl -X DELETE http://192.168.1.254:8000/1/1
result:
  {"userId":1,"status":"SUCCESS","info":null,"error":null}
5.CreateCart
  curl -X POST http://192.168.1.254:8001 -H "Content-Type: application/json" -d '{"currency":"RMB","discount":0,"quantity":0,"skudtoList":[{"discount":0,"displayPrice":7632,"quantity":10,"skuId":1,"spuId":1}],"userId":1}'
result：
  {"userId":1,"status":"SUCCESS","info":null,"error":null}

## cart微服务测试
1. GetCartByCartId
    curl http://192.168.1.254:8001/1/1
result:
 {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":1511338037000,"ncreatetime":1511338037000}

2. GetCartByUser
   curl http://192.168.1.254:8001/1
result:
 {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":1511338037000,"ncreatetime":1511338037000}

3. DeleteCart
   curl -X DELETE http://192.168.1.254:8001/1/1
result:
   {"userId":1,"status":"SUCCESS","info":null,"error":null}
   无购物车时返回状态跟有购物车时一样

4. AddOrUpdateProduct
   curl -X POST http://192.168.1.254:8001/1/1/skus/3 -H "Content-Type: application/json" -d '{"currency":"RMB","discount":0,"quantity":0,"skudtoList":[{"discount":0,"displayPrice":2564,"quantity":20}]}'
result：
   {"userId":1,"status":"SUCCESS","info":null,"error":null}

## search微服务测试
1. SearchProduct （有问题）
  curl http://192.168.1.254:8002/?query=*:*\&page_size=10\&page_num=1\&sort=
通过访问zuul测试相关服务

2. createOrder 正常
curl -X POST http://192.168.1.218:5555/v1/order -H "Content-Type: application/json" -d '{"addressDTO": {"naddressid":1},"deliveryDTO":{"naddressid":1808782,"ndeliveryprice":100,"sexpresscompany":"EMS"},"orderskudtoList":[{"discount":0,"originPrice":7632,"price":7632,"quantity":5,"skuId":1},{"discount":0,"originPrice":8743,"price":8743,"quantity":7,"skuId":2}],"scustomermark":"everything is good!","totalQuantity":0,"userId":1}'

result:
 {"userId":1,"status":"SUCCESS","info":null,"error":null}

3. getOrder by user 正常
  curl http://192.168.1.218:5555/v1/order/1
result：
  {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":null,"ncreatetime":null}

4. getOrder by ID （正常）
  curl http://192.168.1.218:5555/v1/order/1/2
  {"orderId":2,"userId":1,"parentOrderid":0,"paymentMethod":0,"discount":0.00,"totalQuantity":12,"totalPrice":99461.00,"cstatus":0,"screatetime":null,"supdatetime":null,"scompletedtime":1511320977000,"scustomermark":"everything is good!","sordercode":"1-order-2017-11-22-11:22:57","sshopcode":null,"sordertype":null,"dpaymenttime":null,"sordersource":null,"addressDTO":{"naddressid":1808782,"nuserid":164488,"sfirstname":"姓","slastname":"名","saddress":"上海市浦东新区诜畏路 10号 窝小区 83号楼 9单元 396室","scity":"上海","sprovince":"上海","scountry":"中国","semail":"example@huawei.com","sphoneno":"13666941328","sdistrict":null,"dcreatetime":null,"dupdatetime":null,"szipcode":null},"deliveryDTO":{"ndeliveryid":2,"sexpresscompany":"EMS","ndeliveryprice":100.00,"cstatus":0,"dcreatetime":null,"dupdatetime":null,"douttime":null,"naddressid":1808782,"sconsignee":"","sdeliverycomment":"","sdeliverycode":"1-delivery-2017-11-22-11:22:57"},"orderskudtoList":[{"orderId":2,"skuId":1,"quantity":5,"originPrice":7632.00,"discount":0.00,"currency":"RMB","price":7632.00},{"orderId":2,"skuId":2,"quantity":7,"originPrice":8743.00,"discount":0.00,"currency":"RMB","price":8743.00}]}

目前不能定位userID和orderID

4.删除order
  curl -X DELETE http://192.168.1.218:5555/v1/order/1/1
result:
  {"userId":1,"status":"SUCCESS","info":null,"error":null}
5.CreateCart
  curl -X POST http://192.168.1.218:5555/v1/cart -H "Content-Type: application/json" -d '{"currency":"RMB","discount":0,"quantity":0,"skudtoList":[{"discount":0,"displayPrice":8743,"quantity":10,"skuId":2,"spuId":1},{"discount":0,"displayPrice":7632,"quantity":10,"skuId":1,"spuId":1}],"userId":1}'
result：
  {"userId":1,"status":"SUCCESS","info":null,"error":null}

6.GetCartByCartId
    curl http://192.168.1.218:5555/v1/cart/1/2
result:
 {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":1511338037000,"ncreatetime":1511338037000}

7.GetCartByUser
   curl http://192.168.1.218:5555/v1/cart/1
result:
 {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":1511338037000,"ncreatetime":1511338037000}
8.DeleteCart
   curl -X DELETE http://192.168.1.218:5555/v1/cart/1/1
result:
   {"userId":1,"status":"SUCCESS","info":null,"error":null}
   无购物车时返回状态跟有购物车时一样

9.AddOrUpdateProduct
   curl -X POST http://192.168.1.218:5555/v1/cart/1/1/skus/1 -H "Content-Type: application/json" -d '{"currency":"RMB","discount":0,"quantity":0,"skudtoList":[{"discount":0,"displayPrice":7632,"quantity":10,"skuId":1,"spuId":1}],"userId":1}'
result：
   {"userId":1,"status":"SUCCESS","info":null,"error":null}
10.SearchProduct
  curl http://192.168.1.218:5555/v1/search?query=*:*\&page_size=10\&page_num=1\&sort=

## nginx服务测试
1. createOrder 
 curl -X POST http://192.168.1.190:9000/v1/order -H "Content-Type: application/json" -d '{"addressDTO":{"naddressid":1},"deliveryDTO":{"naddressid":1808782,"ndeliveryprice":100,"sexpresscompany":"EMS"},"orderskudtoList":[{"discount":0,"originPrice":7632,"price":7632,"quantity":5,"skuId":1},{"discount":0,"originPrice":8743,"price":8743,"quantity":7,"skuId":2}],"scustomermark":"everything is good!","totalQuantity":0,"userId":1}'

result:
 {"userId":1,"status":"SUCCESS","info":null,"error":null}

2. getOrder by user
  curl http://192.168.1.190:9000/v1/order/1
result：
  {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":null,"ncreatetime":null}

3. getOrder by ID
  curl http://192.168.1.190:9000/v1/order/1/2
  {"orderId":2,"userId":1,"parentOrderid":0,"paymentMethod":0,"discount":0.00,"totalQuantity":12,"totalPrice":99461.00,"cstatus":0,"screatetime":null,"supdatetime":null,"scompletedtime":1511320977000,"scustomermark":"everything is good!","sordercode":"1-order-2017-11-22-11:22:57","sshopcode":null,"sordertype":null,"dpaymenttime":null,"sordersource":null,"addressDTO":{"naddressid":1808782,"nuserid":164488,"sfirstname":"姓","slastname":"名","saddress":"上海市浦东新区诜畏路 10号 窝小区 83号楼 9单元 396室","scity":"上海","sprovince":"上海","scountry":"中国","semail":"example@huawei.com","sphoneno":"13666941328","sdistrict":null,"dcreatetime":null,"dupdatetime":null,"szipcode":null},"deliveryDTO":{"ndeliveryid":2,"sexpresscompany":"EMS","ndeliveryprice":100.00,"cstatus":0,"dcreatetime":null,"dupdatetime":null,"douttime":null,"naddressid":1808782,"sconsignee":"","sdeliverycomment":"","sdeliverycode":"1-delivery-2017-11-22-11:22:57"},"orderskudtoList":[{"orderId":2,"skuId":1,"quantity":5,"originPrice":7632.00,"discount":0.00,"currency":"RMB","price":7632.00},{"orderId":2,"skuId":2,"quantity":7,"originPrice":8743.00,"discount":0.00,"currency":"RMB","price":8743.00}]}

目前不能定位userID和orderID

4. 删除order
  curl -X DELETE http://192.168.1.190:9000/v1/order/1/1
result:
  {"userId":1,"status":"SUCCESS","info":null,"error":null}

5. CreateCart
curl -X POST http://192.168.1.190:9000/v1/cart -H "Content-Type: application/json" -d '{"currency":"RMB","discount":0,"quantity":0,"skudtoList":[{"discount":0,"displayPrice":8743,"quantity":10,"skuId":2,"spuId":1},{"discount":0,"displayPrice":7632,"quantity":10,"skuId":1,"spuId":1}],"userId":1}'
result：
  {"userId":1,"status":"SUCCESS","info":null,"error":null}

6. GetCartByCartId
    curl http://192.168.1.190:9000/v1/cart/1/2
result:
 {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":1511338037000,"ncreatetime":1511338037000}

7. GetCartByUser
   curl http://192.168.1.190:9000/v1/cart/1
result:
 {"nshoppingcartid":1,"userId":1,"discount":0,"price":163750,"quantity":20,"currency":"RMB","skudtoList":[{"skuId":1,"spuId":1,"color":"白色","size":"i7 6700K七代7700K/GTX1060独显游戏diy电脑组装兼容台式主机整机","price":7632.00,"displayPrice":7632.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319752000,"dupdatetime":1511319752000,"quantity":10},{"skuId":2,"spuId":1,"color":"白色","size":"顺丰I7 7700K P600图形工作站设计台式电脑主机建模3D渲染制图","price":8743.00,"displayPrice":8743.00,"currency":"RMB","discount":0.00,"dcreatetime":1511319762000,"dupdatetime":1511319762000,"quantity":10}],"supdatetime":1511338037000,"ncreatetime":1511338037000}

8. DeleteCart
curl -X DELETE http://192.168.1.190:9000/v1/cart/1/1
result:
   {"userId":1,"status":"SUCCESS","info":null,"error":null}
   无购物车时返回状态跟有购物车时一样

9. AddOrUpdateProduct
curl -X POST http://192.168.1.190:9000/v1/cart/1/1/skus/1 -H "Content-Type: application/json" -d '{"currency":"RMB","discount":0,"quantity":0,"skudtoList":[{"discount":0,"displayPrice":7632,"quantity":10,"skuId":1,"spuId":1}],"userId":1}'
result：
   {"userId":1,"status":"SUCCESS","info":null,"error":null}

10. SearchProduct（有问题）
  curl http://192.168.1.190:9000/v1/search?query=*:*\&page_size=10\&page_num=1\&sort=
