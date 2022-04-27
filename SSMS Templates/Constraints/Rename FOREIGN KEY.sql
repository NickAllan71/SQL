IF OBJECT_ID('<CurrentForeignKeyName, , >', 'F') IS NOT NULL
	EXEC sys.sp_rename @objname = N'<SchemaName, SYSNAME, dbo>.<CurrentForeignKeyName, , >',
		@newname = N'<NewForeignKeyName, SYSNAME, FK_>';