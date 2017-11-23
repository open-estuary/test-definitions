---
nginx-server.md - nginx-server test md
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
- 
    no

- **Build:**
- 
    no

- **Test:**
- 
     1.下载nginx压缩包

      wget http://nginx.org/download/nginx-1.5.9.tar.gz

     2.解压nginx

     tar zxvf nginx-1.5.9.tar.gz

     3.安装依赖文件

    　　yum install gcc -y
      yum install zlib* -y
      yum install pcre* -y

    ４.编译

    　　./configure
      make
      make install
	 
     5.修改配置文件

       server{
       listen 80;
       server_name test1.com;
       location / {
           return 500;
	   }
	  }

     6.使用curl来测试

       curl -i "test1.com/"

    7．查看结果

    查看是否可以返回５００
     
    ８．结束测试

       kill -9 进程
       
    ９.卸载snappy

       yum remove -y nginx
       
     
  
- **Result:**
- 
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
