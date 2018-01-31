---
api-api-gateway.md - api-gateway 是一个网关服务
Hardware platform: D05 D03
Software Platform: CentOS
Author: mahongxin <hongxin_228@163.com>
Date: 2018-1-25 15:38:05
Categories: Estuary Documents
Remark:
---
# Test
```bash
    (1)安装 api-gatway eureka　jdk

       yum install micro-service-discovery.aarch64

       yum install java-1.8.0-openjdk.aarch64

       yum install maven-archiver.noarch

       yum install micro-service-api.aarch64

    (2)查找到eureka安装的路径

　　　rpm -ql micro-service-discovery.aarch64
      rpm -ql micro-service-api.aarch64

    (3)启动eureka

        cd /etc/micro-services/discovery/

        java -jar eureka-server-0.0.1-SNAPSHOT.jar &

    (4)打开浏览器访问eureka

       http://ip:8761可以看到eureka的页面代表启动成功

    (5)启动api-gatway

       cd /etc/micro-services/api-gateway/
       java -jar api-gateway-1.0.0.jar&

　  (6)再次重新访问eureka
　　　 查看eureka的页面上Application项已经加载了api-gateway
       API-GATEWAY-SERVICE	n/a (1)	(1)	UP (1) - k8s-node-2:api-gateway-service:5555
　　　　　　　
　  (7)编写eureka测试服务
    　[root@k8s-node-2 eureka]# tree eureka-client/
eureka-client/
├── pom.xml
├── src
│   └── main
│       ├── java
│       │   └── com
│       │       └── spring
│       │           └── EurekaClientApplication.java
│       └── resources
│           └── application.yml


　　　
　  (8)编译测试服务

　 　cd eureka-client
     mvn clean package

    (9)启动测试服务

　　　cd eureka-client/target
      java -jar eureka-client-0.0.1-SNAPSHOT.jar &

　  (10)再次打开浏览器访问eureka

     　查看eureka服务页面上加载了测试服务
　　 　CLOUD-CLIENT	n/a (1)	(1)	UP (1) - k8s-node-2:cloud-client:7070
　　　
    (11)使用zuul来访问测试服务
　　　　http://ip:5555/cloud-client页面出现hello表示路由成

    (12)卸载安装包
　      yum remove micro-service-zipkin.aarch64
        yum remove java-1.8.0-openjdk.aarch64
        yum remove maven-archiver.noarch
        yum remove micro-service-api.aarch64
```
