IF EXISTS (
	SELECT 1 FROM sys.columns WHERE [object_id] = OBJECT_ID('<SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, YourTableName>', 'U') AND name = '<ColumnName, SYSNAME, Current>'
	)
	EXEC sys.sp_rename @objname = N'<SchemaName, , >.<TableName, , >.<ColumnName, , >',
		@newname = '<NewColumnName, SYSNAME, New>',
		@objtype = 'COLUMN';