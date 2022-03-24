<?php
function gmp_decimal_al($val,$d1,$debug=0)
{
if($debug)
print "val1: $val1]\td1: $d1\n";
//$d1 = $coin_mas[$c_id1][digits];
$t = explode(".",$val);
$l = strlen($t[1]);

$d2 = $d1-$l;
//print "d1: $d1\td2: $d2\tt: $t[1]\tl: $l\n";
$t2 = str_replace(".","",$val);
//$l = strlen($t2);
//$t2 = "000872734237397970000";
for($i=0;$i<strlen($t2);$i++)
{
    if($t2[$i]=="0")$t2 = substr($t2+1,$i);
    else break;
}

$t = gmp_pow(10,$d2);
//print_r($t);
//print "t2: $t2\n";
$t = gmp_mul($t2,$t);
//print_r($t);
$t = gmp_strval($t);
//print_r($t);
return $t;
}

?>
