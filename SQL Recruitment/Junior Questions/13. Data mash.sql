DROP TABLE IF EXISTS #Gender;
CREATE TABLE #Gender
	(
	GenderId CHAR(1),
	GenderName VARCHAR(50)
	);
INSERT #Gender
	VALUES ('U', 'Unknown'), ('M', 'Male'), ('F', 'Female');

DROP TABLE IF EXISTS #Test;
CREATE TABLE #Test
	(
	TestId INT IDENTITY PRIMARY KEY,
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
	SELECT 'Harry', '31 MAR 1980', 'U'
	UNION ALL
	SELECT 'Harriet', '29 FEB 2012','F'
	UNION ALL
	SELECT 'Julia', '28 FEB 2005','F';

--How might you combine these two rowsets into one?  Hint you will require a JOIN clause
SELECT * FROM #Test;
SELECT * FROM #Gender;