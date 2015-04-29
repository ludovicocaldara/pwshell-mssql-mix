param ( $ServerInstance, $Database, $Username, $Password )

## add required snap-in to query sqlserver
if ( (Get-PSSnapin -Name sqlserverprovidersnapin100 -ErrorAction SilentlyContinue) -eq $null ) {
    Add-PsSnapin sqlserverprovidersnapin100 
}
if ( (Get-PSSnapin -Name sqlservercmdletsnapin100 -ErrorAction SilentlyContinue) -eq $null ) {
    Add-PsSnapin sqlservercmdletsnapin100
}

######################
# Getting Parameters #
######################
if ( -not $ServerInstance) { $ServerInstance = Read-Host 'Instance Name? ' }
if ( -not $Database) { $Database = Read-Host 'Database Name? ' }
if ( $Username -and $Password ) {
	"Connecting as $Username"
} else {
	$whoami = [Environment]::UserName
	"Connecting as Windows User $whoami"
}

$files = Get-ChildItem . -filter *.sql -recurse 

foreach ($file in $files ) {
	" "
	"################################"
	" "
	$filename= $file | select-object fullname
	$InputFile = $filename.fullname

	"Preparing to execute script: $InputFile"
	if ( $Username -and $Password ) {
		$loginopts = "-U $Username -P $Password"
	} else {
		$loginopts = "-E"
	}

	# -b = exit with error code if sql error
	# -I = enable quote identifiers (default on SSMS)
	# -a = packetsize to optimize network utilization
	$cmd = "sqlcmd -S $ServerInstance -d $Database $loginopts -a 16768 -b -i ""$InputFile"" -o ""$inputfile.txt"" -I"
	$cmd

	Invoke-Expression $cmd
	$result = $lastexitcode
	$result
	if ( $result -eq 0 ) {
		"Script $InputFile ran successfully."
		# renaming successful .sql to .sql.done to mark it as executed and allow new runs
		Rename-Item $InputFile $InputFile".done"
	} else {
		">>>>>>>>>>> Error running script $file. <<<<<<<<<<"
		" "
		get-content "$inputfile.txt"
		" "
		">>>>>>>>>>> Error running script $file. <<<<<<<<<<"
		break
	}
}
