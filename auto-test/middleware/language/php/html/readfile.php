<?php

$myfile = fopen("newfile.txt", "r") or die("Unable to open file!");

echo fread($myfile,filesize("newfile.txt"));

while(!feof($myfile)) {
  echo fgets($myfile) . "<br>";
}

fclose($myfile);



?>
