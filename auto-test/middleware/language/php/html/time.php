<?php
date_default_timezone_set("Asia/Shanghai");
echo "the current time is " . date("h:i:sa");

$d=mktime(9, 12, 31, 6, 10, 2015);
echo "the create time is  " . date("Y-m-d h:i:sa", $d);

$d=strtotime("10:38pm April 15 2015");
echo "the create day is " . date("Y-m-d h:i:sa", $d);

$d1=strtotime("December 31");
$d2=ceil(($d1-time())/60/60/24);
echo "the time to 12.31 has" . $d2 ." days.";

?>

