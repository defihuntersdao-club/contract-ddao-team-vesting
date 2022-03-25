#!/usr/bin/php
<?php
include "conf.php";

$a = "
AddrDDAO:       0x52f36998
AddrProxy:      0x14590dd7
AdminList:      0x90fc4ebb
AmountMax:      0xa4ae6072
TimeStart:      0x3962c4ff
TimeEnd:        0x52bd9914
TimeNow:        0xb597842a
TimeUpdate:     0x93bcd90f
HistoryNum:     0xbad7c6b7
";
//UpdateTime:     0x1bbe5a9a
$a = trim($a);
$mas = explode("\n",$a);
$preg = "/[\s]{1,100}/sim";
foreach($mas as $l)
{
    $l = preg_replace($preg,"\t",$l);
    $t = explode("\t",$l);
    $n = $t[0];
    $n = str_replace(":","",$n);
    $v = $t[1];
    $o[$n] = $v;
}
print_r($o);
foreach($o as $k=>$v2)
{
unset($v,$t);
//$t[from] = $wal;
$t[from] = "0x0000000000000000000000000000000000000000";
$t[data] = $v2;
$t[to] = $contractAddress;
//print_r($t);

$v[jsonrpc] = "2.0";
$v[method] = "eth_call";
//$v[params][0] = $row[wal];
$v[params][0] = $t;
$v[params][1] = "latest";
//$v[id] = $row[id];
$v[id] = $k;
$jss[] = $v;


}
//print_r($jss);

for($i=1;$i<5;$i++)
{
$b = "0x2dcd8d41";
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
$v[id] = "Group_".$i;
$jss[] = $v;

//====================
$b = "0x5de0e9d2";
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
$v[id] = "GroupLen_".$i;
$jss[] = $v;
//================
$b = "0x579bcaa8";
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
$v[id] = "GroupMaxVal_".$i;
$jss[] = $v;

//================
$b = "0xc98dd75a";
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
$v[id] = "GroupMemberShow_".$i;
$jss[] = $v;

}

//================
$b = "0xa43759050000000000000000000000000000000000000000000000000000000000000000";
//unset($v,$t);
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
$v[id] = "RewardAllNow";
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
    $t = explode("_",$id);
    $id = $t[0];
    $item = $t[1];
    $v = $v2[result];
    switch($id)
    {
	case "AddrDDAO":
	case "AddrProxy":
	    $v = "0x".substr($v,26);
	break;
	case "AdminList":
	    $t = substr($v,2);
	    $l = strlen($t)/64;
	    unset($v3);
	    for($i=2;$i<$l;$i++)
	    {
		$t2 = "0x".substr($t,$i*64+24,64-24);
		$v3[] = $t2;
	    }
	    $v = $v3;
	break;
	case "GroupMemberShow":
	    $v3 = $o2[$id];
	    $t = substr($v,2);
	    $l = strlen($t)/64;
//	    unset($v3);
	    for($i=2;$i<$l;$i++)
	    {
		$t2 = "0x".substr($t,$i*64+24,64-24);
		$v3[$item][] = $t2;
	    }
	    $v = $v3;
	break;
	case "TimeStart":
	case "TimeEnd":
	case "TimeNow":
	case "UpdateTime":
	    $v = hexdec($v);
	    $v = date("Y-m-d H:i:s",$v);
	break;
	case "GroupLen":
	case "Group":
	case "GroupMaxVal":
	    //unset($v3);
	    $v3 = $o2[$id];
	    $v = hexdec($v);
	    $v3[$item] = $v;
	    //$o2[$id][$item] = $v;
	    $v = $v3;
	break;
	case "RewardAllNow":
	    $v = hexdec($v);
	    $v /= 10**18;
	break;
	default:
	$v = hexdec($v);
    }
	$o2[$id] = $v;
}
//print_r($o2);
$o2[ContractAddress] = $contractAddress;

unset($jss);
foreach($o2[GroupMemberShow] as $grp=>$v3)
{
    foreach($v3 as $nn=>$v2)
    {
//================
//$b = "0xc98dd75a";
$b = "0x0d6b47b1";
$b = "0xb436af75";
//0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a5b32272f2fe16d402fe6da4edff84cd6f8e4aa
$b .= view_number($grp,64,0);
$b .= "".view_number(substr($v2,2),64,0);
$b .= view_number(0,64,0);
//$b .= "00000000000000000000000000000000000000000000000000000000000000000";
//$b .= $v2;
//0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a5b32272f2fe16d402fe6da4edff84cd6f8e4aa0
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
$v[id] = "RewardByAddr_".$grp."_".($nn+1)."_".$v2;
$jss[] = $v;
	
    }
}
//print_r($jss);


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
    $t = $v2[id];
    $t = explode("_",$t);
    $id = $t[0];
    $grp = $t[1];
    $nn = $t[2];
    $w = $t[3];
    $v = $v2[result];
    $v = hexdec($v);
    $v /= 10**18;
//    switch($id)
    $o2[reward][all] += $v;
    $o2[reward][$grp][$nn] = $v;

    
}
print_r($o2);
unset($jss);
$t_mas[] = "2022-08-01 02:00:00";
$t_mas[] = "2023-03-01 02:00:00";
$t_mas[] = "2024-03-01 02:00:00";
$t_mas[] = "2025-03-01 02:00:00";
foreach($t_mas as $time)
{


reset($o2[GroupMemberShow]);
foreach($o2[GroupMemberShow] as $grp=>$v3)
{
    reset($v3);
    foreach($v3 as $nn=>$v2)
    {
$nn2 = $nn+1;
//================
//$b = "0xc98dd75a";
//$b = "0x0d6b47b1";
$b = "0x35b7580b";
$b .= view_number($grp,64,0);
$b .= "".view_number($nn2,64,0);
$t = $time;
$t = strtotime($t);
$utime = $t;
$t = dechex($t);
$b .= "".view_number($t,64,0);
//$b .= $v2;
//0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a5b32272f2fe16d402fe6da4edff84cd6f8e4aa0
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
$v[id] = "RewardByTime_".$grp."_".($nn+1)."_".$v2."_".$utime;
$jss[] = $v;

    }
}

}

//print_r($jss);die;

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
    $t = $v2[id];
    $t = explode("_",$t);
    $id = $t[0];
    $grp = $t[1];
    $nn = $t[2];
    $w = $t[3];
    $utime = $t[4];
    $time = date("Y-m-d-H-i-s",$utime);
    $v = $v2[result];
    $v = substr($v,64+2,64);
    $v = hexdec($v);
    $v /= 10**18;
    $o2[rewardByTime][$time][$grp][$nn] = $v;
}
print_r($o2);
$a = json_encode($o2,192);
$f = "res.json";
file_put_contents($f,$a);

unset($jss,$mas);
for($i=1;$i<=$o2[HistoryNum];$i++)
{
$b = "0xb436af75";
$b = "0xa21f0368";
//0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a5b32272f2fe16d402fe6da4edff84cd6f8e4aa
$b .= view_number($i,64,0);
//$b .= "".view_number(substr($v2,2),64,0);
//$b .= view_number(0,64,0);
//$b .= "00000000000000000000000000000000000000000000000000000000000000000";
//$b .= $v2;
//0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a5b32272f2fe16d402fe6da4edff84cd6f8e4aa0
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
$v[id] = "History_".$i;
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
foreach($mas as $v2)
{
    unset($t2,$t3);
    $t = $v2[result];
    $t = substr($t,2);
    $l = strlen($t)/64;
    for($i = 0;$i<$l;$i++)
    {
	$v = substr($t,$i*64,64);
	switch($i."")
	{
	    case "0":
		$n = "num";
		$v = hexdec($v);
	    break;

	    case "1":
		$n = "addr";
		$v = "0x".substr($v,24);
	    break;
	    case "2":
		$n = "amount";
		$v = hexdec($v);
		$v /= 10**18;
	    break;
	    case "3":
		$n = "payed";
		$v = hexdec($v);
		$v /= 10**18;
	    break;
	    case "4":
		$n = "time";
		$v = hexdec($v);
		$v = date("Y-m-d H:i:s",$v);
	    break;


	}
	$t3[$n] = $v;
    }
    $o2[history][$t3[num]] = $t3;
//    print_r($t3);

}
print_r($o2);