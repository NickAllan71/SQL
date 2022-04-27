--Run from "master" with diligenciaadmin login
DROP DATABASE IF EXISTS [<NewDatabaseName, SYSNAME, diligencia-t>];
CREATE DATABASE [<NewDatabaseName, , >] AS COPY OF [<SourceDatabaseName, SYSNAME, diligencia-p>];

/* Monitor progress in a separate query:
SELECT * FROM sys.dm_database_copies;
SELECT state_desc, * FROM sys.databases WHERE name IN ('<NewDatabaseName, , >', '<SourceDatabaseName, , >');
SELECT d.[name], so.*
	FROM sys.database_service_objectives AS so
		INNER JOIN sys.databases AS d
			ON so.database_id = d.database_id
	WHERE d.[name] IN ('<NewDatabaseName, , >', '<SourceDatabaseName, , >');
*/