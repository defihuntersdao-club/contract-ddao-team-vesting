<?php

function gmp_hexdec($n) 
{
  $gmp = gmp_init(0);
  $mult = gmp_init(1);
  for ($i=strlen($n)-1;$i>=0;$i--,$mult=gmp_mul($mult, 16)) 
  {
    $gmp = gmp_add($gmp, gmp_mul($mult, hexdec($n[$i])));
  }
  return $gmp;
}

?>