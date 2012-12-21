<?php

$db_host = "localhost";
$db_user = "root";
$db_psw  = "911911";
$db_name = "metatrader";

$tb_thold = "nst_ta_thold_alpariuk833";

$db = new mysqli($db_host,$db_user,$db_psw,$db_name); 

for($i = 0; $i < 47; $i++)
{
	$query = "insert into $tb_thold (ringidx) values ($i)";
	$db->query($query);
}
?>