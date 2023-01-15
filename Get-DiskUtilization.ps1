$ErrorActionPreference = "Continue"; 

$reportPath = ".\";  
$reportName = "DiskUtilization.html"; 
$hcReport = $reportPath + $reportName 

# Set your warning and critical thresholds 
$percentWarning = 30; 
$percentCritcal = 80; 

$redColor = "#FF0000" 
$orangeColor = "#FBB917" 
$whiteColor = "#00FF00"

$computers =  Get-Content .\serverlist.txt

If (Test-Path $hcReport) { Remove-Item $hcReport } 
 
$titleDate = (Get-Date ).ToString('yyyy/MM/dd') + " - " + (Get-Date).DayOfWeek
$header = " 
	<html> 
	<head> 
	<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'> 
	<title>Disk Utilization</title> 
	<STYLE TYPE='text/css'> 
	<!-- 
	td { 
	font-family: Tahoma; 
	font-size: 11px;
    color: #d2f5ff;
	border-top: 0px solid #999999; 
	border-right: 0px solid #999999; 
	border-bottom: 0px solid #999999; 
	border-left: 0px solid #999999; 
	padding-top: 5px; 
	padding-right: 1px; 
	padding-bottom: 5px; 
	padding-left: 5px; 
	} 
	body { 
	margin-left: 5px; 
	margin-top: 5px; 
	margin-right: 0px; 
	margin-bottom: 10px; 
	table { 
	border: thin solid #000000;
    border-collapse: collapse;
	} 
	--> 
	</style> 
	</head> 
	<body> 
	<table width='100%'> 
	<tr bgcolor='#36304a'> 
	<td colspan='7' height='25' align='center'> 
	<font face='tahoma' color='#d2f5ff' size='4'><strong>Disk Utilization - $titledate</strong></font> 
	</td> 
	</tr> 
    </table>
    <br/> 
	" 
Add-Content $hcReport $header 

$tableHeader = " 
    <table width='100%'><tbody> 
    <tr bgcolor='#36304a'> 
	<td colspan='7' height='20' align='center'> 
	<font face='tahoma' color='#d2f5ff' size='2'><strong>DISK SPACE</strong></font> 
	</td> 
	</tr> 
	<tr bgcolor=#36304a> 
	<td width='10%' align='center'>SERVER</td> 
	<td width='5%' align='center'>DRIVE</td> 
	<td width='15%' align='center'>DRIVE LABEL</td> 
	<td width='10%' align='center'>TOTAL CAPACITY(GB)</td> 
	<td width='10%' align='center'>USED CAPACITY(GB)</td> 
	<td width='10%' align='center'>FREE SPACE(GB)</td> 
	<td width='10%' align='center'>FREE SPACE %</td> 
	</tr> 
	" 
Add-Content $hcReport $tableHeader 
  
foreach($computer in $computers) 
{  
	$disks = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk -Filter "DriveType = 3" 
	$computer = $computer.toupper() 
	foreach($disk in $disks) 
	{         
		$deviceID = $disk.DeviceID; 
		$volName = $disk.VolumeName; 
		[float]$size = [Math]::Round($disk.Size, 2); 
		[float]$freespace = [Math]::Round($disk.FreeSpace, 2);  
		$percentFree = [Math]::Round(($freespace / $size) * 100, 2); 
		$sizeGB = [Math]::Round($size / 1073741824, 2); 
		$freeSpaceGB = [Math]::Round($freespace / 1073741824, 2); 
		$usedSpaceGB = [Math]::Round($sizeGB - $freeSpaceGB, 2);
		$color = $whiteColor; 
 
		if($percentFree -lt $percentWarning)       
		{ 
			$color = $orangeColor  

			if($percentFree -lt $percentCritcal) 
			{ 
				$color = $redColor 
			}         
		} 
		$dataRow = " 
		<tr> 
		<td width='10%' bgcolor='#36304a'>$computer</td> 
		<td width='5%' bgcolor='#36304a' align='center'>$deviceID</td> 
		<td width='15%' bgcolor='#36304a'>$volName</td> 
		<td width='10%' align='center' bgcolor='#36304a'>$sizeGB</td> 
		<td width='10%' align='center' bgcolor='#36304a'>$usedSpaceGB</td> 
		<td width='10%' align='center' bgcolor='#36304a'>$freeSpaceGB</td> 
		<td width='5%' bgcolor=`'$color`' align='center'><font color='#36304a'>$percentFree</font></td> 
		</tr> 
		" 
		Add-Content $hcReport $dataRow; 
	} 
} 

$tableDescription = " 
	</table><br><table width='20%'> 
    <table width=30%>
    <tr bgcolor='White'> 
	<td width='50%' align='center' bgcolor='#FBB917'>Warning less than 15% free space</td> 
	<td width='50%' align='center' bgcolor='#FF0000'>Critical less than 10% free space</td> 
    </tr>
    </table>
	" 
Add-Content $hcReport $tableDescription
Add-Content $hcReport "</body></html>" 
