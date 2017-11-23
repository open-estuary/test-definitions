---
nginx-module-njs.md - nginxjavascript
Hardware platform: D05，D03
Software Platform: CentOS
Author: mahongxin <hongxin_228@163.com>  
Date: 2017-11-15 15:31
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
- 
     1.下载nginx安装包

       wget http://nginx.org/download/nginx-1.5.9.tar.gz


     2.解压nginx压缩包

     tar -zxvf nginx-1.5.9.tar.gz

     3.安装编译时候需要的安装包

    　根据提示去安装缺少的安装包

    ４．获取nginxscript模块

    　　yum install mercurial hg clone http://hg.nginx.org/njs

     5.进入到解压后的nginx-1.5.9进行编译

       cd nginx-1.5.9
       ./configure --add-module=../njs/nginx --perfix=/usr/local
       make
       make install
       
     6.查看nginx是否可以正常启动
 
       /usr/local/nginx/sbin/nginx -t
       /usr/local/nginx/sbin/nginx
       cur http://loacalhost/index.html看到welcom nginx test的文字代表nginx安装启动成功
       
     7.修改nginx.conf配置文件</usr/local/nginx/conf/nginx.conf>如下所示
      vi nginx.conf
      
      events {
     worker_connections  1024;
     }


    http {
    include       mime.types;
    default_type  application/octet-stream;
    types_hash_max_size 2048;#添加此行
    types_hash_bucket_size 32;#添加此行
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #     '"$http_user_agent" "$http_x_forwarded_for"';
    #######添加如下配置########
    js_set $msg"
      var str = 'hello,imwed';
     ";
    ##########################
    #access_log  logs/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    #keepalive_timeout  0;
    keepalive_timeout  65;
    #gzip  on;
    ＃配置images
              location / {
            root   html;
            index  index.html index.htm;
        }
        
     #error_page  404              /404.html

	###############添加如下配置#######
	server {
         ...
         location /{
      return 200 $msg;
     }
     }
      }   
       
     8.开始进行图片测试
     /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf &
     
    9．查看单板的ip地址

     ip addr
     
    10．查看结果

     在浏览器输入ip地址http://192.168.1.xxx/imweb 
     如果显示：hello,imweb表示测试通过
     
    11．配置js_run

     修改nginx.conf配置文件</usr/local/nginx/conf/nginx.conf>如下所示
    server {
    location /imwebteam {
     js_run "
    var res;
    res = $r.response;
    res.status = 200;
    res.send('hello,imweb!');
    res.finish();
    ";
    }
 
    }

    12．查看结果

    在浏览器输入ip地址http://192.168.1.xxx/imweb 
    如果显示：hello,imweb表示测试通过
   
    13．结束测试

       kill -9 进程
       
    1４.卸载nginx

       yum remove -y nginx
       
     
  
- **Result:**
- 
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
