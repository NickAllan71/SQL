IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = '<CurrentIndexName, SYSNAME, IX_>' AND [object_id] = OBJECT_ID('<SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, TableName>', 'U'))
	EXEC sys.sp_rename @objname = N'<SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, TableName>.<CurrentIndexName, , >',
		@newname = N'<NewIndexName, SYSNAME, IX_>',
		@objtype = N'INDEX';