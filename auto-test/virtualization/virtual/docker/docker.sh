#!/bin/bash
set -x

cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

! check_root && error_msg "Please run this script as root."

##################### Environmental preparation ###################

case "$distro" in
    centos|fedora|opensuse)
	pkgs="make wget docker"
	install_deps "${pkgs}"
	print_info $? install-docker
    	;;
    ubuntu)
	pkgs="make wget docker docker.io"
	install_deps "${pkgs}"
	print_info $? install-docker
	;;
    debian)
	apt-get update
	#安装软件包
        pkgs="apt-transport-https ca-certificates curl gnupg2 lsb-release software-properties-common make wget"
	install_deps "${pkgs}"
	#添加官方GPG key: 
	curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
	#设置库
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
	print_info $? docker_repository
	apt-get update
	#安装docker
	apt-get install docker-ce -y
	print_info $? install_docker
    ;;
esac

##################### the testing step ###########################
#创建docker用户组
GROUP=`cat /etc/group |grep "docker"|awk -F ':' '{print $1}'`

if [ "$GROUP"x != "docker"x ]; then
    	groupadd docker
fi

#启动docker服务
systemctl start docker
print_info $? docker-start-service

if [ "`systemctl status docker | grep running`"x != ""x ]; then
    print_info 0 docker-status-service
else
    print_info 1 docker-status-service
fi

#下载docker镜像文件
if [ ! -d docker ]; then
    download_file http://htsat.vicp.cc:804/docker/docker.tar.gz
    #download_file http://192.168.50.122:8083/test_dependents/docker.tar.gz
    [[ $? -eq 0 ]] && tar -zxf docker.tar.gz
	print_info $? download-docker-image
fi

#docker加载镜像文件
docker load --input docker/openestuary_apache.tar.gz
print_info $? docker-load-apache

docker load --input docker/openestuary_mysql.tar.gz
print_info $? docker-load-mysql


images=$(docker images| grep -v 'REPOSITORY' | awk '{print $1}')
docker_images=$(echo $images | grep mysql | grep apache)

if [ ! -d docker/Discuz ]; then
    pushd ./docker
    tar -xf Discuz.tgz
	print_info $? unzip-discuz-file
    popd
fi

sed -i "s/192.168.1.246/${local_ip}/g" `grep -rl 192.168.1.246 ./docker/Discuz`
print_info $? replace-discuz-ip

cp -rf ./docker/Discuz ./docker/mysql_data  /root/
print_info $? prepare-lamp-file

#启动镜像文件
docker run -d -p 32768:80 --name apache -v /root/Discuz:/var/www/html openestuary/apache
print_info $? docker-run-apache


docker run -d -p 32769:3306 --name mysql -v /root/mysql_data:/u01/my3306/data openestuary/mysql
print_info $? docker-run-mysql

#查看正在运行的容器
container_id=$(docker ps | grep -v IMAGE | awk '{print $1}')
if [ "$container_id"x != ""x ]; then
    print_info 0 docker-ps
else
    print_info 1 docker-ps
fi


declare -A id_service_dic
declare -a image_id
ids=$(docker ps | grep -v IMAGE | awk '{print $1}')
services=$(docker ps | grep -v IMAGE | awk '{print $NF}')
read -a image_id <<< $(echo $ids)
declare -a service
read -a service <<< $(echo $services)
len_ids=${#service[@]}
i=0
while [ $i -lt $len_ids ]
do
    id_service_dic[${image_id[$i]}]=${service[$i]}
    i=$(( $i + 1 ))
done

#测试容器运行情况
if [ ! -f "upload" ]; then
	echo "upload file not exist!!"
fi
wget http://${local_ip}:32768/upload

if [ -f "upload" ]; then
	print_info 0 docker-run-LAMP
else
	print_info 0 docker-run-LAMP
fi

#重启容器
for i in $container_id
do
    docker restart $i
    print_info $? docker-restart-${id_service_dic[$i]}
done

#停止容器
for i in $container_id
do
    docker stop $i
    print_info $? docker-stop-${id_service_dic[$i]}
done

#删除容器
for i in $container_id
do
    docker rm $i
    print_info $? docker-rm-${id_service_dic[$i]}
done

#删除镜像文件
for i in ${images}
do
    docker rmi $i
    print_info $? docker-rmi-$i
done

####################  environment  restore ##############
rm -rf docker.tar.gz
rm -rf docker
rm -rf upload
rm -rf rm -rf /var/lib/docker

case "${distro}" in
    centos|ubuntu|fedora|opensuse)
	remove_deps "${pkgs}"
	print_info $? remove_docker
	;;
    debian)
	apt-get purge docker-ce -y
	remove_deps "${pkgs}"
        print_info $? remove_docker
	;;
esac






