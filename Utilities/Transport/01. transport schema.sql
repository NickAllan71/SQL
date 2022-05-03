IF SCHEMA_ID('transport') IS NULL
	EXEC ('
CREATE SCHEMA [transport]
	AUTHORIZATION dbo;');