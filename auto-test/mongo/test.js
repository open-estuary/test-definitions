    print('=================');    
    var conn = new Mongo();
    var str = conn.host.match('27017');
    if (str == null)
    {
       run('lava-test-case','monggodb_client_connect' , '--result' , 'fail');
    }else
    {
       run('lava-test-case' , 'mongodb_client_connect' , '--result' , 'pass');
    }

    var db  = conn.getDB('mydb');
    if(db.getName() == 'mydb')
    {
        run('lava-test-case' , 'mongodb_switch_database' , '--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_switch_database' , '--result' , 'fail');
    }
    if(db.col.count() > 0)
    {
        var res = db.col.drop();
        if (res)
        {
            run('lava-test-case' , 'mongodb_drop_table' , '--result' , 'pass');
        }else{
            run('lava-test-case' , 'mongodb_drop_table' , '--result' , 'pass');
        }
    }
    var res1 = db.col.insert({"name":"mongo" , "age":27});
    var res2 = db.col.insert({"name" : "scala" , "age" : 80});
    if(! res1.hasWriteError() && ! res2.hasWriteError())
    {   
        run('lava-test-case' , 'mongodb_insert_data' , '--result' , 'pass');
    }else{
        run('lava-test-case' , 'mongodb_insert_data' , '--result' , 'fail');
    }
    
    var res = db.col.update({name : "mongo"} , {name:'mongo' , age : 100});
    if(res.nModified == 1)
    {
        run('lava-test-case' , 'mongodb_update_document_in_collection' , '--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_update_document_in_collection' , '--result' , 'fail');
    }

    var res = db.col.update({name: 'scala'},
                            {$set:{ age : '190'}});
    if(res.nModified == 1)
    {
        run('lava-test-case' , 'mongodb_update_specific_field' , '--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_update_specific_field' , '--result' , 'fail');
    }
    
    db.col.insert({"name":"mongo" , "age":27});
    db.col.insert({"name":"mongo" , "age":27});
    var res = db.col.remove({name : 'mongo'} , true);
    if(res.nRemoved == 1)
    {
        run('lava-test-case' , 'mongodb_remove_single_document' , '--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_remove_single_document' , '--result' , 'fail');
    }
    db.col.remove({name : 'mongo'} );
    var res = db.col.find({name : 'mongo'});
    if(res.count() == 0)
    {
        run('lava-test-case' , 'mongodb_remove_multi_document' , '--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_remove_multi_document' , '--result' , 'fail');
    }

    db.col.insert({"name":"mongo" , "age":27});
    db.col.insert({"name":"mongo" , "age":127});
    db.col.insert({"name":"spark" , "age":27});
    db.col.insert({"name":"hadoop" , "age":27});
    db.col.insert({"name":"java" , "age":27});
    db.col.insert({"name":"c++" , "age":27});
    db.col.insert({"name":"javascript" , "age":27});
    db.col.insert({"name":"php" , "age":27});
    var res = db.col.find({name : 'mongo'});
    if (res.count() > 0)
    {
        run('lava-test-case' , 'mongodb_find_all_match_contional' , '--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_find_all_match_contional' , '--result' , 'fail');
    }
    var res = db.col.find({name : 'mongo' , age : 27} , {age : 1 , by : 1});
    if(res.count()>0)
    {
        run('lava-test-case' , 'mongo_find_multi_contional' , '--result' , 'pass');
    }else
    {   
        run('lava-test-case' , 'mongodb_find_multi_contional' , '--result' , 'fail');
    }
    
    var res = db.col.find({$or : [{name : 'php'} , {age : 127} ]});
    if(res.count() == 2)
    {
        run('lava-test-case' , 'mongodb_find_with_or_contional' , '--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_find_with_or_contional' , '--result' , 'fail');
    }
    
    var isErr=false;
    try {
        var res1 = db.col.find({name : 'mongo'} , {name : 0 , by : 0});
    }catch(err){
        isErr = true;
    }finally{
        if(isErr){
            run('lava-test-case' , 'mongodb_find_inclusion_mode' , '--result' , 'fail');
        }else{
            run('lava-test-case' , 'mongodb_find_inclusion_mode' , '--result' , 'pass');
        }
    }

    var isErr=false;
    try {
        var res1 = db.col.find({name : 'mongo'} , {name : 1 , by : 1});
    }catch(err){
        isErr = true;
    }finally{
        if(isErr){
            run('lava-test-case' , 'mongodb_find_exclusion_mode' , '--result' , 'fail');
        }else{
            run('lava-test-case' , 'mongodb_find_exclusion_mode' , '--result' , 'pass');
        }
    }


    db.col.dropIndexes();
    db.col.createIndex({name : 1});
    var len =  db.col.getIndexes().length
    if (len == 2)
    {
        run('lava-test-case' , 'mongodb_create_index' ,'--result' , 'pass');
    }else
    {
        run('lave-test-case' , 'mongodb_create_index' , '--result' , 'fail');
    }
    db.col.dropIndexes();
    var len = db.col.getIndexes().length;
    if( len == 1 )
    {
        run('lava-test-case' , 'mongodb_drop_index' ,'--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_drop_index' , '--result' , 'fail');
    }

    for(var i = 0 ; i<5 ; i++)
    {
        db.posts.insert({
            "post_text": "菜鸟教程，最全的技术文档。",
            "user_name": "mark",
             "status":"active"
         });
    }
    var res = db.posts.mapReduce(
        function() { emit(this.user_name , 1) ;},
        function(key , value) { return Array.sum(value) ;},
        {
            query:{ status :"active" },
            out:"post_total"
        }
    )
    if(res == 1){
        run('lava-test-case' , 'mongodb_run_mapreduce' , '--result' ,'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_run_mapreduce' , '--result' , 'pass');
    }
    
    var res0 = db.col.find({name:'mongo'})[0].age;
    var res1 = db.col.findAndModify(
        {
            query:{ name : 'mongo'},
            update :{ $inc : {age : -1} }
        }
    );

    
    var data = db.col.find({name:'mongo'})[0].age;
    if ( res0 - data == 1 ){
        run('lava-test-case' , 'mongo_atomic_op' , '--result' , 'pass');
    }else{
        run('lava-test-case' , 'mongo_atomic_op' , '--result' , 'fail');
    }
    
    var res2 = db.col.find().limit(2);
    if (res2.countReturn() == 2 ){
        run('lava-test-case' , 'mongodb_limit_op' , '--result' , 'pass' );
    }else{
        run('lava-test-case' , 'mongodb_limit_op' , '--result' , 'fail');
    }
    
    var res4 = db.col.find();
    var res3 = db.col.find().skip(3);
    if (res4.countReturn() - res3.countReturn() == 3 ){
        run('lava-test-case' , 'mongodb_skip_op' , '--result' , 'pass');
    }else{
        run('lava-test-case' , 'mongodb_skip_op' , '--result' , 'fail');
    }

    
    db.col.insert({name : 1 , age : 100});
    var res5 = db.col.find({name : {$type : 1}});
    if(res5[0].name == 1){
        run('lava-test-case' , 'mongodb \$type filter' , '--result' , 'pass');
    }else{
        run('lava-test-case' , 'mongodb \$type filter' , '--result' , 'fail');
    }

    if(db.dropDatabase().ok == 1)
    {
        run('lava-test-case' , 'mongodb_drop_database' , '--result' , 'pass');
    }else
    {
        run('lava-test-case' , 'mongodb_drop_database' , '--result' , 'fail');
    }


    
