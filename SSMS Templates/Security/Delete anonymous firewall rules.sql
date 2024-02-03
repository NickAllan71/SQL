USE [master];
GO
SELECT CONCAT('EXECUTE sp_delete_firewall_rule @name = N''', [name], ''';')
	FROM sys.firewall_rules
	WHERE name LIKE 'ClientIPAddress%';

