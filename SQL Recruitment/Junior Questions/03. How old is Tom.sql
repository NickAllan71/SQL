DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	NameEn VARCHAR(50),
	DateOfBirth DATE
	);

INSERT #Test
	SELECT 'Tom', '1 JAN 1960'
	UNION ALL
	SELECT 'Dick', '1 JAN 1970'
	UNION ALL
	SELECT 'Harry', '1 JAN 2000';

SELECT *,
	Age = DATEDIFF(YEAR, GETDATE(), DateOfBirth) --Can you fix this problem?
	FROM #Test;