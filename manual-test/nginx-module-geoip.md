---
nginx-module-geoip.md - 使用nginx和GeoIp模块来处理不同国家的访问
Hardware platform: D05，D03
Software Platform: CentOS
Author: mahongxin <hongxin_228@163.com>  
Date: 2017-11-16 09:13
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
    1.下载nginx安装包
       wget http://nginx.org/download/nginx-1.5.9.tar.gz
    2.解压nginx压缩包
     tar -zxvf nginx-1.5.9.tar.gz
    3.安装编译时候需要的安装包
    　yum install perl-devel perl-ExtUtils-Embed -y
    4.进入到解压后的nginx-1.5.9进行编译
       cd nginx-1.5.9
       ./configure --without-http_empty_gif_module --with-poll_module\
       --with-htp_stub_status_module --with-http_ssl_module \
       --with-http_geoip_module
       make
       make install
       
   5.查看nginx是否可以正常启动
       /usr/local/nginx/sbin/nginx -t
       /usr/local/nginx/sbin/nginx
       cur http://loacalhost/index.html看到welcom nginx test的文字代表nginx安装启动成功
       
    6.下载MaxMind的GeoIP库（MaxMind提供了免费的ＩＰ地域数据库，这个库文件是二进制的，需要用GeoIP库来读取）
    wget http://geolite.maxmind.com/download/geoip/api/c/GeoIP.tar.gz
    
    7.解压GeoIP
    tar -zxvf GeoIP.tar.gz
    
    ８．编译geoip
    cd GeoIP-1.4.6
    ./configure
    make; make install
    9.刚才安装的库自动安装到 /usr/local/lib 下，所以这个目录需要加到动态链接配置里面以便运行相关程序的时候能自动绑定到这个 GeoIP 库：
      echo '/usr/local/lib' > /etc/ld.so.conf.d/geoip.conf
      ldconfig
    10.下载 IP 数据库
    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
    
    11.解压IP库
    gunzip GeoIP.dat.gz
    
    １２．最后是配置 nginx，在相关地方加上如下的配置就可以了：
 　　　　　vi /etc/nginx/nginx.conf
　　　　　...
　　　　　geoip_country /home/vpsee/GeoIP.dat;
　　　　　fastcgi_param GEOIP_COUNTRY_CODE $geoip_country_code;
　　　　　fastcgi_param GEOIP_COUNTRY_CODE3 $geoip_country_code3;
　　　　　fastcgi_param GEOIP_COUNTRY_NAME $geoip_country_name;
　　　　　...
 　　　　if ($geoip_country_code = CN) {
   　　　 root /home/vpsee/cn/;
 　　　　}
    １３.开始进行测试
     /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf &
     
     １４．查看单板的ip地址
     ip addr
     
　　　　1５．查看结果
   　　在浏览器输入ip地址
     　这样，当来自中国的 IP 访问网站后就自动访问到预定的 /home/vpsee/cn 页面。关于 Nginx + GeoIP 还有很多有用的用法，比如做个简单的 CDN，来自　　　　中国的访问自动解析到国内服务器、来自美国的访问自动转向到美国服务器等。MaxMind 还提供了全球各个城市的 IP 信息，还可以下载城市 IP 数据库来针对　　　　不同城市做处理。
     
     1６．结束测试
       kill -9 进程
       
     1７.卸载nginx
       yum remove -y nginx
       
     
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail
