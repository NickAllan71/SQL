--Run from DB(s) user requires access to.  E.g. diligencia-d
DROP USER IF EXISTS [<LoginName, SYSNAME, firstname.lastname>];
GO
CREATE USER [<LoginName, , >] FOR LOGIN [<LoginName, , >];

ALTER ROLE db_owner ADD MEMBER [<LoginName, , >];