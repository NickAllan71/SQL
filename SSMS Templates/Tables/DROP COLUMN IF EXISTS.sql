ALTER TABLE <SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, YourTable>
	DROP CONSTRAINT IF EXISTS DF_<TableName, , >_<ColumnName, SYSNAME, YourColumn>;
ALTER TABLE <SchemaName, , >.<TableName, , >
	DROP COLUMN IF EXISTS <ColumnName, , >;
