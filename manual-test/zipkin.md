---
zipkin-spingboot.md - zipkin 是一个开放源代码分布式的跟踪系统
Hardware platform: D05 D03
Software Platform: CentOS 
Author: mahongxin <hongxin_228@163.com>
Date: 2018-1-19 15:38:05
Categories: Estuary Documents
Remark:
---

# Test
```bash
    (1)安装zipkin　jdk
        yum install micro-service-zipkin.aarch64 
        yum install java-1.8.0-openjdk.aarch64
　　　　　　　　yum install git -y
        yum install wget -y
    (2)查找到zipkin安装的路径
　　　　　　　　rpm -ql micro-service-zipkin

    (3)启动zipkin
        java -jar micro-service-zipkin.jar &

　  (4)查看单板ip地址
　　　　　　 ip addr

　  (5)打开浏览器访问zipkin 
       http://ip:9411

   (6)下载mircoservice
      克隆仓库：https://github.com/dreamerkr/mircoservice.git

　　(7)安装maven 
       yum install maven.noarch -y
  (8)编译service1,service2,service3,service4
       cd service1
　　　    mvn assembly:assembly
  (9)启动　
       java -jar service1-0.0.1-SNAPSHOT-jar-with-dependencies.jar 
　　(10)打开浏览器访问service1 http://localhost:8001
  (11)查看zipkin加载了service
  (12)卸载安装包
　       yum remove micro-service-zipkin.aarch64 
        yum remove java-1.8.0-openjdk.aarch64
　　　　　　　　yum remove git -y
        yum remove wget -y

```
