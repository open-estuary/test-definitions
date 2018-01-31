#! /bin/bash

function install_mongo-tools() {

    yum install -y mongo-tools
    print_info $? 'install_mongo-tools'
    
    yum install -y mongodb

    export LANG=en_US.UTF-8
    ver=`yum info mongo-tools | grep 'Version'| cut -d : -f 2`
    if [ x"$ver" == x"3.5.7"  ];then
        lava-test-case 'mongo-tools_version' --result pass
    else 
        lava-test-case "mongo-tools_version" --result fail
    fi

}

function uninstall_mongo-tools(){
    
    yum remove -y mongo-tools
    print_info $? "uninstall_mongo-tools"

}


function mongo_mongostat(){
    
    mongostat -n 3
    print_info $? 'mongostat_command'
    
    mongotop -n 1
    print_info $? "mongotop_command"
}

function mongo_dump_restore(){
    
    cat >  tmp.js <<- eof 
    var db = new Mongo().getDB('dump_restore');
    
    for(var i = 0 ; i < 100 ; i++){
        db.col.insert({name : 'scala' , age : 100});
    }
eof
    mongo tmp.js
    print_info $? "mongodb_prepare_database_for_dump"

    mongodump --db dump_restore  
    if [ $? -eq 0 ] ;then 
        if [ -d dump/dump_restore ];then
            lava-test-case "mongodb_dump_database" --result pass
        else
            lava-test-case "mongodb_dump_database" --result fail
        fi 
    else
        lava-test-case "mongodb_dump_database" --result fail
    fi
    

    cat > tmp.js <<- eof
    var db = new Mongo().getDB('dump_restore');
    db.dropDatabase();
eof
    mongo tmp.js 
    mongorestore --db dump_restore dump 
    print_info $? "mongodb_restore_database"
    
    if [ -f export.json  ];then
        rm -f export.json
    fi 
    mongoexport --db dump_restore --collection col --out=export.json --type json
    if [ $?  ];then
        if [ -f export.json  ];then
            lava-test-case "mongodb_export_json_file" --result pass
        else
            lava-test-case "mongodb_export_json_file" --result fail
        fi
    else
        lava-test-case "mongodb_export_json_file" --result fail
    fi
    
    mongo tmp.js 
    mongoexport --db dump_restore --collection col --out=export.csv --type csv --fields name,age 
    if [ $?  ];then
        if [ -f export.csv  ];then
            lava-test-case "mongodb_export_csv_file" --result pass
        else
            lava-test-case "mongodb_export_csv_file" --result fail
        fi
    else
        lava-test-case "mongodb_export_csv_file" --result fail
    fi
    
    mongoimport --db dump_restore --collection json export.json
    print_info $? "mongodb_import_json_file"

    mongoimport --db dump_restore --collection csv --type csv --headerline --file export.csv 
    print_info $? "mongodb_import_csv_file"

}


