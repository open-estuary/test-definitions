#!/bin/bash


function install_c_driver(){
    case $distro in
      centos)
        pkgs="gcc mongo-c-driver mongo-c-driver-devel"
        install_deps "${pkgs}" 
        print_info $? "mongo_c_driver_install_gcc"
        export LANG=en_US.UTF-8
        ver=`yum info mongo-c-driver|grep "Version" | cut -d : -f 2`
        if [ x"$ver" == x"1.8.2"  ];then
            print_info 0 mongo_c_driver_version
        else
            print_info 1 mongo_C_driver_verion
        fi
        ;;
      fedora)
         pkgs="gcc mongo-c-driver mongo-c-driver-devel"
         install_deps "${pkgs}"
         print_info $? "mongo_c_driver_install"
         ;;
     esac
      
}

function mongo_c_driver_uninstall(){
    
    remove_deps "${pkgs}"
    print_info $? "uninstall_mongo_c_driver"
}

function mongo_c_driver_base(){
    
    mongocpath=`find / -name mongoc\.h`
    mpath=`dirname $mongocpath`
    bsonpath=`find / -name bson\.h`
    bpath=`dirname $bsonpath`
    
    gcc -o hello_mongoc hello_mongoc.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver_compile_with_dynamic_library"

    ./hello_mongoc | grep ok
    print_info $? "mongoCDriver_exec_hello_mongoc"
    

    
    gcc -o insert insert.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver_compile_insert_document"
    ./insert 
    print_info $? "mongoCDriver_exec_insert_document"

    gcc -o find find.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver_compile_find_document"
    ./find 
    print_info $? "mongoCDriver_exec_find_document"

    
    gcc -o find-specific find-specific.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver_compile_find_specific_document"
    ./find-specific 
    print_info $? "mongoCDriver_exec_find_specific_document"
    

    gcc -o update update.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver_compile_update_document"
    ./update 
    print_info $? "mongoCDriver_exec_update_document"



    gcc -o delete delete.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver_compile_delete_document"
    ./delete 
    print_info $? "mongoCDriver_exec_delete_document"

    gcc -o count count.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver_compile_count__document"
    ./count 
    print_info $? "mongoCDriver_exec_count_document"


    gcc -o executing executing.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0
    print_info $? "mongoCDriver_compile_exec_mongodb_command"
    ./executing 
    print_info $? "mongoCDriver_exec_mongodb_command"


    gcc -o example-pool example-pool.c -I${mpath} -I${bpath} -lmongoc-1.0 -lbson-1.0 -lpthread
    print_info $? "mongoCDriver_compile_connect_pool"
    ./example-pool 
    print_info $? "mongoCDriver_exec_connect_pool"


}
