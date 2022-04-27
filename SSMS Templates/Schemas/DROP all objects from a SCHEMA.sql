--Run this from the database you want to clear
DROP TABLE IF EXISTS #Schemas;
SELECT s.[schema_id],
	SchemaName = QUOTENAME(s.[name])
	INTO #Schemas
	FROM STRING_SPLIT('<SchemasToDrop, SYSNAME, dbo>', ',') AS d
		INNER JOIN sys.schemas AS s
			ON d.[value] = s.[name] COLLATE DATABASE_DEFAULT;

DROP TABLE IF EXISTS #Objects;
SELECT SchemaObjectName = CONCAT(s.SchemaName, '.', QUOTENAME(o.[name])),
	o.[type],
	o.[type_desc]
	INTO #Objects
	FROM sys.objects AS o
		INNER JOIN #Schemas AS s
			ON o.[schema_id] = s.[schema_id]
UNION ALL
SELECT SchemaObjectName = CONCAT(s.SchemaName, '.', QUOTENAME(t.[name])),
	[type] = 'TYPE',
	[type_desc] = 'TYPE'
	FROM sys.types AS t
		INNER JOIN #Schemas AS s
			ON t.[schema_id] = s.[schema_id]
	WHERE t.is_user_defined = 1
UNION ALL
SELECT SchemaObjectName = SchemaName,
	[type] = 'SCHEMA',
	[type_desc] = 'SCHEMA'
	FROM #Schemas
	WHERE SchemaName <> 'dbo';

--Add more as required...
DROP TABLE IF EXISTS #TypeMapping;
CREATE TABLE #TypeMapping
	(
	DropOrder INT IDENTITY,
	From_Type SYSNAME,
	To_Type SYSNAME
	);
INSERT #TypeMapping
	SELECT From_Type = 'P', To_Type = 'PROCEDURE'
	UNION ALL SELECT 'PC', 'PROCEDURE'
	UNION ALL SELECT 'IF', 'FUNCTION'
	UNION ALL SELECT 'TF', 'FUNCTION'
	UNION ALL SELECT 'FN', 'FUNCTION'
	UNION ALL SELECT 'U', 'TABLE'
	UNION ALL SELECT 'V', 'VIEW'
	UNION ALL SELECT 'TYPE', 'TYPE'
	UNION ALL SELECT 'SCHEMA', 'SCHEMA';

SELECT Instructions = 'Review CAREFULLY, then copy/paste/EXECUTE.'
UNION ALL SELECT 'Repeat until no Foreign Key errors are thrown.';
SELECT DropSql = CONCAT('DROP ', map.To_Type COLLATE DATABASE_DEFAULT, ' IF EXISTS ', o.SchemaObjectName)
	FROM #Objects AS o
		INNER JOIN #TypeMapping AS map
			ON o.[type] = map.From_Type COLLATE DATABASE_DEFAULT
	ORDER BY map.DropOrder;