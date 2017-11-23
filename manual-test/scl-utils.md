---
scl-utils.md - scl-utils test md
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
    1.安装scl-utils安装包
       yum install scl-utils.aarch64 -y
    2.是否可以正常浏览可用版本
      yum--disablerepo="*"--enablerepo="scl"list available
    3.是否可以正常安装一个集合
       yum install python33
    ４．安装python33后检查python的默认版本是否没有改变
    　　$ python --version
　　　　　Python2.７.５
	
   5.　是否可以正常启动一个会话
       scl enable python33 bash
     
　　６．查看结果
   　测试新的python是否可用
     
 ７．结束测试
       kill -9 进程
       
  ８.卸载snappy
       yum remove -y scl-utils
       
     
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
