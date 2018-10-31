---
nginx-module-image-perl.md - 一个网站基本都是静态，极少的地方是动态显示
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

      yum install perl-devel perl-ExtUtils-Embed -y

    4.进入到解压后的nginx-1.5.9进行编译

      cd nginx-1.5.9

      ./configure --prefix=/usr/local/nginx --with-http_perl_module --with-ld-opt="-WL,-E"

      make

      make install

    5.查看nginx是否可以正常启动

      /usr/local/nginx/sbin/nginx -t

      /usr/local/nginx/sbin/nginx

      cur http://loacalhost/index.html看到welcom nginx test的文字代表nginx安装启动成功

    6.修改nginx.conf配置文件</usr/local/nginx/conf/nginx.conf>如下所示

      vi nginx.conf

      events {

       worker_connections  1024;
     }


      http {
      include       mime.types;
      default_type  application/octet-stream;
      types_hash_max_size 2048;#添加此行
      types_hash_bucket_size 32;#添加此行
      perl_modules  perl/lib;####添加此行
      perl_require  test.pm;#####添加此行

      #access_log  logs/access.log  main;

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
      location /user/ {
        perl pkg_name::process;          #/usr/local/nginx/conf/html/user user下面的所有请求都交给tes.pm处理
        }

      #error_page  404              /404.html

    7.新建user测试文件夹并在文件夹里面放一个test.pm文件

      mkdir /usr/local/nginx/html/user/

      mkdir /usr/local/nginx/perl/lib/test.pm

    8.编写test.pm文件如下

      package pkg_name;
      use Time::Local;
      use nginx;
      sub process {
      my $r = shift;

      $r->send_http_header('text/html;charset=utf-8');
      my @arr = split('/',$r->uri);
      my $username = @arr[2];
      if (!$username || ($username eq "")){
      $username = "Anonymous";
     }
      $r->print('hello,you name is :'.$username.'');
      $r->rflush();
      return;
    }
    1;
    _END_


    9.开始进行perl测试

       /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf &

    10.查看单板的ip地址

       ip addr

    11.查看结果

       在浏览器输入ip地址http://192.168.1.xxx/user/xxx 

     　如果显示：hello,you name is xxx表示测试通过

    12.结束测试
       kill -9 进程

    13.卸载nginx

       yum remove -y nginx

- **Result:**
-
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail,可以通过对输入的名字不同来显示不同的结果
