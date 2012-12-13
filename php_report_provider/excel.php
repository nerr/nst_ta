<?php
//-- Error reporting 
error_reporting(E_ALL);
ini_set('display_errors', false);
ini_set('display_startup_errors', false);
date_default_timezone_set('Asia/Shanghai');


//-- get data from sqlite
$dbfile = 'D:\Documents\alpariukswaptest.db';
$db = new SQLite3($dbfile);
$results = $db->query('SELECT * FROM dayinfo ORDER BY datetime');
while ($row = $results->fetchArray()) //--
{
	$datestring = substr($row['datetime'], 0, 10);
	$datestring = str_replace('.', '-', $datestring);

	$data[$datestring][$row['symbol']]['swap'] 		+= $row['swap'];
	$data[$datestring][$row['symbol']]['profit'] 	+= $row['profit'];
	$data[$datestring][$row['symbol']]['commission']+= $row['commission'];
	$data[$datestring][$row['symbol']]['size'] 		+= $row['size'];

	$data[$datestring][$row['symbol']]['closeprice'] = $row['closeprice'];

	$total[$datestring]['swap'] 		+= $row['swap'];
	$total[$datestring]['profit'] 		+= $row['profit'];
	$total[$datestring]['commission']	+= $row['commission'];
	$total[$datestring]['size'] 		+= $row['size'];
}

//-- reorganize data
reset($total);
for($i = 0; $i < count($total); $i++)
{
	
	list($date, $symbols) = each($total);

	$total[$date]['totalall'] = array_sum($total[$date]);
	$total[$date]['totalall'] -= $total[$date]['size'];
	$total[$date]['fpi'] = $data[$date]['USDJPY']['closeprice'] / ($data[$date]['USDMXN']['closeprice'] * $data[$date]['MXNJPY']['closeprice']);

	$dateArr[$i] = $date;

	if(isset($dateArr[$i-1]))
		$total[$date]['newswap'] = $total[$date]['swap'] - $total[$dateArr[$i-1]]['swap'];
	else
		$total[$date]['newswap'] = 0;
}

//-- output excel file
define('EOL',(PHP_SAPI == 'cli') ? PHP_EOL : '<br />');
require_once './classes/PHPExcel.php';
require_once './classes/PHPExcel/Cell/AdvancedValueBinder.php';

$excelname = "nst_ta_swap_report_".date('Y-m-d');

// Create new PHPExcel object
echo date('H:i:s') , " Create new PHPExcel object" , EOL;
$objPHPExcel = new PHPExcel();
PHPExcel_Cell::setValueBinder( new PHPExcel_Cell_AdvancedValueBinder());
$objDrawing = new PHPExcel_Worksheet_Drawing(); 

// Set document properties
echo date('H:i:s') , " Set document properties" , EOL;
$objPHPExcel->getProperties()->setCreator("Nerrsoft.com")
							 ->setLastModifiedBy("Nerrsoft.com")
							 ->setTitle("NST_TA_SWAP_Report")
							 ->setSubject("NST_TA_SWAP_Report")
							 ->setDescription("NST_TA_SWAP_Report")
							 ->setKeywords("forex report")
							 ->setCategory("Report");


// Add some data
echo date('H:i:s') , " Add some data" , EOL;

// Set active sheet index to the first sheet, so Excel opens this as the first sheet
$sheet = $objPHPExcel->setActiveSheetIndex(0);

$c = "ABCDEFGHIJKLMNOPQRST";


//-- fill header
$sheet->setCellValue('A2', 'date/info'); $sheet->mergeCells('A2:A3');
$sheet->setCellValue('N2', 'Close FPI'); $sheet->mergeCells('N2:N3');
$sheet->setCellValue('O2', 'New Swap'); $sheet->mergeCells('O2:O3');
$sheet->setCellValue('T2', 'Total All'); $sheet->mergeCells('T2:T3');
$sheet->setCellValue('P2', 'Total'); $sheet->mergeCells('P2:S2');
$sheet->setCellValue('P3', 'Swap');
$sheet->setCellValue('Q3', 'Profit');
$sheet->setCellValue('R3', 'Commission');
$sheet->setCellValue('S3', 'Size');
//-- file date and header
$j = 0;
$l = 4;
for($i = 0; $i < count($data); $i++)
{
	list($date, $symbols) = each($data);
	$n = 0;
	//-- fill date
	$sheet->setCellValue($c{$n}.$l, $date);
	$sheet->getStyle($c{$n}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_DATE_YYYYMMDD);
	$n++;

	foreach($symbols as $symbolname=>$detail)
	{
		//-- fill header
		if($i == 0) 
		{
			$sheet->setCellValue($c{$j+1}.'2', $symbolname);
			$sheet->mergeCells($c{$j+1}.'2:'.$c{$j+4}.'2');
			$sheet->setCellValue($c{$j+1}.'3', "Swap");
			$sheet->setCellValue($c{$j+2}.'3', "Profit");
			$sheet->setCellValue($c{$j+3}.'3', "Commission");
			$sheet->setCellValue($c{$j+4}.'3', "Size");
			$j += 4;
		}

		//-- fill main data
		foreach($detail as $item=>$value)
		{
			if($item == 'closeprice')
				continue;
			$sheet->setCellValue($c{$n}.$l, $value);
			$sheet->getStyle($c{$n}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_00);
			$n++;
		}
		//-- fill total data
		$sheet->setCellValue($c{$n}.$l, round($total[$date]['fpi'], 6));
		$sheet->getStyle($c{$n}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_GENERAL);

		$sheet->setCellValue($c{$n+1}.$l, $total[$date]['newswap']);
		$sheet->getStyle($c{$n+1}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_00);

		$sheet->setCellValue($c{$n+2}.$l, $total[$date]['swap']);
		$sheet->getStyle($c{$n+2}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_00);

		$sheet->setCellValue($c{$n+3}.$l, $total[$date]['profit']);
		$sheet->getStyle($c{$n+3}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_00);

		$sheet->setCellValue($c{$n+4}.$l, $total[$date]['commission']);
		$sheet->getStyle($c{$n+4}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_00);

		$sheet->setCellValue($c{$n+5}.$l, $total[$date]['size']);
		$sheet->getStyle($c{$n+5}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_00);

		$sheet->setCellValue($c{$n+6}.$l, $total[$date]['totalall']);
		$sheet->getStyle($c{$n+6}.$l)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_00);
	}
	$l++;
}

//-- style
$lastline = 3 + count($total); //-- lastline 

$style_allborders = array('allborders' => array('style' => PHPExcel_Style_Border::BORDER_THIN));

//-- header
$sheet->getStyle("A2:T3")->applyFromArray(
	array(
		'fill' => array(
			'type'  => PHPExcel_Style_Fill::FILL_SOLID,
			'color' => array('argb' => '99CC00')
		),
		'borders' => $style_allborders,
		'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
		'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
		'rotation' => 0,
		'alignment' => array('wrap' => true),
		'font' => array(
			'color' => array( 'rgb' => PHPExcel_Style_Color::COLOR_BLACK),
			'size' => '11',
			'bold' => true,
		),
	)
);


//-- date
$sheet->getStyle("A3:A".$lastline)->applyFromArray(
	array(
		'borders' => $style_allborders
	)
);
//-- data
$sheet->getStyle('B4:M'.$lastline)->applyFromArray(
	array(
		'fill' => array(
			'type'  => PHPExcel_Style_Fill::FILL_SOLID,
			'color' => array('argb' => 'CCFFFF')
		),
		'borders' => $style_allborders
	)
);
//-- total
$sheet->getStyle("N4:T".$lastline)->applyFromArray(
	array(
		'fill' => array(
			'type'  => PHPExcel_Style_Fill::FILL_SOLID,
			'color' => array('argb' => 'FFFF99')
		),
		'borders' => $style_allborders
	)
);



//-- auto set width
for($i = 0; $i < strlen($c); $i++)
{
	$sheet->getColumnDimension($c{$i})->setAutoSize(true);
}

//-- draw logo
//$objDrawing = new PHPExcel_Worksheet_Drawing();
$lastline += 5;
$objDrawing->setName('Logo');
$objDrawing->setDescription('Logo');
$objDrawing->setPath('./images/logo_new.png');
$objDrawing->setHeight(104);
$objDrawing->setCoordinates('P'.$lastline);
$objDrawing->setOffsetX(110);
//$objDrawing->setRotation(25);
$objDrawing->setWorksheet($objPHPExcel->getActiveSheet());

// Rename worksheet
echo date('H:i:s') , " Rename worksheet" , EOL;
$objPHPExcel->getActiveSheet()->setTitle('report');

// Save Excel 2007 file
echo date('H:i:s') , " Write to Excel2007 format" , EOL;
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
$objWriter->save($excelname.'.xlsx');
echo date('H:i:s') , " File written to " , str_replace('.php', '.xlsx', pathinfo(__FILE__, PATHINFO_BASENAME)) , EOL;

// Echo memory peak usage
echo date('H:i:s') , " Peak memory usage: " , (memory_get_peak_usage(true) / 1024 / 1024) , " MB" , EOL;
// Echo done
echo date('H:i:s') , " Done writing files" , EOL;
echo 'Files have been created in ' , getcwd() , EOL;

?>