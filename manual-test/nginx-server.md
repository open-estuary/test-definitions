---
snappy.md - snappy test md
Hardware platform: D05，D03
Software Platform: CentOS
Author: mahongxin <hongxin_228@163.com>  
Date: 2017-11-21 15:31
Categories: Estuary Documents  
Remark:
---
- **Dependency:**
    
    １.添加estuary软件包源(可根据实际情况是否要进行此操作)
       sudo wget -O /etc/yum.repos.d/estuary.repo https://raw.githubusercontent.com/open-estuary/distro-repo/master/estuaryftp.repo     
       sudo chmod +r /etc/yum.repos.d/estuary.repo               
       sudo rpm --import ftp://repoftp:repopushez7411@117.78.41.188/releases/ESTUARY-GPG-KEY               
       yum clean dbcache

- **Source code:**
    no

- **Build:**
    no

- **Test:**
    1.安装snappy安装包
       yum install snappy.aarch64 -y
    2.新建一个测试文件a.cpp
     touch a.cpp && chmod 777 a.cpp
    3.编辑测试文件
    #include "snappy.h"
　　#include <string>
　　#include <iostream>
　　int main(){
	std::string s = "ddsandslkanlksdlfj;lkjsld;lfsjldkf;reioweor;dlskjfls";
	std::string d;
	snappy::Compress(s.data(),s.size(),&d);
	std::cout<<d<<std::endl;
	std::cout<<s.size()<<""<<d.size()<<std::endl;
	return 0;
}
    ４．编译a.cpp文件
    　　libtool --mode=compile g++ -c a.cpp
	
   5.　编译链接snappy库
       libtool --mode=link g++ -o test a.lo libsnappy.la 
       
   6.执行生成的可执行文件test
       ./test
     
　　7．查看结果
   　　查看是否压缩成功
     
  ８．结束测试
       kill -9 进程
       
   ９.卸载snappy
       yum remove -y snappy
       
     
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
