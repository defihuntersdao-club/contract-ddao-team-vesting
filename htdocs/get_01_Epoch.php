#!/usr/bin/php
<?php
include "conf.php";

print "RPC: $rpc\n";
print "Contract: $contractAddress\n";;

$b = "0xc8f846af";
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
$v[id] = "EpochCount";
$jss[] = $v;


//for($i = 1;$i<5;$i++)
$i = 1;
{
//$b = "0xfc1fa192";
$b = "0xc1d4931e";
unset($v,$t);
$b .= view_number($i,64,0);
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
$v[id] = "Epoch".$i;
$jss[] = $v;
}

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

