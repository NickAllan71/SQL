WITH cteExtendedForeignKeyNameRequired
	AS
	(
	SELECT parent_object_id,
		referenced_object_id
		FROM sys.foreign_keys
		GROUP BY parent_object_id,
			referenced_object_id
		HAVING COUNT(1) > 1
	),
	cteExpectedNames
	AS
	(
	SELECT ObjectType = 'OBJECT',
		kc.parent_object_id,
		Current_Name = kc.[name],
		Expected_Name = CONCAT('PK_', t.[name])
		FROM sys.key_constraints AS kc
			INNER JOIN sys.tables AS t
				ON kc.parent_object_id = t.[object_id]
		WHERE kc.[type] = 'PK'
	UNION ALL
	SELECT ObjectType = 'OBJECT',
		d.parent_object_id,
		Current_Name = d.[name],
		ExpectedName = CONCAT('DF_', t.[name], '_', c.[name])
		FROM sys.columns AS c
			INNER JOIN sys.tables AS t
				ON c.[object_id] = t.[object_id]
			INNER JOIN sys.default_constraints AS d
				ON c.[object_id] = d.parent_object_id
				AND c.column_id = d.parent_column_id
	UNION ALL
	SELECT ObjectType = 'INDEX',
		parent_object_id = i.[object_id],
		Current_Name = i.[name],
		ExpectedName = CONCAT(
			CASE WHEN i.is_unique = 1 THEN 'UI' ELSE 'IX' END,
			'_', t.[name],
			(
			SELECT '_' + STRING_AGG(c.[name], '_')
				WITHIN GROUP (ORDER BY ic.key_ordinal)
				FROM sys.index_columns AS ic
					INNER JOIN sys.columns AS c
						ON ic.[object_id] = c.[object_id]
						AND ic.column_id = c.column_id
				WHERE i.[object_id] = ic.[object_id]
					AND i.index_id = ic.index_id
					AND is_included_column = 0
			),
			(
			SELECT '_Include_' + STRING_AGG(c.[name], '_')
				WITHIN GROUP (ORDER BY ic.key_ordinal)
				FROM sys.index_columns AS ic
					INNER JOIN sys.columns AS c
						ON ic.[object_id] = c.[object_id]
						AND ic.column_id = c.column_id
				WHERE i.[object_id] = ic.[object_id]
					AND i.index_id = ic.index_id
					AND is_included_column = 1
			),
			'_WHERE_' + REPLACE(TRANSLATE(filter_definition, '()[]', '    '), ' ', '') COLLATE DATABASE_DEFAULT
			)
		FROM sys.indexes AS i
			INNER JOIN sys.tables AS t
				ON i.[object_id] = t.[object_id]
		WHERE i.[type_desc] <> 'HEAP'
			AND is_primary_key = 0
	UNION ALL
	SELECT ObjectType = 'OBJECT',
		f.[object_id],
		Current_Name = f.[name],
		ExpectedName = CASE WHEN EXISTS (
			SELECT 1 FROM cteExtendedForeignKeyNameRequired AS e
				WHERE e.parent_object_id = f.parent_object_id
					AND e.referenced_object_id = f.referenced_object_id
			)
			THEN CONCAT_WS('_', 'FK', pt.[name], pc.[name], rt.[name])
			ELSE CONCAT_WS('_', 'FK', pt.[name], rt.[name])
			END
		FROM sys.foreign_keys AS f
			INNER JOIN sys.tables AS pt
				ON f.parent_object_id = pt.[object_id]
			INNER JOIN sys.tables AS rt
				ON f.referenced_object_id = rt.[object_id]
			INNER JOIN sys.foreign_key_columns AS fkc
				ON f.[object_id] = fkc.constraint_object_id 
				AND f.parent_object_id = fkc.parent_object_id
				AND f.referenced_object_id = fkc.referenced_object_id
			INNER JOIN sys.columns AS pc
				ON f.parent_object_id = pc.[object_id]
				AND fkc.parent_column_id = pc.column_id
			INNER JOIN sys.columns AS rc
				ON f.referenced_object_id = rc.[object_id]
				AND fkc.referenced_column_id = rc.column_id
	)
	SELECT en.*,
		FixSql = CONCAT('EXEC sys.sp_rename @objname = N''',
			QUOTENAME(s.[name]), '.',
			CASE WHEN ObjectType = 'INDEX' THEN QUOTENAME(o.[name]) + '.' END,
			QUOTENAME(Current_Name),
			''', @newname = N''',
			Expected_Name,
			''', @objtype = N''',
			ObjectType, ''';'),
		IsTooLong = CASE WHEN LEN(Expected_Name) > 128 THEN 1 ELSE 0 END
		FROM cteExpectedNames AS en
			INNER JOIN sys.objects AS o
				ON en.parent_object_id = o.[object_id]
			INNER JOIN sys.schemas AS s
				ON o.[schema_id] = s.[schema_id]
		WHERE en.Current_Name <> LEFT(en.Expected_Name, 128) COLLATE Latin1_General_BIN
			AND s.[name] NOT IN ('SYS', 'archive')
		ORDER BY IsTooLong;