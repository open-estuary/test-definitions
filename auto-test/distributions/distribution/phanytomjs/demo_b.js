var page = require('webpage').create();
phantom.outputEncoding = "UTF-8"; //解决中文乱码
page.open("http://10.90.31.150", function(status) {
    console.log(status);
    page.render('screen.png');
    var title = page.evaluate(function() {
        return document.title;
    });
    console.log('Page title: ' + title);
    phantom.exit();
});
