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
		DateOfBirth = '31 JAN 1960',
		GenderId = 'M'
	UNION ALL
	SELECT 'Dick', '31 MAY 1970', 'M'
	UNION ALL
	SELECT 'Harry', '31 MAR 1980', 'M'
	UNION ALL
	SELECT 'Harriet', '29 FEB 2012','F'
	UNION ALL
	SELECT 'Julia', '29 FEB 2005','F';

--Q1. Why is the above INSERT failing?
--Q2. How could you fix this issue?