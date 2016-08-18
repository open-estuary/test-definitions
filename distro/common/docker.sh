#!/bin/bash
pushd ./utils
. ./sys_info.sh
popd

if [ "$start_service"x = ""x ]; then
    service docker start
else
    groupadd docker
    $start_service docker.service
fi
if [ "`ps -aux | grep docker`"x != ""x ]; then
    print_info 0 docker-start-service
else
    print_info 1 docker-start-service
fi


docker pull openestuary/apache
print_info $? docker-pull-apache


docker pull openestuary/mysql
print_info $? docker-pull-mysql


images=$(docker images| grep -v 'REPOSITORY' | awk '{print $1}')
docker_images=$(echo $images | grep mysql | grep apache)

if [ ! -d Discuz ]; then
    download_file http://htsat.vicp.cc:808/Docker-files/Discuz.tar.gz
    [[ $? -eq 0 ]] && tar xf Discuz.tar.gz
fi
if [ ! -d mysql_data ]; then
    download_file http://htsat.vicp.cc:808/Docker-files/mysql_data.tar.gz
    [[ $? -eq 0 ]] && tar xf mysql_data.tar.gz
fi
sed -i "s/192.168.1.246/${local_ip}/g" `grep -rl 192.168.1.246 ./Discuz`

cp -rf Discuz mysql_data  /root/

docker run -d -p 32768:80 --name apache -v /root/Discuz:/var/www/html openestuary/apache
print_info $? docker-run-apache


docker run -d -p 32769:3306 --name mysql -v /root/mysql_data:/u01/my3306/data openestuary/mysql
print_info $? docker-run-mysql


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

wget http://${local_ip}:32768/upload
print_info $? docker-run-LAMP


for i in $container_id
do
    docker restart $i
    print_info $? docker-restart-${id_service_dic[$i]}
done


for i in $container_id
do
    docker stop $i
    print_info $? docker-stop-${id_service_dic[$i]}
done


for i in $container_id
do
    docker rm $i
    print_info $? docker-rm-${id_service_dic[$i]}
done

for i in ${images}
do
    #docker rmi $i
    print_info $? docker-rmi-$i
done
