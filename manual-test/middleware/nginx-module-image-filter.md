---
nginx-module-image-filter.md - 测试nginx的图片模块的基本功能
Hardware platform: D05，D03
Software Platform: CentOS
Author: Liu Caili <hongxin_228@163.com>
Date: 2017-11-10 15:31
Categories: Estuary Documents
Remark:
---
- **Dependency:**

    1.添加estuary软件包源(可根据实际情况是否要进行此操作)

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
    1.下载nginx安装包

       wget http://nginx.org/download/nginx-1.5.9.tar.gz

    2.解压nginx压缩包

       tar -zxvf nginx-1.5.9.tar.gz

    3.安装编译时候需要的安装包

     　yum install gd-devel -y

    4.进入到解压后的nginx-1.5.9进行编译

       cd nginx-1.5.9
       ./configure --prefix=/usr/local/nginx --with-http_image_filter_module
       make
       make install

    5.查看nginx是否可以正常启动

       /usr/local/nginx/sbin/nginx -t
       /usr/local/nginx/sbin/nginx
       cur http://loacalhost/index.html看到welcom nginx test的文字代表nginx安装启动成功

    6.修改nginx.conf配置文件</usr/local/nginx/conf/nginx.conf>
      vi nginx.conf

      events {
      worker_connections  1024;
    }


      http {
      include       mime.types;
      default_type  application/octet-stream;
      types_hash_max_size 2048;#添加此行
      types_hash_bucket_size 32;#添加此行

      sendfile        on;
      #tcp_nopush     on;

      #keepalive_timeout  0;
      keepalive_timeout  65;

      #gzip  on;

      #配置images
              location / {
            root   html;
            index  index.html index.htm;
        }
      location ~* /images {

            image_filter resize 200 200;#表示显示图片的大小为长：200 宽:200
            # image_filter rotate 90;#表示图片旋转90°

       }
        #error_page  404              /404.html

    7.新建images测试文件夹并在文件夹里面放一个jpg格式的文件
       mkdir /usr/local/nginx/html/images/
       cd images/111.jpg#图片可以自己随意添加

    8.开始进行图片测试
        1.先停止nginx  
	2.关闭防火墙
        3./usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf &

    9.查看单板的ip地址
       ip addr

    10.查看结果

      在浏览器输入ip地址http://192.168.1.xxx/images/111.jpg如果能正常显示图片代表成功

    11.结束测试
       kill -9 进程

    12.卸载nginx
       yum remove -y nginx


- **Result:**
-
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail,可以通过对配置文件的修改来对图片进行不同风格的显示，大小变化，旋转等
