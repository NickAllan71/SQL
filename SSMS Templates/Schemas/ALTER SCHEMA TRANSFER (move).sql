IF OBJECT_ID('<CurrentSchema, SYSNAME, dbo>.<ObjectName, SYSNAME, YourObjectName>') IS NOT NULL
	ALTER SCHEMA <NewSchema, SYSNAME, YourNewSchema>
		TRANSFER <CurrentSchema, SYSNAME, >.<ObjectName, , >;