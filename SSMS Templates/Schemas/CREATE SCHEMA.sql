IF SCHEMA_ID('<SchemaName, SYSNAME, verb>') IS NULL
	EXEC ('
CREATE SCHEMA [<SchemaName, , >]
	AUTHORIZATION dbo;');
GO
GRANT EXECUTE ON SCHEMA::[<SchemaName, , >]
	TO [<UserName, SYSNAME, asteriskuser>] --select name from sys.database_principals where type = 's' order by 1;
	AS [dbo];