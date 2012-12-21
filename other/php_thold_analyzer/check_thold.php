<?php

$db_host = "localhost";
$db_user = "root";
$db_psw  = "911911";
$db_name = "metatrader";

//$tholdtable;
$tb_log = "nst_ta_log_alpariuk833";
$tb_thold = "nst_ta_thold_alpariuk833";

$db = new mysqli($db_host,$db_user,$db_psw,$db_name); 


echo "---short thold---\n";
for($i = 0; $i < 47; $i++)
{
	$query = "SELECT (SUM(sthold) - MAX(sthold) - MIN(sthold))/(COUNT(*)-2) as _avg 
			FROM $tb_log
			WHERE ringidx=$i AND sthold>0";

	$result = $db->query($query);

	if($result)
	{
		if($result->num_rows > 0)
		{
			$row = $result->fetch_array(MYSQLI_ASSOC);

			$sthold = $row['_avg'] + 0.0005;
			echo "$i -> avg: ".$row['_avg']." thold: ".$sthold."\n";
			
			udatethold($db, $tb_thold, "sthold", $sthold, $i);
		}
	}
}


echo "---long thold---\n";
for($i = 0; $i < 47; $i++)
{
	$query = "SELECT (SUM(lthold) - MAX(lthold) - MIN(lthold))/(COUNT(*)-2) as _avg 
			FROM $tb_log
			WHERE ringidx=$i AND lthold>0";

	$result = $db->query($query);

	if($result)
	{
		if($result->num_rows > 0)
		{
			$row = $result->fetch_array(MYSQLI_ASSOC);

			$lthold = $row['_avg'] - 0.0005;
			echo "$i -> avg: ".$row['_avg']." thold: ".$lthold."\n";
			
			udatethold($db, $tb_thold, "lthold", $lthold, $i);
		}
	}
}

function udatethold($db, $table, $field, $value, $ringidx)
{
	$query = "update $table set $field=$value where ringidx=$ringidx";
	$db->query($query);
}

?>