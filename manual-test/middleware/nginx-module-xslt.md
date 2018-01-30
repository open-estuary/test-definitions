---
nginx-module-njs.md - nginxjavascript
Hardware platform: D05，D03
Software Platform: CentOS
Author: mahongxin <hongxin_228@163.com>
Date: 2017-11-24 15:31
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

    4.安装nginx-module-xslt模块

      yum install nginx-module-xslt.aarch64 -y

    5.在/etc/nginx/nginx.conf配置文件里面增加如下配置

      load_module modules/ngx_http_xslt_filter_module.so

    6.进入到解压后的nginx-1.5.9进行编译

      cd nginx-1.5.9

      ./configure --with-http_xslt_module

      make

      make install

    7.安装依赖的库

      yum install libxml2 libxslt -y

    8.查看nginx是否可以正常启动

      /usr/local/nginx/sbin/nginx -t

      /usr/local/nginx/sbin/nginx

      cur http://loacalhost/index.html看到welcom nginx test的文字代表nginx安装启动成功

    9.修改nginx.conf配置文件</etc/nginx/nginx.conf>如下所示
      vi nginx.conf

      events {
      worker_connections  1024;
     }


      http {
      include       mime.types;
      default_type  application/octet-stream;
      types_hash_max_size 2048;#添加此行
      types_hash_bucket_size 32;#添加此行

      location / {
        xml_entities    /site/dtd/entities.dtd;
        xslt_stylesheet /site/xslt/one.xslt param=value;
        xslt_stylesheet /site/xslt/two.xslt;
      }


    10.开始进行测试

      /usr/sbin/nginx -c

      /usr/sbin/nginx

    11.查看单板的ip地址

      ip addr

    12.查看结果

      在浏览器输入ip地址http://192.168.1.xxx/
      如果显示：xml文件转换为xhml表示成功

    13.结束测试

      kill -9 进程

    14.卸载nginx

      yum remove -y nginx-module-xslt.aarch64 -y


- **Result:**
-
    测试上述步骤是否全部通过，若是，则pass；若不是，则fail
