ALTER TABLE <SchemaName, SYSNAME, dbo>.<TableName, SYSNAME, YourTable>
	DROP CONSTRAINT IF EXISTS CK_<TableName, , >_<ColumnName, SYSNAME, YourColumn>_<DescriptiveSuffix, SYSNAME, YourSuffix>;
GO
ALTER TABLE <SchemaName, , >.<TableName, , >
	ADD CONSTRAINT CK_<TableName, , >_<ColumnName, , >_<DescriptiveSuffix, , > CHECK (<ColumnName, , > <CheckLogic, E.g., IS NOT NULL>);
GO