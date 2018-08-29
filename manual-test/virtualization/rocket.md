---
rocket.md - 测试安全容器rocket的基本功能
Hardware platform: D05，D03
Software Platform: Ubuntu
Author: ma hongxin <hongxin_228@163.com>
Date: 2018-7-30 14:36
Categories: Estuary Documents
Remark:
---
- **Test:**
    1.安装rocket以及所要用的其他包

       　apt-get install -y rkt　go-lang acbuild

    2.获取帮助信息

         rkt --help

    3.下载镜像

      　 rkt fetch --insecure-options=image docker://ubuntu
　　
    4.查看下载的镜像
    

　　　　　　rkt image list


    5.编译出go程序的可执行文件(由于下载的镜像不能正常使用因此自己制作一个可用的镜像）
　　　　　
　　
         cat hello.go

         package main

         import "fmt"

         func main(){

         fmt.Println("hello,world")

       　}

       　go build hello.go

　　6.制作镜像文件

　     　acbuild begin

         acbuild set-name examle.com/hello

         acbuild copy hello /bin/hello

         acbuild set-exec /bin/hello

         acbuild label add arch amd64

         acbuild label add os linux

         acbuild write hello-0.0.1-linux-amd64.aci

         acbuild end
　　　
    7.使用rkt启动镜像

　　　　 　rkt --insecure-options=image run hello-0.0.1-linux-amd64.aci

    8.查看启动的镜像

　　　 　　rkt list

    9.查看启动的镜像的状态

　　　 　　rkt status UUID:如果是running状态表示启动成功

    10.停止容器

　　　 　　rkt stop example.com/hello

    11.删除镜像

　　　 　　rkt rm image-name


- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
