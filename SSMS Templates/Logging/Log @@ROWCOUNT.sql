
	EXEC <@SchemaName, SYSNAME, >.usp_Procedure_Log_Insert @ProcedureName = @ProcedureName, @CallId = @CallId, @LogRowCount = @@ROWCOUNT,
		@LogMessage = '<@LogMessage, VARCHAR(1000), Inserted\Updated\Deleted table>';