function readFile(){
    var fs = require("fs");
    var exec = require('child_process').exec;
    // 异步读取
    fs.readFile('/etc/passwd', function (err, data) {
    if (err) {
        exec('lava-test-case "nodejs_read_file_async" --result fail', function(err , stdout , stderr){ console.log(stdout); });
        return console.error(err);
    }
     exec('lava-test-case "nodejs_read_file_async" --reuslt pass' ,function(err , stdout , stderr){ console.log(stdout);  });
   //  console.log("异步读取: " + data.toString());
   });
    // 同步读取
    var data = fs.readFileSync('/etc/passwd');
    exec('lava-test-case "nodejs_read_file_sync " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
}

function openFile(){

    var fs = require('fs');
    var exec = require('child_process').exec;
    fs.stat('/etc/passwd', function (err, stats) {
        if(err){
            exec('lava-test-case "nodejs_stat_file " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
        }   
        
        exec('lava-test-case "nodejs_stat_file " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            
    });
    fs.writeFile('input.txt', 'this is a temp file\n',  function(err) {
        if (err) {
            exec('lava-test-case "nodejs_writefile_file " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
               
        }
        exec('lava-test-case "nodejs_writefile_file " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });
    fs.writeFile('tmp.txt',"this is also a temp file\n");
    fs.open('tmp.txt', 'r+', function(err, fd) {
        if (err) {
            exec('lava-test-case "nodejs_open_file_async " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
               
        }
        exec('lava-test-case "nodejs_open_file_async " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );

        fs.close(fd, function(err){
            if (err){
                exec('lava-test-case "nodejs_close_file " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            } 
            exec('lava-test-case "nodejs_close_file " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
        });

    });
    fs.unlink('input.txt', function(err) {
        if (err) {
            exec('lava-test-case "nodejs_unlink_file " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
        }
        exec('lava-test-case "nodejs_unlink_file " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });


    fs.mkdir("/tmp/test/",function(err){
        if (err) {
            exec('lava-test-case "nodejs_mkdir  " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
        }
        exec('lava-test-case "nodejs_mkdir " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });

    fs.readdir("/tmp/",function(err, files){
        if (err) {
            exec('lava-test-case "nodejs_readdir" --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
        }
        exec('lava-test-case "nodejs_readdir " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });

    fs.rmdir("/tmp/test",function(err){
        if (err) {
            exec('lava-test-case "nodejs_rmdir " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
        }
        exec('lava-test-case "nodejs_rmdir " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });

}
    
readFile();
openFile();





