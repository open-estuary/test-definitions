#!/bin/bash

#=================================================================
#   文件名称：create_ansible_dir.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月04日
#   描    述：
#
#================================================================*/

function create_dir(){

    path=$1
    name=`basename $path`
    if [ -d $path ];then
        echo "directory $path had exists! please select another directory,thanks!"
        exit 1
    fi
    mkdir $path
    cd $name
        touch hosts 
        echo "---" > site.yml
        mkdir -p roles/{common,$name}/{tasks,handles,templates,files,vars,meta}
        mkdir -p group_vars
        echo "---" > group_vars/$name
        echo '---' > roles/${name}/tasks/main.yml
        echo "---" > roles/${name}/handles/main.yml
        echo "---" > roles/${name}/vars/main.yml
        echo '---' > roles/common/tasks/main.yml
        echo "---" > roles/common/handles/main.yml
        echo "---" > roles/common/vars/main.yml
    cd -
    
   

}

create_dir $1
