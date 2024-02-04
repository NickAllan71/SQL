DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	TestId INT IDENTITY PRIMARY KEY,
	NameEn VARCHAR(50),
	DateOfBirth DATE,
	GenderId CHAR(1),
	CreatedDateTime DATETIME DEFAULT GETDATE()
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

--How might you identify and DELETE duplication?  Hint: You could use the ROW_NUMBER() window function