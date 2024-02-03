
	DECLARE @CallId INT, @ProcedureName SYSNAME = '<@SchemaName, SYSNAME, >.<@ProcedureName, SYSNAME, >';
	EXEC <@SchemaName, , >.usp_Procedure_Log_Insert @ProcedureName = @ProcedureName, @CallId = @CallId OUTPUT, @LogMessage = 'START';
	
