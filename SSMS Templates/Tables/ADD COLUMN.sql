
ALTER TABLE <SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, YourTable>
	DROP CONSTRAINT IF EXISTS DF_<TableName, , >_<ColumnName, SYSNAME, YourNewColumn>;
ALTER TABLE <SchemaName, , >.<TableName, , >
	DROP COLUMN IF EXISTS <ColumnName, , >;
ALTER TABLE <SchemaName, , >.<TableName, , >
	ADD <ColumnName, , > <ColumnType, SYSNAME, INT> <Nullability, , NULL or NOT NULL>;