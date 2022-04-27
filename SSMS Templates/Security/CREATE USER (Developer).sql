--Run from DB(s) user requires access to.  E.g. diligencia-d
DROP USER IF EXISTS [<LoginName, SYSNAME, firstname.lastname>];
GO
CREATE USER [<LoginName, , >] WITH PASSWORD = '<Password, SYSNAME, Mu$tCh@ng3>';
--ALTER USER [<LoginName, , >] WITH PASSWORD = '<Password, , >';

IF DB_NAME() = 'master'
BEGIN;
	ALTER ROLE dbmanager ADD MEMBER [<LoginName, , >];
	ALTER ROLE loginmanager ADD MEMBER [<LoginName, , >];
END;
ELSE
BEGIN;
	ALTER ROLE db_owner ADD MEMBER [<LoginName, , >];
END;