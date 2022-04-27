ALTER TABLE <SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, YourTableName>
	DROP CONSTRAINT IF EXISTS PK_<TableName, , >;
ALTER TABLE <SchemaName, , >.<TableName, , >
	DROP COLUMN IF EXISTS <ColumnName, SYSNAME, Id>;
ALTER TABLE <SchemaName, , >.<TableName, , >
	ADD <ColumnName, , > <DataType, BIGINT or, INT> NOT NULL
		CONSTRAINT PK_<TableName, , > PRIMARY KEY IDENTITY;