---
eureka-eureka.md - eureka 是一个注册服务
Hardware platform: D05 D03
Software Platform: CentOS
Author: mahongxin <hongxin_228@163.com>
Date: 2018-1-23 15:38:05
Categories: Estuary Documents
Remark:
---
# Test
```bash
    (1)安装eureka　jdk

       yum install micro-service-discovery.aarch64

       yum install java-1.8.0-openjdk.aarch64

       yum install maven-archiver.noarch

    (2)查找到eureka安装的路径

　　 　rpm -ql micro-service-discovery.aarch64

    (3)启动eureka

        cd /etc/micro-services/discovery/

        java -jar eureka-server-0.0.1-SNAPSHOT.jar &

　  (4)查看单板ip地址

　　　 ip addr

　  (5)打开浏览器访问eureka

       http://ip:8761

    (6)编写项目eureka-service和eureka-client

      eureka-client/
    ├── pom.xml
    ├── src
     └── main
    │       ├── java
│       │   └── com
│       │       └── spring
│       │           └── EurekaClientApplication.java
│       └── resources
│          └── application.yml

      eureka-service
      ├── pom.xml
├── src
│   └── main
│       ├── java
│       │   └── com
│       │       └── spring
│       │           └── EurekaServiceApplication.java
│       └── resources
│           └── application.yml

　　(7)编译源程序

      编译客户端:进入到eureka-client/下的pom.xml文件所在的位置,执行命令mvn clean package
      编译服务端: eureka-service编译方法同上

    (8)启动

　　　编译成功后会出现一个target文件夹

    　cd target

      java -jar eureka-client-0.0.1-SNAPSHOT.jar

    　java -jar eureka-service-0.0.1-SNAPSHOT.jar

　　(9)打开浏览器访问eureka http://ip:8761

     查看eureka上Application注册了cloud-client
     CLOUD-CLIENT	n/a (1)	(1)	UP (1) - k8s-node-2:cloud-client:7070

    (10)卸载安装包
　     yum remove micro-service-zipkin.aarch64
       yum remove java-1.8.0-openjdk.aarch64
       yum remove maven-archiver.noarch
```
