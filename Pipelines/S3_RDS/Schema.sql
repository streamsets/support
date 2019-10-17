SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [stg_host](

    [pipeline.file.name] [nvarchar](512) NULL,

    [pipeline.file.date] [datetime2](7) NULL,

    [twdc.data_source_owner] [nvarchar](32) NULL,

    [table.record_max_datetime] [datetime2](7) NULL,

    [table.insert_datetime] [datetime2](7) NULL,

    [table.record_processed] [int] NULL,

    [table.record_guid] [uniqueidentifier] NULL,

    [host.id] [int] NULL,

    [host.comments] [nvarchar](max) NULL,

    [host.dns] [nvarchar](256) NULL,

    [host.ip] [nvarchar](32) NULL,

    [host.last_compliance_scan_datetime] [datetime2](7) NULL,

    [host.last_vm_auth_scanned_date] [datetime2](7) NULL,

    [host.last_vm_auth_scanned_duration] [int] NULL,

    [host.last_vm_scanned_date] [datetime2](7) NULL,

    [host.last_vm_scanned_duration] [int] NULL,

    [host.last_vuln_scan_datetime] [datetime2](7) NULL,

    [host.netbios] [nvarchar](32) NULL,

    [host.network_id] [int] NULL,

    [host.os] [nvarchar](256) NULL,

    [host.tags] [nvarchar](max) NULL,

    [host.tags.name] [nvarchar](max) NULL,

    [host.tags.tag_id] [nvarchar](max) NULL,

    [host.tracking_method] [nvarchar](16) NULL,

    [host.user_def] [nvarchar](max) NULL,

    [table.record_process_rank] [int] NULL,

    [table.run.record_processed] [int] NULL

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [stg_host] SET (LOCK_ESCALATION = DISABLE)

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-default] ON [stg_host]

(

    [twdc.data_source_owner] ASC,

    [pipeline.file.name] ASC,

    [table.record_processed] ASC,

    [host.id] ASC

)

INCLUDE (   [table.insert_datetime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-del-bydate] ON [stg_host]

(

    [twdc.data_source_owner] ASC,

    [table.record_processed] ASC,

    [pipeline.file.date] ASC

)

INCLUDE (   [pipeline.file.name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-get-loops] ON [stg_host]

(

    [twdc.data_source_owner] ASC,

    [table.record_processed] ASC,

    [table.insert_datetime] ASC

)

INCLUDE (   [pipeline.file.name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-identifiers] ON [stg_host]

(

    [twdc.data_source_owner] ASC,

    [host.id] ASC

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-merge-10] ON [stg_host]

(

    [twdc.data_source_owner] ASC,

    [pipeline.file.name] ASC,

    [table.record_processed] ASC,

    [table.insert_datetime] ASC

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-merge-guid] ON [stg_host]

(

    [twdc.data_source_owner] ASC,

    [table.record_guid] ASC

)

INCLUDE (   [table.record_process_rank]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

 

-----------------------------------

 

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

CREATE TABLE [stg_host_asset_group](

    [pipeline.file.name] [nvarchar](512) NULL,

    [pipeline.file.date] [datetime2](7) NULL,

    [twdc.data_source_owner] [nvarchar](32) NULL,

    [table.record_max_datetime] [datetime2](7) NULL,

    [table.insert_datetime] [datetime2](7) NULL,

    [table.record_guid] [uniqueidentifier] NULL,

    [table.record_processed] [int] NULL,

    [host.id] [int] NULL,

    [host.asset_group.id] [int] NULL,

    [table.record_process_rank] [int] NULL,

    [table.run.record_processed] [int] NULL

) ON [PRIMARY]

GO

ALTER TABLE [stg_host_asset_group] SET (LOCK_ESCALATION = DISABLE)

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-default] ON [stg_host_asset_group]

(

    [twdc.data_source_owner] ASC,

    [pipeline.file.name] ASC,

    [table.record_processed] ASC,

    [host.id] ASC,

    [host.asset_group.id] ASC

)

INCLUDE (   [table.insert_datetime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-del-bydate] ON [stg_host_asset_group]

(

    [twdc.data_source_owner] ASC,

    [table.record_processed] ASC,

    [pipeline.file.date] ASC

)

INCLUDE (   [pipeline.file.name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX [idx-nc-merge-00] ON [stg_host_asset_group]

(

    [table.record_guid] ASC

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-merge-10] ON [stg_host_asset_group]

(

    [twdc.data_source_owner] ASC,

    [table.record_processed] ASC,

    [table.insert_datetime] ASC

)

INCLUDE (   [host.id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-merge-guid] ON [stg_host_asset_group]

(

    [twdc.data_source_owner] ASC,

    [table.record_guid] ASC

)

INCLUDE (   [table.record_process_rank]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [idx-nc-pipeline-file-name] ON [stg_host_asset_group]

(

    [twdc.data_source_owner] ASC,

    [pipeline.file.name] DESC,

    [table.record_processed] ASC,

    [table.insert_datetime] ASC

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING ON

GO

CREATE NONCLUSTERED INDEX [nc-idx-get-loops] ON [stg_host_asset_group]

(

    [twdc.data_source_owner] ASC,

    [table.record_processed] ASC,

    [table.insert_datetime] ASC

)

INCLUDE (   [pipeline.file.name]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO





