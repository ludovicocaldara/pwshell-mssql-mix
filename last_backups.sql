with
db as (
select [Instance] = @@SERVERNAME,
[Database]  = name,
    [RecoveryMode]   = DATABASEPROPERTYEX(name, 'Recovery'),
    [CreationTime]   = crdate,
    [Status]         = DATABASEPROPERTYEX(name, 'Status')
from master..sysdatabases
where name!='tempdb'
),
lastfull as	(
select * from (
select [Database]     = s.database_name,
--[Type]   = s.type,
[LastFullDate] = convert(varchar, s.backup_finish_date, 120),
[LastFullSize]   = s.backup_size,
[LastFullDevice] = f.physical_device_name,
        [LastFullDevTyp] = f.device_type,
[Nrank] = rank() over (partition by s.database_name order by s.backup_finish_date desc)
from msdb.dbo.backupset s, msdb.dbo.backupmediafamily f
where
         s.media_set_id=f.media_set_id
and s.type='D'
-- and f.device_type = 7 -- only backup devices
) f
where nrank=1
),
lastlog as (
select * from (
select [Database]     = s.database_name,
--[Type]   = s.type,
[LastLogDate] = convert(varchar, s.backup_finish_date, 120),
[LastLogSize]   = s.backup_size,
[LastLogDevice] = f.physical_device_name,
        [LastLogDevTyp] = f.device_type,
[Nrank] = rank() over (partition by s.database_name order by s.backup_finish_date desc)
from msdb.dbo.backupset s, msdb.dbo.backupmediafamily f
where
         s.media_set_id=f.media_set_id
and s.type='L'
-- and f.device_type = 7 -- only backup devices
) l
where nrank=1
)
select db.[Instance],db.[Database], db.[RecoveryMode], db.[CreationTime], db.[Status],
lastfull.[LastFullDate], lastfull.[LastFullSize],
        lastfull.[LastFullDevice], lastfull.[LastFullDevTyp],
lastlog.[LastLogDate], lastlog.[LastLogSize], lastlog.[LastLogDevice], lastlog.[LastLogDevTyp]
from db
left outer join lastfull
on (db.[Database]=lastfull.[Database])
left outer join lastlog
on (db.[Database]=lastlog.[Database])
