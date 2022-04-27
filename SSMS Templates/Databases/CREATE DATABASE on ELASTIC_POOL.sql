--Run this from master
CREATE DATABASE [<NewDatabaseName, SYSNAME, VendorDbName>]
    COLLATE <CollationName, SYSNAME, Latin1_General_CI_AS>
	(
    SERVICE_OBJECTIVE = ELASTIC_POOL (
        NAME = [<ElasticPoolName, SYSNAME, diligenciasqlpool>]
        )
    );
RETURN;

--Run this from [<NewDatabaseName, , >]
CREATE USER [<UserName, SYSNAME, YourUserName>]
	WITH PASSWORD = '<Password, SYSNAME, Mu$tCh@ng3>';
ALTER ROLE db_owner ADD MEMBER [<UserName, , >];