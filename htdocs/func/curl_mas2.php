<?php

function curl_mas2($jss,$rpc,$debug=0,$proxy = "")
{

//global $curl1,$curl2;
global $curl1,$proxy_mas;
$curl2 = $rpc;
//$kolvo = count($jss);
//print "kolvo = $kolvo\n";

//print "js len = ".strlen($js)."\n";
$len = 0;
$nn = 0;
foreach($jss as $js)
{
    $t = json_encode($js);
    $len += strlen($t);
    if($len>120000){$nn++;$len = 0;}
    $jss2[$nn][] = $js;
}
//$js = json_encode($js2);
//$js = $js2;
//print_r($jss);die;
//print_r($jss2);die;


unset($reg);
foreach($jss2 as $jss)
{
$js = json_encode($jss);
/*
$t = date("s");
$t = $proxy_mas[$t];
$t = explode("\t",$t);
$curl = $curl1."'".$js."' --proxy http://$t[0]:$t[1] $curl2 2>/dev/null";
//$curl = $curl1."'".$js."' $curl2  2>/dev/null";
*/
/*
$t = date("s");
$t *= 1;
$t = $proxy_mas[$t];
//print_r($t);
$t = explode("\t",$t);
//print_r($t);die;
$proxy = "";
if($t[0] && $t[1])
{
$proxy = "--proxy http://$t[0]:$t[1]";
//print $proxy;
//die;
}
*/
//$proxy = proxy_get();
if($proxy)$proxy = "--proxy $proxy";

$curl = $curl1."'".$js."' $proxy $curl2  2>/dev/null";

if($debug)
print $curl."\n";
exec($curl,$reg);
$res = implode("",$reg);
if($debug)
{
//print_r($reg);
//print $res;
}

}
//print_r($reg);


//foreach($reg as $l)
{
    $mas2 = json_decode($res,1);
    foreach($mas2 as $v)
    $mas[] = $v;
//    if(!isset($mas2))
//    $mas2 = $mas;
//    else
//    array_merge($mas2,$mas);
}
//print_r($mas);
//die;
//$res = $reg[0];
return $mas;
}

?>