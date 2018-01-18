---
build.md - 测试单板上下载工程代码、编译工程
Hardware platform: D05
Software Platform: CentOS，Ubuntu
Author: Liu Caili <meili760628705@163.com>  
Date: 2017-11-16 14:12:05
Categories: Estuary Documents  
Remark:
---

- **Dependency:**
    - 已在D05单板上部署好Ubuntu或CentOS系统
    - 自动化实现过程可见：
         - https://github.com/qinshulei/ci-scripts/tree/master/build-scripts

- **Source code:**
    https://github.com/open-estuary/estuary.git

- **Build:**
    no

- **Test:**
       
       1.进入D05上Centos系统下载编译
       
       2.进入D05上Ubuntu系统下载编译
       
       3.将ESTUARY-GPG-SECURE-KEY文件拷入到编译机器/root目录下(私钥需找管理员获取)
       
       4.导入密钥
           $ gpg --import ESTUARY-GPG-SECURE-KEY
           
       5.检查密钥是否导入成功
           $ gpg --list-secret-keys
           
       6.下载代码仓库
           $ git clone https://github.com/open-estuary/estuary.git
           
       7.校验代码下载的完整性
           $ echo $?
           
       8.下载源代码中断后的恢复下载
       
       9.下载指定分支的源代码
           $ git clone https://github.com/open-estuary/estuary.git -b branch-name
           
       10.配置estuarycfg.json中选择platform所有项、distro所有项，使用./build.sh进行编译，测试是否成功
           $ vim estuarycfg.json
           将platform所有项、distro所有项的install状态都改为yes
           ./build.sh
           
       11.配置estuarycfg.json中选择platform任意一项、distro任意多项，使用./build.sh进行编译，测试是否成功
           $ vim estuarycfg.json
           将platform任意一项、distro所有项的install状态都改为yes，不编译的项的install状态改为no
           ./build.sh
           
       12.配置estuarycfg.json中选择platform任意多项、distro任意一项，使用./build.sh进行编译，测试是否成功
           $ vim estuarycfg.json
           将platform任意多项、distro任意一项的install状态都改为yes，不编译的项的install状态改为no
           ./build.sh
           
       13.配置estuarycfg.json中选择platform任意一项、distro任意一项，使用./build.sh进行编译，测试是否成功
           $ vim estuarycfg.json
           将platform任意一项、distro任意一项的install状态都改为yes，不编译的项的install状态改为no
           ./build.sh
           
       14.配置estuarycfg.json中选择platform零项、distro任意一项或多项，使用./build.sh进行编译，测试是否成功
            $ vim estuarycfg.json
           将platform所有项的install状态改为no，distro任意一项或多项的install状态都改为yes，不编译的项的install状态改为no
           ./build.sh
           
       15.配置estuarycfg.json中选择platform任意一项或多项、distro零项，使用./build.sh进行编译，测试是否成功
       	   $ vim estuarycfg.json
           将platform任意一项或多项的install状态改为yes，不编译的项的install状态改为no，distro所有项的install状态都改为no
           ./build.sh
           
       16.配置estuarycfg.json中选择platform零项、distro零项，使用./build.sh进行编译，测试是否成功
            $ vim estuarycfg.json
           将platform所有项、distro所有项的install状态都改为no
           ./build.sh
           
       17.配置estuarycfg.json中repo源填错或者不填，使用./build.sh进行编译，测试是否成功
       	    $ vim estuarycfg.json
           将DEBIAN_ESTUARY_REPO改为一个错误url或者不填
           ./build.sh
           
       18.使用./build.sh clean，检查能否清除先前编译生成的文件
       
       19.中断编译再重新编译
       
       20.对比工程代码编译前后的commit号是否正确
           $ git show v5.0-rc0|grep commit
	   $ git log -n 1
	   
       21.回滚与更新测试
        

- **Result:**
        测试D05单板下centos和ubuntu两个平台下是否都可以成功编译

