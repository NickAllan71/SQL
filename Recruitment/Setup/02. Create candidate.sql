--Run from DB(s) user requires access to.  E.g. diligencia-t
DROP USER IF EXISTS [candidate];
GO
CREATE USER [candidate] WITH PASSWORD = 'Int3rv13w';

ALTER ROLE db_owner ADD MEMBER [candidate];