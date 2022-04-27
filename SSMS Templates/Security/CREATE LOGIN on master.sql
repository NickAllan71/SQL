--Run from master (requires loginmanager role)
IF EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = '<LoginName, SYSNAME, firstname.lastname>')
	DROP LOGIN [<LoginName, , >];

CREATE LOGIN [<LoginName, , >]
	WITH PASSWORD = '<Password, SYSNAME, Mu$tCh@ng3>';