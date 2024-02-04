--Run this from master
CREATE DATABASE [<NewDatabaseName, SYSNAME, YouNewDatabase>]
    COLLATE <CollationName, SYSNAME, Latin1_General_CI_AS>
	(
    SERVICE_OBJECTIVE = ELASTIC_POOL (
        NAME = [<ElasticPoolName, SYSNAME, YourElasticPool>]
        )
    );
RETURN;

--Run this from [<NewDatabaseName, , >]
CREATE USER [<UserName, SYSNAME, YourUserName>]
	WITH PASSWORD = '<Password, SYSNAME, YourTemporaryPassword>';
ALTER ROLE db_owner ADD MEMBER [<UserName, , >];