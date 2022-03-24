<?php
function gmp_dechex($dec)
{
    $hex = gmp_strval(gmp_init($dec), 16);
    return $hex;
}
?>