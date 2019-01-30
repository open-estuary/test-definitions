var page = require('webpage').create();
page.open('https://baidu.com/', function () {
     page.render('test/example.png');
     phantom.exit();
 });
