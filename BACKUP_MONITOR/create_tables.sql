CREATE TABLE [dbo].[DB_Servers] (
    [DB_Instance] [nvarchar](40) NOT NULL,
    CONSTRAINT [PK_DB_Servers] PRIMARY KEY (DB_Instance)
)
GO
 
CREATE TABLE [dbo].[DB_Status](
[InstanceName] [varchar](50) NOT NULL,
[DatabaseName] [varchar](50) NOT NULL,
[RecoveryMode] [varchar](12) NULL,
[DatabaseStatus] [varchar](15) NULL,
[CreationTime] [datetime] NULL,
[LastFull] [datetime] NULL,
[LastLog] [datetime] NULL,
[LastUpdate] [datetime] NULL,
    PRIMARY KEY CLUSTERED ([InstanceName] ASC,[DatabaseName] ASC)
)
GO
 
CREATE TABLE [dbo].[DB_Backup_Exceptions](
[InstanceName] [varchar](50) NOT NULL,
[DatabaseName] [varchar](50) NOT NULL,
[LastFullHours] [int] NULL,
[LastLogHours] [int] NULL,
[Description] [varchar](250) NULL,
[BestBefore] [datetime] NULL,
    PRIMARY KEY CLUSTERED ([InstanceName] ASC,[DatabaseName] ASC)
)
GO
