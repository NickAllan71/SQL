SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

Description:	Procedure to remove comments from T-SQL code.
Created:		18 Jul 2022
Author:			Nick Allan

*/
CREATE   PROCEDURE dbo.usp_StripCommentsFromCode
	(
	@Code NVARCHAR(MAX) OUTPUT
	)
	AS
BEGIN;
	DECLARE @StartIndex INT = 1;
	
	SET @StartIndex = CHARINDEX('/*', @Code, @StartIndex);
	WHILE @StartIndex > 0
	BEGIN;
		DECLARE @EndIndex INT = CHARINDEX('*/', @Code, @StartIndex + 2);
		IF @EndIndex = 0 BREAK;

		SELECT @Code = LEFT(@Code, @StartIndex - 1) + SUBSTRING(@Code, @EndIndex + 2, LEN(@Code)),
			@StartIndex = 1;
	END;
END;

GO
