DROP TABLE IF EXISTS <SchemaName, SYSNAME, dbo>.<TablePrefix, SYSNAME, YourPrefix>_<TableSuffix, SYSNAME, YourSuffix>;
GO
CREATE TABLE <SchemaName, , >.<TablePrefix, ,>_<TableSuffix, , >
	(
	<TableSuffix, , >Id INT NOT NULL CONSTRAINT PK_<TablePrefix, ,>_<TableSuffix, , > PRIMARY KEY IDENTITY,
	<FirstColumn, SYSNAME, YourFirstColumnName> INT NOT NULL,
	CreatedDateTime DATETIME NOT NULL CONSTRAINT DF_<TablePrefix, ,>_<TableSuffix, , >_CreatedDateTime DEFAULT GETDATE()
	);
GO
IF OBJECT_ID('dbo.usp_Standard_TableAlias_Create', 'P') IS NOT NULL
	EXEC dbo.usp_Standard_TableAlias_Create @SchemaTableName = '<SchemaName, , >.<TablePrefix, ,>_<TableSuffix, , >',
		@TableAlias = '<TableAlias, SYSNAME, YourTableAlias>';