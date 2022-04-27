DROP TRIGGER IF EXISTS <SchemaName, SYSNAME, dbo>.tr_<TableName, SYSNAME, YourTableName>_<TriggerNameSuffix, SYSNAME, YourSuffix>;
GO
/*

Description:	<Description, VARCHAR, Trigger to >
Created:		<CreatedDate, DATE, >
Author:			<CreatedBy, SYSNAME, Nick Allan>

*/
CREATE TRIGGER <SchemaName, , >.tr_<TableName, , >_<TriggerNameSuffix, , >
	ON <SchemaName, , >.<TableName, , >
	AFTER <ActionAfter, VARCHAR, INSERT, UPDATE, DELETE>
	AS
BEGIN;
	SET NOCOUNT ON;
	
	
END;
GO