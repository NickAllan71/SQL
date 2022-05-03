/*
Description:    Script bundled from C:\GitHub\NickAllan71\SQL\Utilities\Transport
Author:         Nick Allan
Date:           03/05/2022 15:35:31
	01. transport schema.sql
	..\..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\UserDefinedFunctions\transport.fn_GetTableDefinition.sql
	..\..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\transport.usp_ImportXML.sql
	..\..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\transport.usp_ImportXML_ByTableName.sql
	..\..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\transport.usp_ScriptImport.sql
*/
PRINT 'Script: 01. transport schema.sql';
GO
IF SCHEMA_ID('transport') IS NULL
	EXEC ('
CREATE SCHEMA [transport]
	AUTHORIZATION dbo;');
GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: transport.fn_GetTableDefinition.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Table-valued function to return the table definition for a given @SchemaTableName
Created:		1 Dec 2017
Author:			Nick Allan

--Example use:
SELECT * FROM transport.fn_GetTableDefinition('import.Map_VendorRecordSource');

*/
CREATE FUNCTION transport.fn_GetTableDefinition
	(
	@SchemaTableName SYSNAME
	)
	RETURNS TABLE
	AS RETURN (
		SELECT c.column_id,
			ColumnName = c.[name],
			c.is_identity,
			c.is_computed,
			is_primary_key = ISNULL(i.is_primary_key, 0),
			ColumnType = CASE
				WHEN t.is_assembly_type = 1 THEN 'NVARCHAR(MAX)'
				WHEN t.[name] IN ('decimal', 'numeric') THEN FORMATMESSAGE('%s(%i, %i)', t.[name], c.[precision], c.scale)
				WHEN c.collation_name IS NULL OR t.[name] = 'SYSNAME' THEN t.[name]
				WHEN c.max_length = -1 THEN t.[name] + '(MAX)'
				WHEN t.[name] LIKE 'N%' THEN FORMATMESSAGE('%s(%i)', t.[name], c.max_length / 2)
				ELSE FORMATMESSAGE('%s(%i)', t.[name], c.max_length)
				END
--DEBUG: declare @schematablename sysname = 'import.Map_VendorRecordSource'; select *
			FROM sys.columns AS c
				INNER JOIN sys.types AS t
					ON c.system_type_id = t.system_type_id
					AND c.user_type_id = t.user_type_id
				LEFT OUTER JOIN sys.indexes AS i
					INNER JOIN sys.index_columns AS ic
						ON i.[object_id] = ic.[object_id]
						AND i.[index_id] = ic.[index_id]
					ON c.[object_id] = i.[object_id]
					AND c.column_id = ic.column_id
					AND i.is_primary_key = 1
			WHERE c.[object_id] = OBJECT_ID(@SchemaTableName, 'U')
	);
GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: transport.usp_ImportXML.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Procedure to INSERT and UPDATE rows from a given @TransportXml document
Created:		4 Dec 2017
Author:			Nick Allan

--Example use:
DECLARE @TransportXml XML = (
	SELECT XmlDocument FROM transport.fn_GetXMLDocumentForOrgIds('111,112')
	);
EXEC transport.usp_ImportXML @TransportXml = @TransportXml, @Debug = 1;

*/
CREATE PROCEDURE transport.usp_ImportXML
	(
	@TransportXml XML,
	@TableOrderCSV VARCHAR(1000) = NULL,
	@SkipColumns VARCHAR(1000) = NULL,
	@Debug BIT = 0
	)
	AS
BEGIN;
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

--DEBUG: declare @tableordercsv varchar(1000), @skipcolumns varchar(1000), @debug bit = 0, @transportxml xml = '<transport><dbo.Shared_RecordSources RecordSourceId="29" RecordSourceName="ASM" IsHidden="1"><import.Map_VendorRecordSource VendorRecordSourceId="5" RecordSourceId="29" CountryId="AO" VendorDatabaseName="VendorAngola" VendorDescription="Sourced from Instituto Nacional de Apoio às Micro, Pequenas e Médias Empresas (INAPEM)" CreatedDateTime="2019-09-06T11:02:47.503" /></dbo.Shared_RecordSources></transport>'
	DROP TABLE IF EXISTS #TableOrder;
	SELECT TableOrder = IDENTITY(INT, 1, 1),
		TableName = o.[value],
		SchemaTableName = SCHEMA_NAME(t.[schema_id]) + '.' + t.name
		INTO #TableOrder
		FROM STRING_SPLIT(@TableOrderCSV, ',') AS o
			LEFT OUTER JOIN sys.tables AS t
				ON OBJECT_ID(LTRIM(o.[value])) = t.[object_id]
		WHERE o.[value] IS NOT NULL;
	DECLARE @InvalidTableNames VARCHAR(MAX);
	SELECT @InvalidTableNames = ISNULL(@InvalidTableNames + ', ', '') + TableName
		FROM #TableOrder
		WHERE SchemaTableName IS NULL;
	IF @@ROWCOUNT > 0
	BEGIN;
		DECLARE @ErrorMessage VARCHAR(MAX) = FORMATMESSAGE('@TableOrderCSV contained invalid table name(s): %s', @InvalidTableNames);
		THROW 50000, @ErrorMessage, 1;
	END;

	DROP TABLE IF EXISTS #RowsToShred;
	SELECT Position = IDENTITY(INT, 1, 1),
		SchemaTableName = c.value('local-name(.)', 'SYSNAME')
		INTO #RowsToShred
		FROM @TransportXml.nodes('/transport//*') AS t(c);

	DROP TABLE IF EXISTS #TablesToShred;
	CREATE TABLE #TablesToShred
		(
		TableId INT,
		SchemaTableName SYSNAME,
		DynamicSql VARCHAR(MAX)
		);
	WITH cteDeduplicate
		AS
		(
		SELECT Position,
			SchemaTableName,
			RowNumber = ROW_NUMBER() OVER (PARTITION BY SchemaTableName ORDER BY Position)
			FROM #RowsToShred
		)
		INSERT #TablesToShred
			(
			TableId,
			SchemaTableName,
			DynamicSql
			)
			SELECT ShredOrder = ROW_NUMBER() OVER (ORDER BY ISNULL(o.TableOrder, 99), r.Position),
				r.SchemaTableName,
				DynamicSql = FORMATMESSAGE('EXEC transport.usp_ImportXML_ByTableName @TableName = %s, @TransportXml = @TransportXml, @SkipColumns = %s;',
					QUOTENAME(r.SchemaTableName, ''''),
					ISNULL(QUOTENAME(@SkipColumns, ''''), 'NULL')
					)
				FROM cteDeduplicate AS r
					LEFT OUTER JOIN #TableOrder AS o
						ON r.SchemaTableName = o.SchemaTableName COLLATE DATABASE_DEFAULT
				WHERE r.RowNumber = 1
				ORDER BY ShredOrder;
	
	IF @Debug = 1
		SELECT * FROM #TablesToShred;
	
	BEGIN TRANSACTION;

	DECLARE @TableId INT,
		@MaxId INT;
	SELECT @TableId = MIN(TableId),
		@MaxId = MAX(TableId)
		FROM #TablesToShred;
	WHILE @TableId <= @MaxId
	BEGIN;
		DECLARE @SchemaTableName SYSNAME,
			@DynamicSql VARCHAR(MAX);
		SELECT @SchemaTableName = SchemaTableName,
			@DynamicSql = DynamicSql
			FROM #TablesToShred
			WHERE TableId = @TableId;
		
		PRINT @DynamicSql;
		EXEC transport.usp_ImportXML_ByTableName @TableName = @SchemaTableName,
			@TransportXml = @TransportXml,
			@SkipColumns = @SkipColumns,
			@Debug = @Debug;

		SET @TableId += 1;
	END
	
	IF @Debug = 1
		ROLLBACK TRANSACTION;
	ELSE
		COMMIT TRANSACTION;
END;
GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: transport.usp_ImportXML_ByTableName.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Procedure to import data for a given @TableName from a given @TransportXml document
Created:		1 Dec 2017
Author:			Nick Allan

--Example use:

DECLARE @TransportXml XML = (SELECT XmlDocument FROM transport.fn_GetXMLDocumentForOrgIds('13'));
EXEC transport.usp_ImportXML_ByTableName @TableName = 'dbo.People_Person',
	@TransportXml = @TransportXml,
	@Debug = 1;
*/
CREATE PROCEDURE transport.usp_ImportXML_ByTableName
	(
	@TableName SYSNAME,
	@TransportXml XML,
	@SkipColumns VARCHAR(1000) = NULL,
	@Debug BIT = 0 --Transaction is rolled back
	)
	AS
BEGIN;
	SET NOCOUNT ON;

--DEBUG: declare @tablename sysname = 'dbo.People_Person', @transportxml xml = (select xmldocument from transport.fn_getxmldocumentfororgids('13')), @skipcolumns varchar(1000), @Debug BIT = 1;
	DECLARE @ObjectId INT = OBJECT_ID(@TableName);
	IF @ObjectId IS NULL
	BEGIN;
		DECLARE @ErrorMessage VARCHAR(MAX) = FORMATMESSAGE('Failed to find @TableName "%s"', @TableName);
		THROW 50000, @ErrorMessage, 1;
	END;

	DECLARE @SchemaTableName SYSNAME = CONCAT(OBJECT_SCHEMA_NAME(@ObjectId), '.', OBJECT_NAME(@ObjectId));

	DROP TABLE IF EXISTS #TableDefinition;
	CREATE TABLE #TableDefinition
		(
		column_id INT,
		ColumnName SYSNAME,
		is_identity BIT,
		is_primary_key BIT,
		ColumnType SYSNAME,
		Delimiter VARCHAR(2)
		)
	INSERT #TableDefinition
		(
		column_id,
		ColumnName,
		is_identity,
		is_primary_key,
		ColumnType,
		Delimiter
		)
		SELECT d.column_id,
			d.ColumnName,
			d.is_identity,
			d.is_primary_key,
			d.ColumnType,
			Delimiter = CASE WHEN ROW_NUMBER() OVER (ORDER BY d.column_id DESC) = 1 THEN '' ELSE ',' + CHAR(10) END
			FROM transport.fn_GetTableDefinition(@SchemaTableName) AS d
				LEFT OUTER JOIN STRING_SPLIT(@SkipColumns, ',') AS s
					ON d.ColumnName = s.[value] COLLATE DATABASE_DEFAULT
			WHERE s.[value] IS NULL
				AND d.is_computed = 0;

	DECLARE @ShredSQL NVARCHAR(MAX);
	SELECT @ShredSQL = '
SELECT DISTINCT '
	+ STRING_AGG(CONVERT(NVARCHAR(MAX),
		CONCAT(QUOTENAME(ColumnName), ' = c.value(', QUOTENAME('@' + ColumnName, ''''), ', ''', ColumnType, ''')')
		), ',
	')	WITHIN GROUP (ORDER BY column_id) + '
	INTO ##ImportData
	FROM @TransportXml.nodes(''//' + @SchemaTableName + ''') AS t(c);'
		FROM #TableDefinition;
	IF @Debug = 1
		PRINT @ShredSQL;

	DROP TABLE IF EXISTS ##ImportData;
	EXEC sys.sp_executesql @statement = @ShredSQL,
		@params = N'@TransportXml XML',
		@TransportXml = @TransportXml;

	DECLARE @JoinColumns NVARCHAR(MAX),
		@CheckColumns NVARCHAR(MAX);
	SELECT @JoinColumns = STRING_AGG(CONVERT(NVARCHAR(MAX),
		CONCAT('dest.', QUOTENAME(ColumnName), ' = src.', QUOTENAME(ColumnName))), '
			AND '),
		@CheckColumns = STRING_AGG(CONVERT(NVARCHAR(MAX),
		CONCAT('dest.', QUOTENAME(ColumnName), ' IS NULL')), '
			AND ')
		FROM #TableDefinition
		WHERE is_primary_key = 1;

	DECLARE @UpdateSQL NVARCHAR(MAX);
	SELECT @UpdateSQL = '
UPDATE dest
	SET ' + STRING_AGG(CONVERT(NVARCHAR(MAX),
				CONCAT(QUOTENAME(ColumnName), ' = ', 'src.', QUOTENAME(ColumnName))
			), ',
		')	WITHIN GROUP (ORDER BY column_id) + '
	FROM ' + @SchemaTableName + ' AS dest
		INNER JOIN ##ImportData AS src
			ON ' + @JoinColumns + ';
PRINT FORMATMESSAGE(''Updated %i ' + @SchemaTableName + ' rows'', @@ROWCOUNT);'
			FROM #TableDefinition
			WHERE is_primary_key = 0;

	DECLARE @InsertSQL NVARCHAR(MAX);
	SELECT @InsertSQL = '
INSERT ' + @SchemaTableName + '
	(
	' + STRING_AGG(CONVERT(NVARCHAR(MAX), QUOTENAME(ColumnName)), ',
	')	WITHIN GROUP (ORDER BY column_id) + '
	)
	SELECT ' + STRING_AGG(CONVERT(NVARCHAR(MAX), CONCAT('src.', QUOTENAME(ColumnName))), ',
		')	WITHIN GROUP (ORDER BY column_id) + '
		FROM ##ImportData AS src
			LEFT OUTER JOIN ' + @SchemaTableName + ' AS dest
				ON ' + @JoinColumns + '
		WHERE ' + @CheckColumns + ';
PRINT FORMATMESSAGE(''Inserted %i ' + @SchemaTableName + ' rows'', @@ROWCOUNT);'
		FROM #TableDefinition;

	SELECT @InsertSQL = '
SET IDENTITY_INSERT ' + @SchemaTableName + ' ON;
' + @InsertSQL + '

SET IDENTITY_INSERT ' + @SchemaTableName + ' OFF;'
		FROM #TableDefinition
		WHERE is_identity = 1;

	IF @Debug = 1
	BEGIN;
		PRINT @UpdateSQL;
		PRINT @InsertSQL;
	END;

	DECLARE @RollbackTransaction BIT = CASE 
		WHEN @Debug = 1 AND @@TRANCOUNT = 0
		THEN 1
		ELSE 0
		END;
	IF @RollbackTransaction = 1
		BEGIN TRANSACTION;

	EXEC(@UpdateSQL);
	EXEC(@InsertSQL);

	IF @RollbackTransaction = 1
	BEGIN;
		ROLLBACK TRANSACTION;
		PRINT 'TRANSACTION ROLLED BACK'
	END;
END;
GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: transport.usp_ScriptImport.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Procedure to prepare an import script for a given @XML transport document
Created:		13 Jan 2019
Author:			Nick Allan

--Example use:
DECLARE @TransportXML XML = (SELECT XmlDocument FROM transport.fn_GetXMLDocumentForOrgIds('13'));
EXEC transport.usp_ScriptImport @TransportXML = @TransportXML;

*/
CREATE PROCEDURE transport.usp_ScriptImport
	(
	@TransportXML XML
	)
	AS
BEGIN;
	SET NOCOUNT ON;
	
--DEBUG: declare @transportxml xml = (select xmldocument from transport.fn_getxmldocumentfororgids('13'));
	DROP TABLE IF EXISTS #Substitutions;
	CREATE TABLE #Substitutions
		(
		Lookfor NVARCHAR(10),
		ReplaceWith VARCHAR(10)
		);
	DECLARE @LF CHAR(1) = CHAR(10);
	INSERT #Substitutions
		VALUES ('><', '>' + @LF + '<'),
			(' /></', ' />' + @LF + '</'),
			('''', '''''');

	DECLARE @XMLString NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX), @TransportXML);
	SELECT @XMLString = REPLACE(@XMLString, LookFor, ReplaceWith)
		FROM #Substitutions;

	DROP TABLE IF EXISTS #Script;
	CREATE TABLE #Script
		(
		Id INT,
		Item NVARCHAR(MAX)
		);
	INSERT #Script
		SELECT Id = ordinal,
			Item = [value]
			FROM STRING_SPLIT(@XMLString, @LF, 1);
	DECLARE @MaxId INT = @@ROWCOUNT;

	UPDATE #Script
		SET Item = 'EXEC transport.usp_ImportXML @TransportXml = N''' + Item
		WHERE Id = 1;
	UPDATE #Script
		SET Item = Item + ''';'
		WHERE Id = @MaxId;

	DECLARE @Id INT = 1;
	WHILE @Id <= @MaxId
	BEGIN;
		DECLARE @Item NVARCHAR(MAX);
		SELECT @Item = Item
			FROM #Script
			WHERE Id = @Id;
		
		PRINT @Item;
		SET @Id += 1;
	END;
END;

GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
DECLARE @Success AS BIT
SET @Success = 1;
SET NOEXEC OFF;
IF @Success = 1
    PRINT 'The database update succeeded';
ELSE
    PRINT 'The database update failed';
GO
