IF EXISTS (
	SELECT 1 FROM sys.external_data_sources WHERE [name] = 'eds_<External DB Name, SYSNAME, diligencia-p>'
	)
	DROP EXTERNAL DATA SOURCE [eds_<External DB Name, , >]
GO
CREATE EXTERNAL DATA SOURCE [eds_<External DB Name, , >]
	WITH (
		TYPE = RDBMS,
		LOCATION = N'diligenciasql.database.windows.net',
		CREDENTIAL = [VendorImportCredential], --SELECT * FROM sys.database_scoped_credentials
		DATABASE_NAME = N'<External DB Name, , >'
	);