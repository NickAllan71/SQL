
DECLARE @<IdColumnName, sysname, Id> INT,
	@MaxId INT;
SELECT @<IdColumnName, sysname, > = MIN(<IdColumnName, sysname, >),
	@MaxId = MAX(<IdColumnName, sysname, >)
	FROM <SchemaTableName, sysname, YourTable>;
WHILE @<IdColumnName, sysname, > <= @MaxId
BEGIN;
	DECLARE @<FirstColumnName, sysname, YourFirstColumn> <FirstColumnType, sysname, >;
	SELECT @<FirstColumnName, sysname, > = <FirstColumnName, sysname, >
		FROM <SchemaTableName, sysname, >
		WHERE <IdColumnName, sysname, > = @<IdColumnName, sysname, >;
	
	SET @<IdColumnName, sysname, > += 1;
END;