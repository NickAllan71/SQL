DROP TABLE IF EXISTS <SchemaName, SYSNAME, import>.Map_<TableSuffix, SYSNAME, YourSuffix>;
GO
CREATE TABLE <SchemaName, , >.Map_<TableSuffix, , >
	(
	MappingId INT NOT NULL CONSTRAINT PK_Map_<TableSuffix, , > PRIMARY KEY IDENTITY,
	From_<FromColumn, SYSNAME, SourceColumn> <FromColumnType, , NVARCHAR()> NOT NULL,
	To_<ToColumn, SYSNAME, DestinationColumn> <ToColumnType, , INT> NOT NULL,
	CreatedDateTime DATETIME NOT NULL CONSTRAINT DF_Map_<TableSuffix, , >_CreatedDateTime DEFAULT GETDATE()
	);
CREATE UNIQUE NONCLUSTERED INDEX UI_Map_<TableSuffix, , >_From_<FromColumn, , >
	ON <SchemaName, , >.Map_<TableSuffix, , > (
		From_<FromColumn, , >
		);

DROP TABLE IF EXISTS #Mapping;
CREATE TABLE #Mapping
	(
	From_<FromColumn, , > <FromColumnType, , > NOT NULL,
	To_<ToColumn, , > <ToColumnType, , > NOT NULL
	);

INSERT <SchemaName, , >.Map_<TableSuffix, , >
	(
	From_<FromColumn, , >,
	To_<ToColumn, , >
	)
	SELECT From_<FromColumn, , >,
		To_<ToColumn, , >
		FROM #Mapping;