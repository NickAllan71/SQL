--How might you fix this?
GO
CREATE OR ALTER FUNCTION interview.fn_GetAgeInYears
	(
	@OrgId INT
	)
	RETURNS INT
	AS
BEGIN;
	DECLARE @AgeInYears INT;
	SELECT @AgeInYears = DATEDIFF(YEAR, LastReviewDate, GETDATE())
		FROM dbo.Org_Organisations AS org
		WHERE OrgId = @OrgId;

	RETURN @AgeInYears;
END;
GO
WITH cteResults
	AS
	(
	SELECT AgeInYears = interview.fn_GetAgeInYears(OrgId),
		*
		FROM dbo.Org_Organisations
	)
	SELECT OrgId,
		LastReviewDate,
		AgeInYears
		FROM cteResults
		WHERE AgeInYears < 3
		ORDER BY AgeInYears;