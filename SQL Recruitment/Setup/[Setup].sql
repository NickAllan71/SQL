/*
Description:    Script bundled from C:\Git Repos\NicksGitHub\SQL\SQL Recruitment\Setup
Author:         Nick Allan (assumed)
Date:           04/02/2024 00:11:10
	01. Create schema interview.sql
	02. Create candidate.sql
*/
PRINT 'Script: 01. Create schema interview.sql';
GO
IF SCHEMA_ID('interview') IS NULL
	EXEC ('CREATE SCHEMA interview AUTHORIZATION dbo;');
GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
PRINT 'Script: 02. Create candidate.sql';
GO
--Run from DB(s) user requires access to
DROP USER IF EXISTS [candidate];
GO
CREATE USER [candidate] WITH PASSWORD = 'Int3rv13w';

ALTER ROLE db_owner ADD MEMBER [candidate];
GO
IF @@ERROR <> 0 SET NOEXEC ON;
GO
DECLARE @Success AS BIT
SET @Success = 1;
SET NOEXEC OFF;
IF @Success = 1
    PRINT 'The database update succeeded';
ELSE
    PRINT 'The database update failed';
GO
