function readFile(){
    var fs = require("fs");
    var exec = require('child_process').exec;
    // 异步读取
    fs.readFile('/etc/passwd', function (err, data) {
    if (err) {
        exec('lava-test-case "nodejs read file async" --result fail', function(err , stdout , stderr){ console.log(stdout); });
        return console.error(err);
    }
     exec('lava-test-case "nodejs read file async" --reuslt pass' ,function(err , stdout , stderr){ console.log(stdout);  });
   //  console.log("异步读取: " + data.toString());
   });
    // 同步读取
    var data = fs.readFileSync('/etc/passwd');
    exec('lava-test-case "nodejs read file sync " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
}

function openFile(){

    var fs = require('fs');
    var exec = require('child_process').exec;
    fs.stat('/etc/passwd', function (err, stats) {
        if(err){
            exec('lava-test-case "nodejs stat file " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
        }   
        
        exec('lava-test-case "nodejs stat file " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            
    });
    fs.writeFile('input.txt', 'this is a temp file\n',  function(err) {
        if (err) {
            exec('lava-test-case "nodejs writefile file " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
               
        }
        exec('lava-test-case "nodejs writefile file " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });
    fs.writeFile('tmp.txt',"this is also a temp file\n");
    fs.open('tmp.txt', 'r+', function(err, fd) {
        if (err) {
            exec('lava-test-case "nodejs open file async " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
               
        }
        exec('lava-test-case "nodejs open file async " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );

        fs.close(fd, function(err){
            if (err){
                exec('lava-test-case "nodejs close file " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            } 
            exec('lava-test-case "nodejs close file " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
        });

    });
    fs.unlink('input.txt', function(err) {
        if (err) {
            exec('lava-test-case "nodejs unlink file " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
        }
        exec('lava-test-case "nodejs unlink file " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });


    fs.mkdir("/tmp/test/",function(err){
        if (err) {
            exec('lava-test-case "nodejs mkdir  " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
        }
        exec('lava-test-case "nodejs mkdir " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });

    fs.readdir("/tmp/",function(err, files){
        if (err) {
            exec('lava-test-case "nodejs readdir" --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
        }
        exec('lava-test-case "nodejs readdir " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });

    fs.rmdir("/tmp/test",function(err){
        if (err) {
            exec('lava-test-case "nodejs rmdir " --result fail' , function(err , stdout ,stderr ){console.log(stdout) ;} );
            return console.error(err);
        }
        exec('lava-test-case "nodejs rmdir " --result pass' , function(err , stdout ,stderr ){console.log(stdout) ;} );
    });

}
    
readFile();
openFile();





