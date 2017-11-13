---
javapackages-tools.md - 测试v500对javapackages-tools的兼容性及其基本功能
Hardware platform: D05，D03
Software Platform: CentOS
Author: Liu Caili <meili760628705@163.com>  
Date: 2017-11-09 17:00
Categories: Estuary Documents  
Remark:
---
- **Dependency:**
    添加estuary软件包源
       sudo wget -O /etc/yum.repos.d/estuary.repo https://raw.githubusercontent.com/open-estuary/distro-repo/master/estuaryftp.repo     
       sudo chmod +r /etc/yum.repos.d/estuary.repo               
       sudo rpm --import ftp://repoftp:repopushez7411@117.78.41.188/releases/ESTUARY-GPG-KEY               
       yum clean dbcache

- **Source code:**
    no

- **Build:**
    no

- **Test:**
    	1.安装javapackages-tools
       	yum install -y javapackages-tools
     
      	2.功能测试步骤暂未开发
      	   补充：此为java包封装的宏和脚本
      	
     	3.卸载javapackages-tools
       yum remove -y javapackages-tools
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail