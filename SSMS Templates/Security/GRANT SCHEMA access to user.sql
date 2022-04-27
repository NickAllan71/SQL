<Grant or REVOKE, , GRANT> <PermissionName, SYSNAME, EXECUTE> --select distinct permission_name from sys.database_permissions;
	ON SCHEMA::[<SchemaName, SYSNAME, YourSchema>] --select * from sys.schemas;
	TO [<UserName, SYSNAME, YourUser>] --select type_desc, name from sys.database_principals order by 1 desc, 2;
	AS [dbo];

SELECT PrincipalName = p.[name],
	p.[type_desc],
	dp.[permission_name],
	dp.[state_desc],
	ObjectName = CASE dp.class_desc
		WHEN 'DATABASE' THEN DB_NAME(dp.major_id)
		WHEN 'SCHEMA' THEN SCHEMA_NAME(dp.major_id)
		WHEN 'OBJECT_OR_COLUMN' THEN CONCAT_WS('.', OBJECT_SCHEMA_NAME(dp.major_id), OBJECT_NAME(dp.major_id), c.[name])
		END
	FROM sys.database_principals AS p
		LEFT OUTER JOIN sys.database_permissions AS dp
			ON p.principal_id = dp.grantee_principal_id
		LEFT OUTER JOIN sys.columns AS c
			ON dp.major_id = c.[object_id]
			AND dp.minor_id = c.column_id
	WHERE p.[name] = '<UserName, , >'
	ORDER BY 1, 2, 3, 4;