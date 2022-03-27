#!/usr/bin/php
<?php
include "conf.php";

unset($v);
$v[jsonrpc] = "2.0";
$v[method] = "eth_blockNumber";
//$v[params][0] = $row[wal];
$v[params] = array();
//$v[params][1] = "latest";
//$v[id] = $row[id];
$v[id] = "last";
//$v[id] = "balance_".$name;
$jss[] = $v;


$b = "0x9c05f302";
unset($v,$t);
//$b .= view_number($i,64,0);
//$t[from] = $wal;
$t[from] = "0x0000000000000000000000000000000000000000";
$t[data] = $b;
$t[to] = $contractAddress;
//print_r($t);

$v[jsonrpc] = "2.0";
$v[method] = "eth_call";
//$v[params][0] = $row[wal];
$v[params][0] = $t;
$v[params][1] = "latest";
//$v[id] = $row[id];
$v[id] = "deploy";
$jss[] = $v;

print "Send ".count($jss)." requests to blockchain\n";
$t = $time;
//print "Get data from blockchain in ".count($jss)." requests\n";
if(count($jss))
{
$mas = curl_mas2($jss,$rpc,1);
}
$t = time()-$t;
print "Get data from blockchain in ".count($jss)." requests [$t sec]\n";

print_r($mas);

foreach($mas as $v2)
{
    $id = $v2[id];
    $v = $v2[result];
    $v = hexdec($v);
    $o[blk][$id] = $v;
}
print_r($o);

unset($jss);
unset($t,$v);
unset($v);
$v[jsonrpc] = "2.0";
$v[method] = "eth_getLogs";

$t[address] = $contractAddress;
//$i11 = $i1-100;
//if($i11>$i2)$i11 = $i2-100;

$t[fromBlock] = "0x".dechex($o[blk][deploy]);
$t[toBlock] = "0x".dechex($o[blk][last]);;
//$t[topics][] = $topic;
$v[params][0] = $t;
//$v[id] = $row[id];
$v[id] = "logs";
//$v[id] = "logs";
//$jss[] = $v;
$jss[] = $v;

print_r($jss);
print "Send ".count($jss)." requests to blockchain\n";
$t = $time;
//print "Get data from blockchain in ".count($jss)." requests\n";
if(count($jss))
{
$mas = curl_mas2($jss,$rpc,1);
}
$t = time()-$t;
print "Get data from blockchain in ".count($jss)." requests [$t sec]\n";
//print_r($mas);
foreach($mas[0][result] as $nn=>$v2)
{
//print_r($v2);
    $topic = $v2[topics][0];
    $t = $v2[data];

    $t = substr($t,2);
    $l = strlen($t)/64;
//print "$t\t$l\n";;
    for($i = 0;$i<$l;$i++)
    {
	$t2 = substr($t,$i*64,64);
	$v = gmp_hexdec("0x".$t2);
	$v = gmp_strval($v);
	print "$i\t";
	print "$t2\t";
	print "$v\t";
	print "\n";
    }
    print "\n";
}
print "\nEND\n";