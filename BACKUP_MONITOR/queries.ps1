
$query_bck_database = "select	[Database]       = s.db, 
	    [RecoveryMode]   = DATABASEPROPERTYEX(d.name, 'Recovery'),
	    [CreationTime]   = d.crdate,
	    [Status]         = DATABASEPROPERTYEX(d.name, 'Status'),
	    [LastFull]       = s.finish,
	    [LastFullDevice] = s.device,
	    [LastFullDevTyp] = s.devtyp ,
	    [LastLog]        = c.logfinish,
	    [LastLogDevice]  = c.logdevice,
	    [LastLogDevTyp]  = c.logdevtyp
  from  master.dbo.sysdatabases d
left outer join
  (
	select [DB]     = s.database_name,
           [Type]   = s.type,
           [Finish] = convert(varchar,s.backup_finish_date,120),
           [Device] = f.physical_device_name,
           [DevTyp] = f.device_type,
           [Size]   = s.backup_size
	from msdb.dbo.backupset s, msdb.dbo.backupmediafamily f
         where 
         s.media_set_id=f.media_set_id
  ) s
on d.name=s.db
inner join (
	select db,
		type,
		maxfinish=MAX(finish)
	from
		(
		select [DB]     = s.database_name,
	           [Type]   = s.type,
			   [Finish] = convert(varchar, s.backup_finish_date, 120)
		from msdb.dbo.backupset s, msdb.dbo.backupmediafamily f
			where 
			s.media_set_id=f.media_set_id
		) a1
	 where type='D'
	group by db, type
	) s1
    on s1.db = s.db
      and s1.maxfinish = s.finish
      and s.Type = s1.type
left outer join
    (select l.db,
		logfinish = l.finish,
		logtype   = l.type,
		logdevice = l.device,
		logdevtyp = l.devtyp
	  from
	  	(
	    select [DB]     = s.database_name,
               [Type]   = s.type,
               [Finish] = convert(varchar,s.backup_finish_date,120),
               [Device] = f.physical_device_name,
               [DevTyp] = f.device_type
			from msdb.dbo.backupset s, msdb.dbo.backupmediafamily f
				where 
				s.media_set_id=f.media_set_id
		) l
	inner join
		(select db,
			type,
			maxfinish=MAX(finish)
		from 
			(
			select [DB]     = s.database_name,
				   [Type]   = s.type,
			       [Finish] = convert(varchar, s.backup_finish_date, 120)
		    from msdb.dbo.backupset s, msdb.dbo.backupmediafamily f
				where 
				s.media_set_id=f.media_set_id
			) b1
				where type='L'
			group by db, type
		) l1
    on l1.db=l.db
      and l1.maxfinish=l.finish
      and l.Type=l1.type
    ) c
on s.DB=c.db";
