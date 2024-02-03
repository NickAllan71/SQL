--Run this on the source database to generate script to be run on the destination database
DECLARE @SourceSchemaObjectName SYSNAME = '<Source Object, SYSNAME, dbo.YourObject>',
	@ExternalTableSchema SYSNAME = '<External Table Schema, SYSNAME, internalise>',
	@ExternalDataSource SYSNAME = CONCAT('eds_', DB_NAME()); --SELECT * FROM sys.external_data_sources

DECLARE @ObjectId INT = OBJECT_ID(@SourceSchemaObjectName);
IF @ObjectId IS NULL
BEGIN;
	DECLARE @ErrorMessage VARCHAR(MAX) = FORMATMESSAGE('Failed to find @SourceSchemaObjectName "%s" in database "%s".',
		@SourceSchemaObjectName, DB_NAME());
	THROW 50000, @ErrorMessage, 1;
END;

DECLARE @ExternalTableName SYSNAME = CONCAT(@ExternalTableSchema, '.', OBJECT_NAME(@ObjectId));

DECLARE @Columns VARCHAR(MAX),
	@Delimiter CHAR(3) = ',' + CHAR(10) + CHAR(9);
WITH cteColumns
	AS
	(
	SELECT c.column_id,
		ColumnName = c.[name],
		ColumnType = UPPER(t.[name]) + CASE
				WHEN t.[name] IN ('numeric', 'decimal')
				THEN FORMATMESSAGE('(%i, %i)',  c.[precision], c.scale)
				WHEN t.[name] LIKE '%char' AND c.max_length = -1
				THEN '(MAX)'
				WHEN t.[name] LIKE 'n%char'
				THEN FORMATMESSAGE('(%i)', c.max_length / 2)
				WHEN t.[name] LIKE '%char'
				THEN FORMATMESSAGE('(%i)', c.max_length)
				ELSE ''
				END,
		Collation = 'COLLATE ' + c.collation_name + ' ' COLLATE DATABASE_DEFAULT,
		NullableIndicator = CASE WHEN c.is_nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
		FROM sys.columns AS c
			INNER JOIN sys.types AS t
				ON c.system_type_id = t.system_type_id
				AND c.user_type_id = t.user_type_id
		WHERE c.[object_id] = @ObjectId
			AND t.[name] <> 'geography' --Unsupported
	)
	SELECT @Columns = STRING_AGG(CONVERT(NVARCHAR(MAX), CONCAT(QUOTENAME(ColumnName), ' ', ColumnType, ' ', Collation, NullableIndicator)), ',
	')
		WITHIN GROUP (ORDER BY column_id)
		FROM cteColumns;

SELECT CONCAT('--Run this on the destination database to create the external table
IF SCHEMA_ID(', QUOTENAME(@ExternalTableSchema, ''''), ') IS NULL
	EXEC (''
CREATE SCHEMA ', QUOTENAME(@ExternalTableSchema), '
	AUTHORIZATION dbo;'');
GO
IF OBJECT_ID(' + QUOTENAME(@ExternalTableName, '''') + ') IS NOT NULL
	DROP EXTERNAL TABLE ' + @ExternalTableName + ';
GO
CREATE EXTERNAL TABLE ' + @ExternalTableName + '
	(
	' + @Columns + '
	)
	WITH (
		DATA_SOURCE = ' + QUOTENAME(@ExternalDataSource) + ',
		SCHEMA_NAME = ' + QUOTENAME(OBJECT_SCHEMA_NAME(@ObjectId), '''') + ',
		OBJECT_NAME = ' + QUOTENAME(OBJECT_NAME(@ObjectId), '''') + '
	);');