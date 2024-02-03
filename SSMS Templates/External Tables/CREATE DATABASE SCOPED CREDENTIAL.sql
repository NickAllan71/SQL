IF EXISTS(SELECT * FROM sys.database_principals WHERE [name] = '<CredentialIdentity, SYSNAME, YourCredentialUser>')
	DROP USER [<CredentialIdentity, , >];
GO
CREATE USER [<CredentialIdentity, , >] WITH PASSWORD = '<Password, VARCHAR, YourPassword>';

ALTER ROLE db_datareader ADD MEMBER [<CredentialIdentity, , >];
GO
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
	CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<Password, VARCHAR, YourMasterKeyPassword>';
GO
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = '<CredentialName, SYSNAME, YourCredentialName>')
	DROP DATABASE SCOPED CREDENTIAL <CredentialName, , >;
GO
CREATE DATABASE SCOPED CREDENTIAL <CredentialName, , >
	WITH IDENTITY = '<CredentialIdentity, , >',
	SECRET = '<Password, VARCHAR, YourSecret>';