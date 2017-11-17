#!/bin/bash


function install_mongodb() {
    yum install -y mongodb 
    print_info $? "mongodb install mongodb client"
    yum install -y mongodb-server
    print_info $? "mongodb install mongodb server"

    mZersion=`mongo -version | grep "shell version" | awk {'print $4'}`
    echo  $version | grep "v3.4.3"
    print_info $? "mongodb client version"

    version=`mongod -version | grep "db version | awk {'print $3'}"`
    echo $version | grep "v3.4.3"
    print_info $? "mongodb server version"

}

function mongodb_config(){
    echo     

}

function mongodb_start(){
    ## --frok 是可以在后台运行
    ## --dbpath 是mongodb数据存放地方
    ## --rest 是可以web访问的参数 端口是 27017 + 1000
    mon=`ps -ef |grep "mongod --fork" | grep -v grep`
    if [ $?  ];then
        echo $mon | awk {'print $2'} | kill -4
    fi
    if [ -d /mongodb/db  ];then
        rm -rf /mongodb/db 
    fi
    if [ -d /mongodb/log  ];then
        rm -rf /mongdb/log
    fi
    mkdir -p /mongodb/db 
    mkdir -p /mongodb/log
    mongod --fork --dbpath /mongodb/db --logpath /mongodb/log/mongodb.log --logappend --rest
    print_info $? "mongodb start server"

}

function mongodb_client(){
   cat > test.js <<-EOF
   print('=========WECOME==========');

   var cursor=db.user.find();
   printjson(cursor.toArray());
EOF
    mongo test.js 
}
