#!/bin/bash

set -x

cd ../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

#install
# In addition, use ${INSTALLDIR}/bin, ${INSTALLDIR}/lib, and 
# ${INSTALLDIR}/include to install packages 
# 
# However if it needs to install two or more version of the same package
# it must be installed into ${INSTALLDIR}/${CUR_PKG}/{bin,include,libs} accordingly 
# In addition, it should create symbol links from ${INSTALLDIR}/{bin,libs,include} to
# ${INSTALLDIR}/${CUR_PKG}/{bin,libs,include}
#
INSTALLDIR=$(cd $1; pwd)

HOST=`uname -n`

PKG_NAME="hhvm"
PKG_VER="3.17.3"

case $HOST in
    centos)
        echo "[$PKG_NAME] install package on $HOST system"
        # install hhvm dependent packages
        yum install tbb libdwarf freetype libjpeg-turbo ImageMagick libmemcached libxslt libyaml libtiff fontconfig libXext libXt libtool-ltdl \
        libSM libICE libX11 libgomp cyrus-sasl jbigkit libxcb libXau -y
        print_info $? install-dependent-packages
        yum install -y curl nginx
		print_info $? install-nginx
    ;;
    ubuntu)
        echo "[$PKG_NAME] install package on $HOST system"
        #update the system
        apt-get update -y
        
        # install hhvm dependent packages
        apt-get install libjemalloc-dev libonig-dev libcurl3 libgoogle-glog-dev libtbb-dev libfreetype6-dev libjpeg-turbo8-dev libvpx-dev libxslt1-dev \
        libmagickwand-dev libc-client2007e-dev libmemcached-dev libmcrypt-dev libpq-dev libboost-dev libboost-filesystem-dev libboost-program-options-dev \
        libboost-regex-dev libboost-system-dev libboost-thread-dev libboost-context-dev -y
        print_info $? install-dependent-packages
        apt-get install -y curl nginx
		print_info $? install-nginx
    ;;
    debian)
        echo "[$PKG_NAME] Do not support install hhvm on $HOST system"
        print_info 1 install-dependent-packages
		print_info 1 install-nginx
    ;;
    *)
        echo "[$PKG_NAME] do not support install hhvm on $HOST system"
        print_info 1 install-dependent-packages
		print_info 1 install-nginx
    ;;
esac

pushd $INSTALLDIR/packages/$PKG_NAME-$PKG_VER

if [ ! -e ./${PKG_NAME}-${PKG_VER}-${HOST}.aarch64.tar.gz ];then
    echo "[$PKG_NAME] the tarball is not exist"
	wget http://htsat.vicp.cc:804/hhvm/${PKG_NAME}-${PKG_VER}-${HOST}.aarch64.tar.gz
fi
print_info $? download-hhvm-tarball

if [ ! -d ${INSTALLDIR}/bin ];then
    mkdir -p $INSTALLDIR/bin
fi

if [ ! -d ${INSTALLDIR}/etc/hhvm ];then
    mkdir -p ${INSTALLDIR}/etc/hhvm
fi

tar -xzvf ./${PKG_NAME}-${PKG_VER}-${HOST}.aarch64.tar.gz
print_info $? unzip-hhvm-file

r1=`cp -fr ./bin/* $INSTALLDIR/bin`
r2=`cp -fr ./hhvm/config.hdf $INSTALLDIR/etc/hhvm`
r3=`cp -fr ./hhvm/php.ini $INSTALLDIR/etc/hhvm`
r4=`cp -fr ./hhvm/server.ini $INSTALLDIR/etc/hhvm`
r5=`rm -fr ./bin ./hhvm`
if [ ! $r1 ] && [ ! $r2 ] && [ ! $r3 ] && [ ! $r4 ] && [ ! $r5 ];then
	print_info 0 prepare-config-files
else
	print_info 1 prepare-config-files
fi

popd > /dev/null

echo "setup hhvm successfully"

#prepare test env
test ! -d /var/run/hhvm && mkdir -p /var/run/hhvm
test ! -d /var/log/hhvm && mkdir -p /var/log/hhvm

cp ./conf/nginx.conf* /etc/nginx/ -fr
test ! -d $INSTALLDIR/etc/hhvm && mkdir -p $INSTALLDIR/etc/hhvm

cp ./test_page/test_*.php /usr/share/nginx/html/ -fr
print_info $? copy-php-to-webserver

/usr/sbin/nginx -c /etc/nginx/nginx.conf
curl -o "./index" "http://localhost/index.html"
grep "nginx" "./index"
print_info $? start-nginx

export LD_LIBRARY_PATH=$INSTALLDIR/packages/boost-1.58.0/lib:$LD_LIBRARY_PATH

#create run and log directory
if [ ! -d /var/run/hhvm ];then
    mkdir -p /var/run/hhvm
fi

if [ ! -d /var/log/hhvm ];then
    mkdir -p /var/log/hhvm
fi

#start hhvm service
if [ ! -e $INSTALLDIR/bin/hhvm ];then
    echo "[$PKG_NAME] hhvm has not installed ,please install it firtly"
	print_info 1 start-hhvm 
else
	$INSTALLDIR/bin/hhvm --mode daemon --config $INSTALLDIR/etc/hhvm/server.ini --config $INSTALLDIR/etc/hhvm/php.ini --config $INSTALLDIR/etc/hhvm/config.hdf
	print_info $? start-hhvm
	echo "[$PKG_NAME] start hhvm service successfully"
fi

ps -aux | grep nginx -wc
ps -aux | grep hhvm -wc

# HHVM is work or not
curl -o "./test_hhvm" "http://localhost/test_hhvm.php"
grep "HHVM is working" "./test_hhvm"
print_info $? hhvm-work-status

#remove
#kill the nginx and hhvm process
unset LD_LIBRARY_PATH
print_info $? unset-lib-path

count=`ps -aux | grep nginx | wc -l`
if [ $count -gt 0 ];then
    kill -9 $(pidof nginx)
	print_info $? kill-nginx
fi

count=`ps -aux | grep hhvm | wc -l`
if [ $count -gt 0 ];then
    kill -9 $(pidof hhvm)
	print_info $? kill-hhvm
fi

#remove the binary and configuration files of hhvm
if [ -d /usr/estuary/bin/hhvm ];then
    rm -fr /usr/estuary/bin/hhvm 
fi

if [ -d /usr/estuary/etc/hhvm ];then
    rm -fr /usr/estuary/etc/hhvm
fi

if [ -d /usr/estuary/etc/nginx ];then
    rm -fr /usr/estuary/etc/nginx
fi

print_info $? remove-hhvm
