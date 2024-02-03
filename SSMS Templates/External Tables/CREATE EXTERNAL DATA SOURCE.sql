IF EXISTS (
	SELECT 1 FROM sys.external_data_sources WHERE [name] = 'eds_<External DB Name, SYSNAME, >'
	)
	DROP EXTERNAL DATA SOURCE [eds_<External DB Name, , >]
GO
CREATE EXTERNAL DATA SOURCE [eds_<External DB Name, , >]
	WITH (
		TYPE = RDBMS,
		LOCATION = N'<SqlInstanceName, SYSNAME, ___.database.windows.net>',
		CREDENTIAL = [<CredentialName, SYSNAME, YourCredentialName>], --SELECT * FROM sys.database_scoped_credentials
		DATABASE_NAME = N'<External DB Name, , >'
	);