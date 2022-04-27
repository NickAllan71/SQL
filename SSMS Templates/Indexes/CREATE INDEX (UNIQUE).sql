
CREATE UNIQUE <CLUSTERED, or, NONCLUSTERED> INDEX UI_<TableName, SYSNAME, #YourTableName>_<FirstColumnName, SYSNAME, YourColumnName>
	ON <SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, > (
		<FirstColumnName, SYSNAME, >
		)
	WITH (ONLINE = ON);