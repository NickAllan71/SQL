--How might you test for improved performance?
DECLARE @DateFrom DATE = DATEADD(YEAR, -3, GETDATE());
DROP TABLE IF EXISTS #Results;
SELECT org.OrgId,
	org.LastReviewDate
	INTO #Results
	FROM dbo.Org_Organisations AS org
	WHERE LastReviewDate > @DateFrom;

SELECT *,
	AgeInYears = DATEDIFF(YEAR, LastReviewDate, GETDATE())
	FROM #Results
	ORDER BY LastReviewDate;