DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	NameEn VARCHAR(50),
	DateOfBirth DATE,
	GenderId CHAR(1)
	);

INSERT #Test
	(
	NameEn,
	DateOfBirth,
	GenderId
	)
	SELECT NameEn = 'Tom',
		DateOfBirth = '1 JAN 1960',
		GenderId = 'M'
	UNION ALL
	SELECT 'Dick', '1 JAN 1970', 'M'
	UNION ALL
	SELECT 'Harry', '1 JAN 1980', 'M'
	UNION ALL
	SELECT 'Harriet', '1 JAN 2000','F'
	UNION ALL
	SELECT 'Julia', '1 JAN 2005','F';

--Can you modify this aggregate query to output a grand total?  Hint: you will need to use "WITH ROLLUP"
SELECT PeopleCount = COUNT(1),
	GenderId
	FROM #Test
	GROUP BY GenderId;