DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	TestId INT IDENTITY PRIMARY KEY,
	NameEn VARCHAR(50),
	DateOfBirth DATE,
	GenderId CHAR(1),
	CreatedDateTime DATETIME NOT NULL DEFAULT GETDATE()
	);

INSERT #Test
	(
	NameEn,
	DateOfBirth,
	GenderId
	)
	SELECT NameEn = 'Tom',
		DateOfBirth = '31 JAN 1960',
		GenderId = 'M'
	UNION ALL
	SELECT 'Dick', '31 MAY 1970', 'M'
	UNION ALL
	SELECT 'Harry', '31 MAR 1980', 'M'
	UNION ALL
	SELECT 'Harry', '31 MAR 1980','M'
	UNION ALL
	SELECT 'Julia', '28 FEB 2005','F';

DROP TABLE IF EXISTS #Duplicates;
SELECT DuplicateId = ROW_NUMBER() OVER (
	PARTITION BY NameEn,
		DateOfBirth,
		GenderId
	ORDER BY TestId
	),
	*
	INTO #Duplicates
	FROM #Test;

--How might you turn this statement into a DELETE statement to remove duplicates?
SELECT t.*,
	d.DuplicateId
	FROM #Test AS t
		INNER JOIN #Duplicates AS d
			ON t.TestId = d.TestId
			AND d.DuplicateId > 1;

SELECT * FROM #Test;