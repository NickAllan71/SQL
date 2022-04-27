DECLARE @<IdColumnName, sysname, Id> INT,
	@MaxId INT,
	@BatchSize INT = 10000;
SELECT @<IdColumnName, sysname, > = MIN(<IdColumnName, sysname, >),
	@MaxId = MAX(<IdColumnName, sysname, >)
	FROM <SchemaTableName, sysname, YourTable>;
WHILE @<IdColumnName, sysname, > <= @MaxId
BEGIN;
	DECLARE @<FirstColumnName, sysname, YourFirstColumn> <FirstColumnType, sysname, INT>;
	SELECT @<FirstColumnName, , > = <FirstColumnName, , >
		FROM <SchemaTableName, , >
		WHERE <IdColumnName, , > BETWEEN @<IdColumnName, , > AND @<IdColumnName, , > + @BatchSize - 1;
	
	SET @<IdColumnName, , > += @BatchSize;
END;