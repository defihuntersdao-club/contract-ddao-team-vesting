<?php
function view_number($temp_number=1,$digits=20,$symbol = "0")
{
#        $debuger = check_debugger(__FUNCTION__);

//print $temp_prefix;
//if (!(strpos($temp_prefix,"_")===false)) $digits=4;
//else $digits=5;
//;
if (strlen($temp_number)<$digits) for ($i=strlen($temp_number);$i<$digits;$i++) $temp_number=$symbol.$temp_number;
//print $digits."<br>";
        return @$temp_number;
}

?>
