---
build.md - 测试单板上下载工程代码、编译工程
Hardware platform: D05，D03
Software Platform: CentOS，Ubuntu
Author: Liu Caili <meili760628705@163.com>  
Date: 2017-11-16 14:12:05
Categories: Estuary Documents  
Remark:
---

- **Dependency:**
    已在单板上部署好Ubuntu或CentOS系统

- **Source code:**
    https://github.com/open-estuary/estuary.git

- **Build:**
    no

- **Test:**
       
  第一部分  编译前平台选择方式
       1.用ipmitool工具连接D05，进入centos系统
       2.用ipmitool工具连接D05，进入ubuntu系统
       3.用ssh登录D05上的centos系统
       4.用ssh登录D05上的ubutnu系统
         
       
   第二部分  编译整个工程
       1.将ESTUARY-GPG-SECURE-KEY文件拷入到编译机器/root目录下(私钥需找管理员获取)
       2.导入密钥
           $ gpg --import ESTUARY-GPG-SECURE-KEY
       3.检查密钥是否导入成功
           $ gpg --list-secret-keys
       2.下载代码仓库
           $ git clone https://github.com/open-estuary/estuary.git
       3.校验代码下载的完整性
           $ echo $?
       4.下载源代码人为因素中断后的恢复下载
       5.下载指定分支的源代码
           $ git clone https://github.com/open-estuary/estuary.git -b branch-name
       6.使用vim estuarycfg.json修改配置文件中不同的参数
           $ cd estuary/
           目前支持debian，ubuntu，centos三种，根据编译需要设置estuarycfg.json中distro的install状态为yes或no
       7.使用./build.sh --build_dir=./workspace进行编译
       8.使用./build.sh clean清除先前编译生成的文件
       9.中断编译再重新编译
       10.对比工程代码编译前后的commit号是否正确
           $ git show v5.0-rc0|grep commit
	   $ git log -n 1
       11.回滚与更新测试
        

- **Result:**
        测试centos和ubuntu两个平台下是否都可以成功编译

