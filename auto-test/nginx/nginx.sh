#!/bin/sh -e
set -x
cd ../../utils
    . ./sys_info.sh
cd -
if [ `whoami` != 'root' ] ; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

case $distro in
    "centos")
         wget http://nginx.org/download/nginx-1.5.9.tar.gz
         tar zxvf nginx-1.5.9.tar.gz
         cd nginx-1.5.9
         ./configure --prefix=/usr/local/nginx--pid-path=/var/run/nginx/nginx.pid --lock-path=/var/lock/nginx.lock --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-http_gzip_static_module --http-client-body-temp-path=/var/temp/nginx/client --http-proxy-temp-path=/var/temp/nginx/proxy --http-fastcgi-temp-path=/var/temp/nginx/fastcgi --http-uwsgi-temp-path=/var/temp/nginx/uwsgi --http-scgi-temp-path=/var/temp/nginx/scgi
         make
         make install
         ;;
 esac
cd /usr/local/nginx/conf
cp nginx.conf nginx.conf_bak
sed -i '/default_type/a\    types_hash_max_size 2048;' nginx.conf
sed -i '/types_hash_max_size/a\    types_hash_bucket_size 32;' nginx.conf
/usr/local/nginx/sbin/nginx -t
/usr/local/nginx/sbin/nginx
curl http://localhost/index.html >> nginx.log
str=`grep -Po "Welcome to nginx" nginx.log`
TCID="nginx-test"
if [ "str" != "" ];then
   lava-test-case $TCID --result pass
else
    lava-test-case $TCID --result fail
fi

