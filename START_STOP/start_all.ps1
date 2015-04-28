$compArray = get-content k:\tools\stop_all\list.txt

foreach($strComputer in $compArray) {
	# Get-WMIObject Win32_Service  | Where-Object{$_.name -match ".*mssql\$.*" }
	# Get-WMIObject Win32_Service -ComputerName $strComputer |  Where-Object{$_.name -match ".*mssql\$.*" } | get-member

	" "
	" "
	"Current Status on "+$strComputer
	Get-WMIObject Win32_Service  -Computername $strComputer | Where-Object{$_.name -match ".*mssql\$.*" } | Sort-Object -Property Name | Format-Table Name, StartName, startmode, state, status
	$sqlservices = get-service -computername $strComputer -name MSSQL$*

	foreach($sqlservice in $sqlservices) {
		Get-WMIObject Win32_Service  -Computername $strComputer | Where-Object{$_.name -eq $sqlservice.Servicename } | Format-Table Name, StartName, startmode, state, status


		$confirmString = "Start Service: "+$sqlservice.ServiceName+" on $strComputer ? (Y/N) "
		$confirm = Read-Host $confirmString

		if ($confirm -eq 'Y' ) {
			"Starting Service: "+$sqlservice.ServiceName+" on $strComputer"
			$sqlservice.start()

		}
	}
	sleep 5
	" "
	"Current Status on "+$strComputer
	Get-WMIObject Win32_Service  -Computername $strComputer | Where-Object{$_.name -match ".*mssql\$.*" } | Sort-Object -Property Name | Format-Table Name, StartName, startmode, state, status
}
