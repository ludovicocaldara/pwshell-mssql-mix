$compArray = get-content k:\tools\stop_all\list_full.txt

foreach($strComputer in $compArray) {
	" "
	$strComputer
	Get-WMIObject Win32_Service  -Computername $strComputer | Where-Object{$_.name -match ".*sql.*\$.*" } | Sort-Object -Property Name | Format-Table Name, StartName, startmode, state, status
}
