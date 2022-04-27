
CREATE <CLUSTERED, or, NONCLUSTERED> INDEX IX_<TableName, SYSNAME, #YourTableName>_<FirstColumnName, SYSNAME, YourColumnName>
	ON <SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, > (
		<FirstColumnName, SYSNAME, >
		)
	WITH (ONLINE = ON);