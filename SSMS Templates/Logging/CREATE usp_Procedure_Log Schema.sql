IF OBJECT_ID('<SchemaName, SYSNAME, YourSchema>.Procedure_Log', 'U') IS NULL
	CREATE TABLE <SchemaName, , >.Procedure_Log(
		LogId INT NOT NULL CONSTRAINT PK_Procedure_Log PRIMARY KEY IDENTITY,
		ProcedureName SYSNAME NOT NULL,
		CallId INT NOT NULL,
		IsError bit NOT NULL,
		LogRowCount INT NULL,
		LogMessage VARCHAR(1000) NOT NULL,
		CreatedDateTime DATETIME NOT NULL CONSTRAINT DF_Procedure_Log_CreatedDateTime DEFAULT GETDATE()
		);
GO
/*

Description:	Procedure to add a row to <SchemaName, , >.Procedure_Log
Author:			Nick Allan

--Example use:
DECLARE @CallId INT;
SELECT * FROM <SchemaName, , >.Procedure_Log
EXEC <SchemaName, , >.usp_Procedure_Log_Insert @ProcedureName = '<SchemaName, , >.usp_Procedure_Log_Insert',
	@CallId = @CallId OUTPUT,
	@LogMessage = 'TEST';
SELECT *
	FROM <SchemaName, , >.Procedure_Log
	WHERE CallId = @CallId;

*/
CREATE OR ALTER PROCEDURE <SchemaName, , >.usp_Procedure_Log_Insert
	(
	@ProcedureName SYSNAME,
	@CallId INT = NULL OUTPUT,
	@IsError BIT = 0,
	@LogRowCount INT = NULL,
	@LogMessage VARCHAR(1000)
	)
	AS
BEGIN;
	SET NOCOUNT ON;
	
	IF @CallId = 0
	BEGIN;
		PRINT FORMATMESSAGE(
			'%s: %s',
			CASE WHEN @IsError = 1 THEN 'ERROR' ELSE 'INFO' END,
			@LogMessage
			)
			+ CASE WHEN @LogRowCount IS NULL THEN '' ELSE FORMATMESSAGE(' (%i rows)', @LogRowCount) END;
		RETURN;
	END;
	
	IF @CallId IS NULL
		SET @CallId = ISNULL(
			(SELECT MAX(CallId) + 1 FROM <SchemaName, , >.Procedure_Log),
			1);
	
	INSERT <SchemaName, , >.Procedure_Log
		(
		ProcedureName,
		CallId,
		IsError,
		LogRowCount,
		LogMessage
		)
		SELECT @ProcedureName,
			@CallId,
			@IsError,
			@LogRowCount,
			@LogMessage;
END;
GO
/*

Description:	Procedure to delete old log rows
Created:		8 Feb 2019
Author:			Nick Allan

--Example use:
SELECT TOP 1 * FROM <SchemaName, , >.Procedure_Log
EXEC <SchemaName, , >.usp_Procedure_Log_Clear;
SELECT TOP 1 * FROM <SchemaName, , >.Procedure_Log

*/
CREATE OR ALTER PROCEDURE <SchemaName, , >.usp_Procedure_Log_Clear
	(
	@MonthsToRetain INT = <MonthsToRetain, INT, 3>,
	@BatchSize INT = 4000,
	@StopAfterMinutes INT = 20
	)
	AS
BEGIN;
	SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY LOW;
	
	DECLARE @KeepAfterDate DATE = DATEADD(MONTH, -@MonthsToRetain, GETDATE()),
		@StopAfterTime DATETIME = DATEADD(MINUTE, @StopAfterMinutes, GETDATE());

	WHILE GETDATE() <= @StopAfterTime
	BEGIN;
		DROP TABLE IF EXISTS #ToDelete;
		SELECT TOP (@BatchSize) LogId
			INTO #ToDelete
			FROM <SchemaName, , >.Procedure_Log
			WHERE CreatedDateTime < @KeepAfterDate
			ORDER BY LogId;
		IF @@ROWCOUNT = 0
			BREAK;

		DELETE l
			FROM <SchemaName, , >.Procedure_Log AS l
				INNER JOIN #ToDelete AS d
					ON l.LogId = d.LogId;
	END;
END;
GO
