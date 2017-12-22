---
deploy.md - 测试发行版的部署
Hardware platform: D05，D03
Software Platform: CentOS，Ubuntu，Debian
Author: Liu Caili <meili760628705@163.com>  
Date: 2017-11-15 11:12:05  
Categories: Estuary Documents  
Remark:
---

- **Dependency:**
    准备编译好的iso和文件系统压缩包

- **Source code:**
    no

- **Build:**
    no

- **Test:**
  第一部分  引导启动
       
       1.网络安装方式
          
          1）PXE安装方式
               - 检查是否已搭建PXE部署系统环境
               - 能否拷贝Image和mini系统文件至PXE的tftp路径下
               - 重启目标单板，进入UEFI，验证能否以PXE方式启动
               - 验证能否进入mini系统
               
          2)  NFS安装方式
               - 解压文件系统至NFS的tftp目录下
               - 配置grub支持NFS
               - 重启目标单板，测试系统能否以NFS方式进入安装菜单
       
          3)  netboot安装方式
               - 解压netboot包至NFS的tftp目录下
               - 配置grub支持netboot
               - 重启目标单板，测试系统能否以netboot方式进入安装菜单
        
       2.本地安装方式
          
          1）登录web 进入BMC 加载mini ISO
                - 打开浏览器登录BMC，找到ISO装载页面，装入mini ISO文件
                - 连接mini ISO文件，配置从光驱启动
                - 重启系统，测试系统能否进入安装menu
                
          2）登录web 进入BMC 加载everything ISO
                - 打开浏览器登录BMC，找到ISO装载页面，装入everything ISO文件
                - 连接everything ISO文件，配置从光驱启动
                - 重启系统，测试系统能否进入安装menu
                
          3）BMC命令加载mini ISO（BMC版本不低于2.40）
               - 强制关机
               - 设置第一次开机启动项为cdrom
               - 拷贝要挂载的mini ISO到NFS根目录上
               - 通过bmc接口挂载mini ISO作为虚拟光驱
               - 进入安装菜单
          
          4）BMC命令加载everything ISO（BMC版本不低于2.40）
               - 强制关机
               - 设置第一次开机启动项为cdrom
               - 拷贝要挂载的everything ISO到NFS根目录上
               - 通过bmc接口挂载everything ISO作为虚拟光驱
               - 进入安装菜单     
  
  第二部分  安装过程
         
         1.测试Installer menu是否正常
            菜单是否可以正常点击，是否逻辑正常
            
         2.设置国家或地区
            选择国家或地区
            
         3.设置语言
            选择国家，再选择哪种语言种类
            
         4.设置时钟
            选择国家或地区，再选择相应城市
            
         5.设置系统镜像源
            选择系统镜像源，或者手动输入
            
         6.设置要安装的软件
            选择安装系统时，需要安装的软件包，如webserver
            
         7.选择网络接口
            选择通网的网络接口，如eth0
            
         8.设置网络接口的配置
            设置该接口是由何种方式来获取ip，如DHCP
            
         9.设置hostname
            
         10.设置需要部署的硬盘
             选择需要部署的硬盘，如sda,sdb
            
         11.设置硬盘占用空间
            选择占用硬盘空间大小，如整块硬盘，还是剩余空间
            
         12.设置root密码
             
         13.设置新用户及其密码
         
         14.等待自动安装，观察是否成功
         
         15.重启系统，检查UEFI是否有新增项，如centos,ubuntu,debian等
         
         16.选择新增项，观察能否正常启动系统
  

- **Result:**
        分别部署centos、ubuntu、debian等系统，测试以上两种启动方式进行安装，是否都可以成功部署

