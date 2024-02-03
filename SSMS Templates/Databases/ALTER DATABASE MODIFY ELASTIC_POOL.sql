--Run this from master
ALTER DATABASE [<DatabaseName, SYSNAME, YourDatabase>]
	MODIFY (
		SERVICE_OBJECTIVE = ELASTIC_POOL (name = [<ElasticPoolName, SYSNAME, >])
		);

--Check status as follows:
SELECT DatabaseName = d.[name],
	obj.*
	FROM sys.database_service_objectives AS obj
		INNER JOIN sys.databases AS d
			ON obj.database_id = d.database_id

--Check latest utilization:
SELECT TOP 10 * FROM sys.elastic_pool_resource_stats ORDER BY 1 DESC;