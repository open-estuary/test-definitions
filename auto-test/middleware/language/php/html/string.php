<?php
echo strlen("Hello world!");
echo strpos("Hello world!","world");
print_r(str_split("Shanghai",3));
echo strchr("Hello world!","world",true);
echo strcmp("Hello","hELLo");
echo strncasecmp("I love China!","I love Shanghai!",6);
echo strncmp("I love China!","I love Shanghai!",6);
echo strrev("I love Shanghai!");
echo strtolower("Hello WORLD.");
echo strtoupper("Hello WORLD!");
echo substr("Hello world",-10,-2)."<br>";

?>
