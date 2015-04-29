set-location "K:\TOOLS\CHECK_SQL\"

### environment to insert results/get lists
$serverName = "SERVER01\MSSQL01" 
$databaseName = "Tools"


## initialise a file with some variables containing queries (to offload the script)
. .\queries.ps1


## initialise a class to better manage database backups as objects
. .\DatabaseBackup.ps1

## add required snap-in to query sqlserver
if ( (Get-PSSnapin -Name sqlserverprovidersnapin100 -ErrorAction SilentlyContinue) -eq $null ) {
    Add-PsSnapin sqlserverprovidersnapin100 
}
if ( (Get-PSSnapin -Name sqlservercmdletsnapin100 -ErrorAction SilentlyContinue) -eq $null ) {
    Add-PsSnapin sqlservercmdletsnapin100
}


function getDatabaseBackups ([String]$instance) {

  Write-Output "    Instance: $instance"
  $databases = invoke-sqlcmd -Query  $query_bck_database -Server $instance

  
  $i = 0
  foreach ( $database in $databases ) {
    $dbbck = new-object DatabaseBackup
    $dbbck.instanceName = $instance
    $dbbck.databaseName = $database.Database
    $dbbck.recoveryMode = $database.RecoveryMode
    $dbbck.creationTime = $database.CreationTime
    $dbbck.status = $database.Status
    if ( -not ( $database.IsNull("LastFull") ) ) {
      $dbbck.lastFull = $database.LastFull
    } else {
      $dbbck.lastFull = "01.01.1900 00:00:00"
    }
    if ( -not ( $database.IsNull("LastTran") ) ) {
      $dbbck.lastLog = $database.LastTran
    } else {
      $dbbck.lastLog = "01.01.1900 00:00:00"
    }

    [DatabaseBackup[]]$databasebackups += $dbbck
  }
  return $databasebackups
}


$Connection = New-Object System.Data.SQLClient.SQLConnection
$Connection.ConnectionString ="Server=$serverName;Database=$databaseName;trusted_connection=true;"
$Connection.Open()

$Command = New-Object System.Data.SQLClient.SQLCommand
$Command.Connection = $Connection

$instances = invoke-sqlcmd -Query "select [name]=db_instance from db_servers" -ServerInstance $serverName -Database $databasename

foreach ( $instance in $instances ) {

  $databasebackups = getDatabaseBackups ($instance.name);
  # $databasebackups

  $databasebackups[1..($databasebackups.length-1)] | foreach {

	$_ | select-object instanceName,databaseName

    $Command.CommandText = "MERGE DB_Status as target USING (
  select '$($_.instanceName )','$($_.databaseName )','$($_.recoveryMode )','$($_.status )','$($_.creationTime)','$($_.lastFull)','$($_.lastLog)')
  as source (InstanceName, DatabaseName, RecoveryMode, DatabaseStatus, CreationTime, LastFull, LastLog)
ON (source.InstanceName=target.InstanceName and source.DatabaseName=target.DatabaseName)
 WHEN MATCHED THEN
  UPDATE SET RecoveryMode = source.RecoveryMode, DatabaseStatus = source.DatabaseStatus, CreationTime = source.CreationTime,
   LastFull = source.LastFull, LastLog = source.LastLog, LastUpdate=getdate()
 WHEN NOT MATCHED THEN
  INSERT (InstanceName, DatabaseName, RecoveryMode, DatabaseStatus, CreationTime, LastFull, LastLog, LastUpdate)
   VALUES (source.InstanceName, source.DatabaseName,source.RecoveryMode,source.DatabaseStatus, source.CreationTime, source.LastFull,source.LastLog,getdate() );
"
    # $Command.CommandText
    $Command.ExecuteNonQuery() | out-null
  }
  Remove-Variable databasebackups
}

$Connection.Close()
