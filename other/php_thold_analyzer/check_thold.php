<?php
$account  = $argv[1];
$mqlver = $argv[2]; // -- 4 or 5

$db_host = "localhost";
$db_user = "root";
$db_psw  = "911911";
$db_name = "metatrader";

$tb_fpi = "nst_ta_fpi_".$account;
$tb_thold = "nst_ta_thold_".$account;

$db = new mysqli($db_host, $db_user, $db_psw, $db_name);


//--
$begin = 0;
$result = $db->query("SELECT MAX(ringidx) as _max FROM $tb_fpi limit 200");
if($result)
{
	$result->data_seek(1);
	$row = $result->fetch_array(MYSQLI_ASSOC);
	$end = $row['_max'];
}

if($mqlver!=5)
{
	$begin++;
	$end++;
}

echo $tb_fpi."\n";
echo $end."\n";


//--
echo "---short thold---\n";
for($i = $begin; $i < $end; $i++)
{
	$db->query("INSERT IGNORE INTO $tb_thold (`ringidx`) VALUES ($i)");

	$query = "SELECT (SUM(sfpi) - MAX(sfpi) - MIN(sfpi))/(COUNT(*)-2) as _avg 
			FROM $tb_fpi
			WHERE ringidx=$i AND sfpi>0";

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
for($i = $begin; $i < $end; $i++)
{
	$query = "SELECT (SUM(lfpi) - MAX(lfpi) - MIN(lfpi))/(COUNT(*)-2) as _avg 
			FROM $tb_fpi
			WHERE ringidx=$i AND lfpi>0";

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