/*
Description:    Script bundled from C:\GitHub\NickAllan71\SQL\Utilities
Author:         Nick Allan
Date:           27/04/2022 09:39:12
	01. Cleardown.sql
	..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\dbo.sp_Find.sql
	..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\dbo.sp_FindCode.sql
	..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\dbo.sp_MatchTableName.sql
	..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\dbo.sp_Join.sql
	..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\dbo.sp_ScriptExecute.sql
	..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\dbo.sp_ScriptInsert.sql
	..\..\..\..\DiligenciaStudio\Dev\SQL\diligencia-p\StoredProcedures\dbo.sp_LaunchTool.sql
*/
PRINT 'Script: 01. Cleardown.sql';
GO
DROP PROCEDURE IF EXISTS dbo.sp_Find;
DROP PROCEDURE IF EXISTS dbo.sp_FindCode;
DROP PROCEDURE IF EXISTS dbo.sp_MatchTableName;
DROP PROCEDURE IF EXISTS dbo.sp_Join;
DROP PROCEDURE IF EXISTS dbo.sp_ScriptExecute;
DROP PROCEDURE IF EXISTS dbo.sp_ScriptInsert;
DROP PROCEDURE IF EXISTS dbo.sp_LaunchTool;
GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: dbo.sp_Find.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Utility procedure to find objects matching a given @SearchTarget
Created:		28 Jun 2017
Author:			Nick Allan

--Example use:
EXEC sp_Find dbo
EXEC sp_Find OrgId
EXEC sp_Find IX_

*/
CREATE PROCEDURE dbo.sp_Find
	(
	@SearchTarget NVARCHAR(100) = '.' --Return all objects by default
	)
	AS
BEGIN;
	SET NOCOUNT ON;
	
--DEBUG: declare @searchtarget nvarchar(100) = '.';
	DECLARE @WidenedSearchTarget NVARCHAR(100) = CASE
		WHEN @SearchTarget LIKE N'[%]%[%]'
		THEN @SearchTarget
		ELSE CONCAT(N'%', @SearchTarget, N'%')
		END;

	DROP TABLE IF EXISTS #FoundObjects;
	WITH cteFoundObjects
		AS
		(
		SELECT FoundObject = CONCAT(s.[name], N'.',
				CASE WHEN o.[name] LIKE '% %' THEN QUOTENAME(o.[name]) ELSE o.[name] END
				),
			FoundIndex = NULL,
			o.[type],
			ObjectType = o.[type_desc],
			o.modify_date
			FROM sys.schemas AS s
				INNER JOIN sys.objects AS o
					ON s.[schema_id] = o.[schema_id]
			WHERE CONCAT(s.[name], N'.', o.[name]) LIKE @WidenedSearchTarget
				AND o.[type] NOT IN ('S', 'IT', 'SQ') --Internal system types inaccessible to users anyway
		UNION ALL
		SELECT FoundObject = CONCAT(s.[name], N'.', 
				CASE WHEN o.[name] LIKE '% %' THEN QUOTENAME(o.[name]) ELSE o.[name] END
				),
			FoundIndex = CASE WHEN i.[name] LIKE '% %' THEN QUOTENAME(i.[name]) ELSE i.[name] END,
			[type] = NULL,
			ObjectType = i.[type_desc],
			o.modify_date
			FROM sys.schemas AS s
				INNER JOIN sys.objects AS o
					ON s.[schema_id] = o.[schema_id]
				INNER JOIN sys.indexes AS i
					ON o.[object_id] = i.[object_id]
			WHERE i.[name] LIKE @SearchTarget + '%'
		UNION ALL
		SELECT FoundObject = CASE WHEN [name] LIKE '% %' THEN QUOTENAME([name]) ELSE [name] END,
			FoundIndex = NULL,
			[type] = NULL,
			ObjectType = 'USER',
			modify_date = updatedate
			FROM dbo.sysusers
			WHERE [name] LIKE @WidenedSearchTarget
		)
		SELECT *,
			ViewDefinition = FORMATMESSAGE(
				CASE WHEN [type] IN ('P', 'TR', 'V', 'IF', 'TF', 'FN') THEN N'EXEC sp_ScriptObject N''%s'';'
				WHEN FoundIndex IS NOT NULL THEN N'EXEC sp_helpindex N''%s'';'
				WHEN ObjectType = 'LOGIN' THEN N'EXEC sp_helplogins N''%s'';'
				WHEN ObjectType = 'USER' THEN N'SELECT * FROM sys.sysusers WHERE name = N''%s'';'
				ELSE N'EXEC sp_help N''%s'';'
				END,
				FoundObject)
			INTO #FoundObjects
			FROM cteFoundObjects;
	DECLARE @FoundObjects INT = @@ROWCOUNT;
	
	DROP TABLE IF EXISTS #FoundColumns;
	SELECT FoundColumn = CASE WHEN c.[name] LIKE '% %' THEN QUOTENAME(c.[name]) ELSE c.[name] END,
		FoundObject = CONCAT(s.[name], N'.', 
			CASE WHEN o.[name] LIKE '% %' THEN QUOTENAME(o.[name]) ELSE o.[name] END
			),
		o.[type],
		ObjectType = o.[type_desc],
		ColumnType = t.[name],
		c.max_length,
		c.[precision],
		c.scale,
		c.is_identity,
		c.is_nullable,
		is_defaulted = CONVERT(BIT, c.default_object_id),
		ViewDefinition = FORMATMESSAGE(
			CASE WHEN [type] IN ('P', 'TR', 'V', 'IF', 'TF', 'FN')
			THEN N'EXEC sp_ScriptObject N''%s'';'
			ELSE N'EXEC sp_help N''%s'';'
			END,
			CONCAT(s.[name], N'.', o.[name]))
		INTO #FoundColumns
		FROM sys.schemas AS s
			INNER JOIN sys.objects AS o
				ON s.[schema_id] = o.[schema_id]
			INNER JOIN sys.columns AS c
				ON o.[object_id] = c.[object_id]
			INNER JOIN sys.types AS t
				ON c.system_type_id = t.system_type_id
				AND c.user_type_id = t.user_type_id
		WHERE c.name LIKE @WidenedSearchTarget;
	DECLARE @FoundColumns INT = @@ROWCOUNT;

	IF @FoundObjects = 1 AND @FoundColumns = 0
	BEGIN;
		DECLARE @ViewDefinition VARCHAR(MAX) = (
			SELECT ViewDefinition
				FROM #FoundObjects
			);
		EXEC (@ViewDefinition);
		
		RETURN;
	END;

	PRINT FORMATMESSAGE('Found %i objects and %i columns in database ''%s'' matching @WidenedSearchTarget ''%s''.',
		@FoundObjects, @FoundColumns, DB_Name(), @WidenedSearchTarget);
	
	DROP TABLE IF EXISTS #SortOrder;
	SELECT SortOrder = IDENTITY(INT, 1, 1),
		[type] = [value]
		INTO #SortOrder
		FROM STRING_SPLIT('U,P,V,IF,TF,FN', ',');
	
	IF @FoundObjects > 0
		SELECT f.* FROM #FoundObjects AS f
			LEFT OUTER JOIN #SortOrder AS o
				ON f.[type] = o.[type] COLLATE DATABASE_DEFAULT
			ORDER BY o.SortOrder,
				f.FoundObject;
	
	IF @FoundColumns > 0
		SELECT * FROM #FoundColumns
			ORDER BY is_identity DESC,
				FoundColumn,
				FoundObject,
				ObjectType;
END;

GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: dbo.sp_FindCode.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Prodedure to find code matching a given @SearchTarget
Created:		14 Mar 2017
Author:			Nick Allan

Example use:

--Find all code referencing dbo.sp_ScriptObject
sp_FindCode 'dbo.sp_ScriptObject';

*/
CREATE PROCEDURE dbo.sp_FindCode
	(
	@SearchTarget VARCHAR(100)
	)
	AS
BEGIN;
	SET NOCOUNT ON;
	
--DEBUG: declare @searchtarget as varchar(100) = 'SELECT'
	IF @SearchTarget NOT LIKE '[%]%[%]'
		SET @SearchTarget = '%' + @SearchTarget + '%';
 
	DROP TABLE IF EXISTS #FoundCode;
	SELECT FoundObject = SCHEMA_NAME(o.[schema_id]) + '.' + o.name,
		o.type_desc,
		o.modify_date
		INTO #FoundCode
		FROM sys.sql_modules AS m
			INNER JOIN sys.objects AS o
				ON m.[object_id] = o.[object_id]
		WHERE m.[definition] LIKE @SearchTarget;
	DECLARE @FoundObjects INT = @@ROWCOUNT;
 
	PRINT FORMATMESSAGE('Found code within %i objects in database ''%s'' matching @SearchTarget ''%s''.', @FoundObjects, DB_Name(), @SearchTarget);
 
	IF @FoundObjects > 0
		SELECT *,
			ViewDefinitionSQL = FORMATMESSAGE('EXEC sp_ScriptObject ''%s''', FoundObject)
			FROM #FoundCode
			ORDER BY type_desc,
				FoundObject;
END;

GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: dbo.sp_MatchTableName.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Procedure to match the name of a table using a given table name fragment.
Author:			Nick Allan
Date:			21 Apr 2017

Example use...

DECLARE @TableName SYSNAME = 'ORGANISATION'; --NB: Singular!
EXEC dbo.sp_MatchTableName @TableName = @TableName OUTPUT;
SELECT [@TableName] = @TableName;
GO
DECLARE @TableName SYSNAME = 'Persons'; --NB: Plural!
EXEC dbo.sp_MatchTableName @TableName = @TableName OUTPUT;
SELECT [@TableName] = @TableName;

*/
CREATE PROCEDURE dbo.sp_MatchTableName
	(
	@TableName SYSNAME OUTPUT
	)
	AS
BEGIN;
	SET NOCOUNT ON;

--DEBUG: declare @tablename sysname = 'people_identifications';
	IF @TableName IS NULL
		RETURN;
	
	IF @TableName LIKE '#%' AND OBJECT_ID('tempdb.dbo.' + @TableName, 'U') IS NOT NULL
		RETURN;
	
	IF OBJECT_ID('tempdb.dbo.#LikeClauses', 'U') IS NOT NULL
		DROP TABLE #LikeClauses;
	CREATE TABLE #LikeClauses
		(
		ID INT IDENTITY,
		LikeClause NVARCHAR(200)
		);
	INSERT #LikeClauses
		(
		LikeClause
		)
		SELECT LikeClause = @TableName
			WHERE @TableName LIKE '%.%'
		UNION ALL
		SELECT LikeClause = '%.' + @TableName
			WHERE @TableName NOT LIKE '%.%'
		UNION ALL
		SELECT LikeClause = '%[_]' + @TableName
			WHERE @TableName NOT LIKE '%.%';

	INSERT #LikeClauses
		(
		LikeClause
		)
		SELECT LikeClause = LikeClause + 's'
			FROM #LikeClauses
			WHERE LikeClause NOT LIKE '%s'
		UNION ALL
		SELECT LikeClause = LEFT (LikeClause, LEN(LikeClause) - 1)
			FROM #LikeClauses
			WHERE LikeClause LIKE '%s';
	
	DECLARE @MatchedTableName SYSNAME;
	SELECT @MatchedTableName = s.name + '.' + t.name
		FROM sys.tables AS t
			INNER JOIN sys.schemas AS s
				ON t.[schema_id] = s.[schema_id]
			INNER JOIN #LikeClauses AS lc
				ON s.name + '.' + t.name LIKE lc.LikeClause COLLATE DATABASE_DEFAULT
		WHERE t.is_external = 0;

	DECLARE @MatchCount INT = @@ROWCOUNT;
	IF @MatchCount <> 1
	BEGIN;
		DECLARE @ErrorMessage VARCHAR(MAX) = FORMATMESSAGE('Found %i tables matching the name "%s".', @MatchCount, @TableName);
		THROW 50000, @ErrorMessage, 2;
	END;

	SET @TableName = @MatchedTableName;
END;
GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: dbo.sp_Join.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Procedure to script a join between two or more given tables (up to 7).  Ideally foreign keys should be present,
				failing that, same-named columns are used in the join clause.  To avoid truncation of output setup SSMS as follows...
				Tools > Options > Query Results > SQL Server > Results to Text > Maximum characters displayed in each column: 8192
Author:			Nick Allan
Date:			21 Apr 2011

--Example use...
EXEC sp_Join countries, region, cities, town, district, zone, @ListColumns = 1

--Example of multiple table join...
EXEC sp_join managementsectiontype, managementtypestosectiontype, managementtype, position, persontoorg, organisation

*/
CREATE PROCEDURE dbo.sp_Join
	(
	@Table1 SYSNAME,
	@Table2 SYSNAME,
	@Table3 SYSNAME = NULL,
	@Table4 SYSNAME = NULL,
	@Table5 SYSNAME = NULL,
	@Table6 SYSNAME = NULL,
	@Table7 SYSNAME = NULL,
	@ListColumns BIT = 0,
	@UseAliases BIT = 1
	)
	AS
BEGIN;
	SET NOCOUNT ON;

--DEBUG: declare @table1 sysname = 'searchindex_queue', @table2 sysname = 'people_person', @table3 sysname, @table4 sysname, @table5 sysname, @table6 sysname, @table7 sysname, @listcolumns bit = 0
	EXEC dbo.sp_MatchTableName @TableName = @Table1 OUTPUT;
	EXEC dbo.sp_MatchTableName @TableName = @Table2 OUTPUT;
	EXEC dbo.sp_MatchTableName @TableName = @Table3 OUTPUT;
	EXEC dbo.sp_MatchTableName @TableName = @Table4 OUTPUT;
	EXEC dbo.sp_MatchTableName @TableName = @Table5 OUTPUT;
	EXEC dbo.sp_MatchTableName @TableName = @Table6 OUTPUT;
	EXEC dbo.sp_MatchTableName @TableName = @Table7 OUTPUT;

	DROP TABLE IF EXISTS #Tables;
	CREATE TABLE #Tables
		(
		TableId INT IDENTITY,
		TableName SYSNAME,
		TableObjectId INT,
		Alias SYSNAME NULL
		);
	WITH cteTables
		(
		TableName
		)
		AS
		(
		SELECT @Table1
		UNION ALL
		SELECT @Table2
		UNION ALL
		SELECT @Table3
		UNION ALL
		SELECT @Table4
		UNION ALL
		SELECT @Table5
		UNION ALL
		SELECT @Table6
		UNION ALL
		SELECT @Table7
		)
		INSERT #Tables
			(
			TableName,
			Alias,
			TableObjectId
			)
			SELECT TableName = TableName,
				Alias = TableName,
				TableObjectId = OBJECT_ID(TableName, 'U')
				FROM cteTables AS t
				WHERE TableName IS NOT NULL;
	
	IF OBJECT_ID('dbo.Standard_TableAlias', 'U') IS NULL
		SET @UseAliases = 0;

	IF @UseAliases = 1
		UPDATE t
			SET Alias = COALESCE(a.TableAlias, t.TableName)
			FROM #Tables AS t
				LEFT OUTER JOIN dbo.Standard_TableAlias AS a
					ON t.TableObjectId = OBJECT_ID(a.SchemaTableName, 'U');
	
	DROP TABLE IF EXISTS #JoinKeys;
	--Look for foreign keys between given tables
	SELECT ParentId = parent.TableId,
		ParentColumn = CONCAT(parent.Alias, '.', pc.[name] COLLATE DATABASE_DEFAULT),
		IsParentColumnNullable = pc.is_nullable,
		ReferencedId = referenced.TableId,
		ReferencedColumn = CONCAT(referenced.Alias, '.', rc.[name] COLLATE DATABASE_DEFAULT),
		IsReferencedColumnNullable = rc.is_nullable,
		IsForeignKey = 1,
		KeyColumnNumber = ROW_NUMBER() OVER (
			PARTITION BY fk.[object_id]
			ORDER BY parent.TableId,
				referenced.TableId
			)
		INTO #JoinKeys
		FROM #Tables AS parent
			INNER JOIN sys.foreign_keys AS fk
				ON parent.TableObjectId = fk.parent_object_id
			INNER JOIN #Tables AS referenced
				ON fk.referenced_object_id = referenced.TableObjectId
				AND ABS(parent.TableId - referenced.TableId) = 1
			INNER JOIN sys.foreign_key_columns AS fkc
				ON fk.[object_id] = fkc.constraint_object_id
			INNER JOIN sys.columns AS rc
				ON fkc.referenced_object_id = rc.[object_id]
				AND fkc.referenced_column_id = rc.column_id
			INNER JOIN sys.columns AS pc
				ON fkc.parent_object_id = pc.[object_id]
				AND fkc.parent_column_id = pc.column_id
		ORDER BY parent.TableId,
			referenced.TableId;

	UPDATE #JoinKeys
		SET ParentId = ReferencedId,
			ParentColumn = ReferencedColumn,
			IsParentColumnNullable = IsReferencedColumnNullable,
			ReferencedId = ParentId,
			ReferencedColumn = ParentColumn
		WHERE ParentId > ReferencedId;

	--Guess where the foreign keys should be, if they're missing...
	INSERT #JoinKeys
		(
		ParentId,
		ParentColumn,
		IsParentColumnNullable,
		ReferencedId,
		ReferencedColumn,
		IsReferencedColumnNullable,
		IsForeignKey,
		KeyColumnNumber
		)
		SELECT ParentId = t.TableId,
			ParentColumn = CONCAT(t.Alias, '.', tc.[name]),
			IsParentColumnNullable = tc.is_nullable,
			ReferencedId = n.TableId,
			ReferencedColumn = CONCAT(n.Alias, '.', ntc.[name]),
			IsReferencedColumnNullable = ntc.is_nullable,
			IsForeignKey = 0,
			KeyColumnNumber = 1
			FROM #Tables AS t
				INNER JOIN #Tables AS n
					ON t.TableId = n.TableId - 1
				INNER JOIN sys.columns AS tc
					ON t.TableObjectId = tc.[object_id]
				INNER JOIN sys.columns AS ntc
					ON n.TableObjectId = ntc.[object_id]
					AND tc.[name] = ntc.[name] --Look for same-named columns between tables
			WHERE NOT EXISTS (SELECT 1 FROM #JoinKeys AS k WHERE k.ParentId = t.TableId)
				AND NOT EXISTS (
					SELECT 1 FROM sys.types AS tp
						WHERE tc.user_type_id = tp.user_type_id
							AND tp.collation_name IS NOT NULL
							AND tc.max_length > 20
					) --Avoid joining on long string columns
				AND ntc.[name] NOT LIKE '%Date%'
				AND ntc.[name] NOT IN ('CreatedByUserId', 'ModifiedByUserId'); --Avoid joining on audit columns
	
	DECLARE @MissingJoinKeys VARCHAR(MAX);
	SELECT @MissingJoinKeys = 'No foreign keys or same-named columns found between: '
		+ STRING_AGG(t.TableName + ' and ' + n.TableName, + ', ')
		FROM #Tables AS t
			INNER JOIN #Tables AS n
				ON t.TableId = n.TableId - 1
			LEFT OUTER JOIN #JoinKeys AS k
				ON t.TableId = k.ParentId
		WHERE k.ParentId IS NULL;

	IF @MissingJoinKeys IS NOT NULL
		THROW 50000, @MissingJoinKeys, 1;

	DECLARE @ColumnList VARCHAR(MAX);

	IF @ListColumns = 0
		SET @ColumnList = '*';
	ELSE
		SELECT @ColumnList = STRING_AGG(CONCAT(t.Alias, '.', c.[name]), ',
	' COLLATE DATABASE_DEFAULT)
			WITHIN GROUP (ORDER BY t.TableId, c.column_id)
			FROM #Tables AS t
				INNER JOIN sys.columns AS c
					ON t.TableObjectId = c.[object_id];

	DECLARE @SQL VARCHAR(MAX);
	SELECT @SQL = STRING_AGG(
		CASE
			WHEN k.ParentId IS NULL
			THEN '
SELECT ' + @ColumnList + '
	FROM ' + t.TableName + CASE WHEN t.Alias <> t.TableName THEN ' AS ' + t.Alias ELSE '' END
			ELSE
				CASE
					WHEN k.KeyColumnNumber = 1
					THEN
						CASE
							WHEN mfk.ParentId IS NULL
							THEN ''
							ELSE '
--WARNING: There are multiple FKs between these tables, so alias ' + t.TableName + ' or remove this join...'
							END
						+ CASE
							WHEN k.IsParentColumnNullable = 1
							THEN '
		LEFT OUTER JOIN '	ELSE '
		INNER JOIN '	END + t.TableName
						+ CASE WHEN t.Alias <> t.TableName THEN ' AS ' + t.Alias ELSE '' END
						+ CASE
							WHEN k.IsForeignKey = 0
							THEN ' --Implied Join (no foreign key found)'
							ELSE ''
							END + '
			ON '
				ELSE '
			AND ' --Multiple column key
				END
				+ k.ParentColumn + ' = ' + k.ReferencedColumn
			END, '')
			WITHIN GROUP (ORDER BY t.TableId) + ';'
		FROM #Tables AS t
			LEFT OUTER JOIN #JoinKeys AS k
				ON t.TableId = k.ReferencedId
			LEFT OUTER JOIN (
--Detect when a pair of tables have multiple foreign keys between them
				SELECT ParentId,
					ReferencedId,
					KeyColumnNumber
					FROM #JoinKeys
					GROUP BY ParentId,
						ReferencedId,
						KeyColumnNumber
					HAVING COUNT(1) > 1
				) AS mfk
				ON k.ParentId = mfk.ParentId
				AND k.ReferencedId = mfk.ReferencedId
				AND k.KeyColumnNumber = mfk.KeyColumnNumber;

	PRINT @SQL;
END;
GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: dbo.sp_ScriptExecute.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Procedure to prepare an EXECUTE statement for a given procedure
Author:			Nick Allan
Date:			14 Apr 2017

--Example SQL... 
EXEC dbo.sp_ScriptExecute sp_find;
EXEC dbo.sp_ScriptExecute usp_GetProjectIdByReference
*/
CREATE PROCEDURE dbo.sp_ScriptExecute
	(
	@ProcedureName SYSNAME
	)
	AS
BEGIN;
	SET NOCOUNT ON;

--DEBUG: declare @procedurename sysname = 'datafix.usp_Source_Assignment_Add';
	DECLARE @ObjectID INT,
		@SearchTarget VARCHAR(255) = '%' + REPLACE(REPLACE(@ProcedureName, '[', ''), ']', '');
	SELECT @ObjectID = [object_id]
		FROM sys.procedures
		WHERE SCHEMA_NAME([schema_id]) + '.' + [name] LIKE @SearchTarget;
	DECLARE @RowCount INT = @@ROWCOUNT;
	IF @RowCount <> 1
	BEGIN;
		DECLARE @ErrorMessage VARCHAR(MAX) = FORMATMESSAGE('Found %i procedures matching "%s"', @RowCount, @ProcedureName);
		THROW 50000, @ErrorMessage, 1;
	END;

	SET @ProcedureName = OBJECT_SCHEMA_NAME(@ObjectId) + '.' + OBJECT_NAME(@ObjectId);

	DECLARE @Code VARCHAR(MAX)
	SELECT @Code = SUBSTRING([definition],
		PATINDEX('%CREATE PROC%' + OBJECT_NAME(@ObjectId) + '%AS%', [definition] COLLATE DATABASE_DEFAULT),
		LEN([definition]))
		FROM sys.sql_modules
		WHERE [object_id] = @ObjectID;

	DROP TABLE IF EXISTS #Parameters;
	CREATE TABLE #Parameters
		(
		ID INT IDENTITY,
		ParameterName SYSNAME NOT NULL,
		IsString BIT,
		IsDatetime BIT,
		is_output BIT,
		ParameterDefinition VARCHAR(100) NULL,
		StartIndex INT,
		EndIndex INT,
		ParamDefault VARCHAR(100) NULL,
		ValueDelimiter VARCHAR(2) NULL
		);

	INSERT #Parameters
		(
		ParameterName,
		IsString,
		IsDatetime,
		is_output,
		StartIndex,
		ParameterDefinition
		)
		SELECT ParameterName = p.[name],
			IsString = CASE
				WHEN t.collation_name IS NULL
				THEN 0
				ELSE 1
				END,
			IsDatetime = CASE
				WHEN t.[name] LIKE '%date%'
				THEN 1
				ELSE 0
				END,
			p.is_output,
			StartIndex = CHARINDEX(p.[name], @Code),
			ParameterDefinition = UPPER(t.[name]) + CASE
				WHEN t.[name] IN ('numeric', 'decimal')
				THEN FORMATMESSAGE('(%i, %i)',  p.[precision], p.scale)
				WHEN t.[name] LIKE '%char' AND p.max_length = -1
				THEN '(MAX)'
				WHEN t.[name] LIKE 'n%char'
				THEN FORMATMESSAGE('(%i)', p.max_length / 2)
				WHEN t.[name] LIKE '%char'
				THEN FORMATMESSAGE('(%i)', p.max_length)
				ELSE ''
				END
			FROM sys.parameters AS p
				INNER JOIN sys.types AS t
					ON p.user_type_id = t.user_type_id
			WHERE p.[object_id] = @ObjectID
			ORDER BY p.parameter_id;
	DECLARE @ParamCount INT = @@ROWCOUNT;
	
	UPDATE #Parameters
		SET EndIndex = CHARINDEX(
			CASE --Param Terminator
				WHEN ID < @ParamCount
				THEN ','
				ELSE '	AS'
				END,
			@Code,
			StartIndex + 1
			)
		WHERE StartIndex > 0;

--Look for parameters defaults...
	UPDATE #Parameters
		SET StartIndex = CHARINDEX('=', @Code, StartIndex)
		WHERE StartIndex > 0;

	UPDATE #Parameters
		SET ParamDefault = TRIM(' ()
	'		FROM SUBSTRING(@Code, StartIndex + 1, EndIndex - StartIndex - 1))
		WHERE StartIndex > 0 AND StartIndex < EndIndex;

	UPDATE #Parameters
		SET ValueDelimiter = CASE
				WHEN ISNULL(ParamDefault, '') <> 'NULL'
					AND (
						IsString = 1
						OR IsDateTime = 1
						)
				THEN ''''
				ELSE ''
				END;

	DECLARE @Declare VARCHAR(MAX)
	SELECT @Declare = 'DECLARE ' + STRING_AGG(ParameterName + ' ' + ParameterDefinition, ', ') + ';'
		FROM #Parameters
		WHERE is_output = 1;

	DECLARE @Exec VARCHAR(MAX);
	SELECT @Exec = ' ' + STRING_AGG(
		CASE WHEN is_output = 1
			THEN CONCAT(ParameterName, ' = ', ParameterName, ' OUTPUT')
			ELSE CONCAT(ParameterName, ' = <', ParameterName, ', ', ParameterDefinition, ', ', ValueDelimiter,
				TRIM('''' FROM ParamDefault), ValueDelimiter, '>')
			END, ',
	')	FROM #Parameters;
	SET @Exec = 'EXEC ' + @ProcedureName + ISNULL(@Exec, '') + ';';

	DECLARE @Output VARCHAR(MAX);
	SELECT @Output = 'SELECT ' + STRING_AGG(QUOTENAME(ParameterName) + ' = ' + ParameterName, ',
	') + ';'
		FROM #Parameters
		WHERE is_output = 1;

	PRINT @Declare;
	PRINT @Exec;
	PRINT @Output;
END;
GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: dbo.sp_ScriptInsert.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Prodedure to prepare an INSERT statement for a given table
Created:		20 Apr 2017
Author:			Nick Allan

--Example use:
sp_scriptinsert org_statuses;

*/
CREATE PROCEDURE dbo.sp_ScriptInsert
	(
	@SchemaTableName SYSNAME,
	@ExcludeDateColumnsWithDefaults BIT = 1 --Providing a default of getdate() exists
	)
	AS
BEGIN;
	SET NOCOUNT ON;

--DEBUG: declare @schematablename sysname = 'org_statuses', @excludedatecolumnswithdefaults bit = 1;
	EXEC dbo.sp_MatchTableName @TableName = @SchemaTableName OUTPUT;
	DECLARE @ObjectId INT = OBJECT_ID(@SchemaTableName, 'U');

	IF @ObjectId IS NULL
	BEGIN;
		DECLARE @ErrorMessage VARCHAR(MAX) = FORMATMESSAGE('Failed to find table named %s', @SchemaTableName);
		THROW 50000, @ErrorMessage, 1;
	END;

	DROP TABLE IF EXISTS #Columns;
	SELECT c.column_id,
		ColumnName = CONVERT(NVARCHAR(MAX),
			CASE WHEN c.[name] LIKE '%[^a-zA-Z0-9_]%' THEN QUOTENAME(c.[name]) ELSE c.[name] END
			),
		TypeName = t.[name],
		IsString = CASE WHEN c.collation_name IS NULL THEN 0 ELSE 1 END,
		IsUnicode = CASE WHEN c.collation_name IS NOT NULL AND t.[name] LIKE 'N%' THEN 1 ELSE 0 END,
		c.is_nullable,
		DefaultDefinition = d.[definition],
		ReferenceQuery = (
			SELECT DISTINCT --Allow for duplicate Foriegn Keys!
				FORMATMESSAGE('SELECT %s FROM %s.%s',
					fc.[name],
					OBJECT_SCHEMA_NAME(fkc.referenced_object_id),
					OBJECT_NAME(fkc.referenced_object_id)
					)
				FROM sys.foreign_key_columns AS fkc
					INNER JOIN sys.columns AS fc
						ON fkc.referenced_object_id = fc.[object_id]
						AND fkc.referenced_column_id = fc.column_id
				WHERE c.[object_id] = fkc.parent_object_id
					AND c.column_id = fkc.parent_column_id
			),
		SelectColumnDelimiter = ','
		INTO #Columns
		FROM sys.columns AS c
			LEFT OUTER JOIN sys.default_constraints AS d
				ON c.[object_id] = d.parent_object_id
				AND c.column_id = d.parent_column_id
			INNER JOIN sys.types AS t
				ON c.system_type_id = t.system_type_id
				AND c.user_type_id = t.user_type_id
		WHERE c.[object_id] = @ObjectId
			AND c.is_identity = 0
			AND c.is_computed = 0;
	
	WHILE @@ROWCOUNT > 0
		UPDATE #Columns
			SET DefaultDefinition = SUBSTRING(DefaultDefinition, 2, LEN(DefaultDefinition) - 2)
			WHERE DefaultDefinition LIKE '(%)';

	UPDATE #Columns
		SET DefaultDefinition = 'N' + DefaultDefinition
		WHERE IsUnicode = 1
			AND DefaultDefinition NOT LIKE 'N%';

	IF @ExcludeDateColumnsWithDefaults = 1
		DELETE #Columns
			WHERE TypeName LIKE '%DATE%'
				AND DefaultDefinition = 'getdate()';

	UPDATE #Columns
		SET SelectColumnDelimiter = ';'
		WHERE column_id = (
			SELECT MAX(column_id) FROM #Columns
			);
		
	DECLARE @InsertDelimiter VARCHAR(10) = ',
	',	@SelectDelimiter VARCHAR(10) = '
		';
	DECLARE @InsertColumnList NVARCHAR(MAX) = (
			SELECT STRING_AGG(ColumnName, @InsertDelimiter)
				WITHIN GROUP (ORDER BY column_id)
				FROM #Columns
			),
		@SelectColumnList NVARCHAR(MAX) = (
			SELECT STRING_AGG(ColumnName + ' = ' + CASE
					WHEN DefaultDefinition IS NOT NULL THEN DefaultDefinition
					WHEN is_nullable = 1 THEN 'NULL'
					WHEN IsUnicode = 1 THEN 'N'''''
					WHEN IsString = 1 THEN ''''''
					ELSE ''
					END
				+ SelectColumnDelimiter
				+ ISNULL(' --' + ReferenceQuery, ''),
				@SelectDelimiter COLLATE DATABASE_DEFAULT)
				WITHIN GROUP (ORDER BY column_id)
				FROM #Columns
			);

	PRINT '
INSERT ' + @SchemaTableName + '
	(
	' + @InsertColumnList + '
	)';
	PRINT '	SELECT ' + @SelectColumnList;
END;
GO

GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: dbo.sp_LaunchTool.sql';
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Helper procedure to call other helper tools based on the given input.  Add as an SMSS Keyboard Shortcut via
				Tools > Options > Keyboard > Ctrl+0 > sp_LaunchTool > OK
Author:			Nick Allan
Date:			24 Apr 2017

--Example SQL:
sp_LaunchTool sp_LaunchTool

EXEC sp_LaunchTool organisations, persontoorg
*/
CREATE PROCEDURE dbo.sp_LaunchTool
	(
	@Object1 SYSNAME = NULL, --A table or a procedure
--Tables only used when JOINing...
	@Object2 SYSNAME = NULL,
	@Object3 SYSNAME = NULL,
	@Object4 SYSNAME = NULL,
	@Object5 SYSNAME = NULL,
	@Object6 SYSNAME = NULL,
	@Object7 SYSNAME = NULL,
	@ListColumns BIT = 0
	)
	AS
BEGIN;
	SET NOCOUNT ON;

	IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = @Object1 OR [object_id] = OBJECT_ID(@Object1, 'P'))
	BEGIN;
		EXEC dbo.sp_ScriptExecute @Object1;
		RETURN;
	END;
	
	EXEC dbo.sp_MatchTableName @TableName = @Object1 OUTPUT;
	
	IF @Object2 IS NULL
		EXEC dbo.sp_ScriptInsert @Object1;
	ELSE
		EXEC dbo.sp_Join @Table1 = @Object1,
			@Table2 = @Object2,
			@Table3 = @Object3,
			@Table4 = @Object4,
			@Table5 = @Object5,
			@Table6 = @Object6,
			@Table7 = @Object7,
			@ListColumns = @ListColumns;
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
