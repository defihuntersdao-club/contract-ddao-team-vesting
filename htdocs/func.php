<?php
$func_dir = dirname(__FILE__)."/func/";
$handle=opendir($func_dir);

while ($file = readdir($handle))
if (!($file=="." || $file==".."))
{
    if($file[0]==".")continue;
    if($file[0]=="#")continue;
    $this_file = $func_dir.$file;
$t = pathinfo($this_file);
if($t[extension]!="php")continue;
//print $this_file."\n";
        include $this_file;
}
?>
