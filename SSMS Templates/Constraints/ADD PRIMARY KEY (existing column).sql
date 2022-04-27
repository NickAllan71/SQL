ALTER TABLE <SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, YourTableName>
	DROP CONSTRAINT IF EXISTS PK_<TableName, , >;
GO
ALTER TABLE <SchemaName, SYSNAME, >.<TableName, , >
	ADD CONSTRAINT PK_<TableName, , > PRIMARY KEY (<PrimaryKeyColumn, SYSNAME, YourColumn>);