---
elasticsearch.md - 测试v500对elasticsearch的兼容性及其基本功能
Hardware platform: D05，D03
Software Platform: CentOS
Author: Liu Caili <meili760628705@163.com>  
Date: 2017-11-09 15:31
Categories: Estuary Documents  
Remark:
---
- **Dependency:**
    1.已安装jdk
       java -version
    2.添加estuary软件包源
       sudo wget -O /etc/yum.repos.d/estuary.repo https://raw.githubusercontent.com/open-estuary/distro-repo/master/estuaryftp.repo     
       sudo chmod +r /etc/yum.repos.d/estuary.repo               
       sudo rpm --import ftp://repoftp:repopushez7411@117.78.41.188/releases/ESTUARY-GPG-KEY               
       yum clean dbcache

- **Source code:**
    no

- **Build:**
    no

- **Test:**
    1.安装elasticsearch
       yum install -y elasticsearch
       
    2.启动elasticsearch
       cd /usr/share/elasticsearch
       ./elasticsearch -d
       
    3.查看elasticsearch是否安装成功
       jps
       
    4.查看elasticsearch是否启动成功
       curl -X GET http://localhost:9200
       
    5.命令行添加一个索引
       curl -X PUT 'http://localhost:9200/dept/employee/32' -d '{"employee":"emp32"}'
       
     6.查看索引是否添加成功
       curl -X GET http://localhost:9200
       
     7.关闭elasticsearch
       kill -9 进程号
      或者
       curl -X POST http://localhost:9200/_cluster/nodes/_shutdown
       
     8.卸载elasticsearch
       yum remove -y elasticsearch
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail