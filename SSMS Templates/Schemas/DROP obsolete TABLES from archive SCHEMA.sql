SELECT CONCAT('DROP TABLE IF EXISTS archive.', [name], ';')
	FROM sys.tables
	WHERE [schema_id] = SCHEMA_ID('archive')
		AND modify_date < DATEADD(YEAR, -1, GETDATE());