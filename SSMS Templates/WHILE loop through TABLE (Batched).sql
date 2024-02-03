DECLARE @BatchSize INT = 50000,
	@Finished BIT = 0;
WHILE @Finished = 0
BEGIN;
	
	SET @Finished = CASE WHEN @@ROWCOUNT = @BatchSize THEN 0 ELSE 1 END;
END;