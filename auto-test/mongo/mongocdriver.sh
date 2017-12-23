#!/bin/bash


function install_c_driver(){
    
    yum install -y gcc
    print_info $? "mongo c driver install gcc"
    yum install -y mongo-c-driver 
    print_info $? "mongodb install c driver"

    export LANG=en_US.UTF-8
    ver=`yum info mongo-c-driver|grep "Version" | cut -d : -f 2`
    if [ $ver == "1.6.2"  ];then
        true
    else
        false
    fi
    print_info $? "mongo c driver version"

    yum install -y mongo-c-driver-devel 

}

function mongo_c_driver_uninstall(){
    
    yum remove -y mongo-c-driver
    print_info $? "uninstall mongo c driver"
    yum remove -y mongo-c-driver-devel 
}

function mongo_c_driver_base(){
    
    mongocpath=`find / -name mongoc\.h`
    mpath=`dirname $mongocpath`
    bsonpath=`find / -name bson\.h`
    bpath=`dirname $bsonpath`
    
    gcc -o hello_mongoc hello_mongoc.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver compile with dynamic library"

    ./hello_mongoc | grep ok
    print_info $? "mongoCDriver exec hello_mongoc"
    

    
    gcc -o insert insert.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver compile insert document"
    ./insert 
    print_info $? "mongoCDriver exec insert document"

    gcc -o find find.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver compile find document"
    ./find 
    print_info $? "mongoCDriver exec find document"

    
    gcc -o find-specific find-specific.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver compile find specific document"
    ./find-specific 
    print_info $? "mongoCDriver exec find specific document"
    

    gcc -o update update.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver compile update document"
    ./update 
    print_info $? "mongoCDriver exec update document"



    gcc -o delete delete.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver compile delete document"
    ./delete 
    print_info $? "mongoCDriver exec delete document"

    gcc -o count count.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver compile count  document"
    ./count 
    print_info $? "mongoCDriver exec count document"


    gcc -o executing executing.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver compile exec mongodb command"
    ./executing 
    print_info $? "mongoCDriver exec mongodb command"


    gcc -o example-pool example-pool.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0 -lpthread
    print_info $? "mongoCDriver compile connect pool"
    ./example-pool 
    print_info $? "mongoCDriver exec connect pool"


}
