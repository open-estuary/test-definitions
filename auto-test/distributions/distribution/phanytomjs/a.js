var page = require('webpage').create();
page.open('https://www.baidu.com/', function () {
     page.render('test/example.png');
     phantom.exit();
 });
