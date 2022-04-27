ALTER TABLE <SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, YourTable>
	DROP CONSTRAINT IF EXISTS DF_<TableName, , >_<ColumnName, SYSNAME, YourColumn>;
GO
ALTER TABLE <SchemaName, , >.<TableName, , >
	ADD CONSTRAINT DF_<TableName, , >_<ColumnName, , >
	DEFAULT <DefaultValue, E.g., 0>
	FOR <ColumnName, , >;
