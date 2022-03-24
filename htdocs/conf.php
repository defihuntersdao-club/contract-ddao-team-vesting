<?php

error_reporting(0);

include "func.php";

$curl1 = "curl --connect-timeout 4 -H 'content-type: application/json' -X POST --data ";

$f = "/opt/rpc_need.txt";
$rpc = file_get_contents($f);

$rpc = "https://matic-mumbai.chainstacklabs.com";

$time = time();
$chain_id = 137;

$contractAddress = "0x2935890863a2235bfd8876ff8e92b2785a9a20a7";
$contractAddress = "0x2a968bc126E6afFAF27f88cd11b06a6E548135d1";
?>