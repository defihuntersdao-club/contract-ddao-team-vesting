<?php
include "conf.php";

ob_start();
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <title>DDAO Team</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
  <META HTTP-EQUIV="refresh" CONTENT="3">
</head>
<body>
<?php
$f = "res.json";
$a = file_get_contents($f);
$a = json_decode($a,192);
print "<pre>";
print_r($a);
print "</pre>";

$f = "index";
$a = ob_get_contents();
$md5 = md5($a);
$b = file_get_contents($f.".md5");
if($b != $md5)
{
file_put_contents($f.".html",$a);
file_put_contents($f.".md5",$md5);
}
//print $a;
